# How to load data to Flutter DataTable with Hive box
Load the data from hive database to the Flutter DataTable widget by fetching the list collection from hive database and create the rows for the datagrid from the that list collection.
The following steps explains how to load the data from hive database for flutter DataTable.
## STEP 1

To access the hive database, you need to add the following dependencies in pubspec.yaml.

```xml
dependencies:
  hive_flutter: ^1.0.0
  get: ^4.1.3
  flutter_secure_storage: ^3.3.5
  hive: ^2.0.0
  path_provider: ^2.0.1

dev_dependencies:
  hive_generator: ^1.0.0
  build_runner: ^1.11.5
```

## STEP 2 

Import the following library in flutter application.	

```xml
import 'dart:convert';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
```

## STEP 3

Create Employee class and add right annotations for generating type adaptors.

```xml
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Employee {
  @HiveField(0)
  int id;
  @HiveField(1)
  String name;
  @HiveField(2)
  String designation;
  @HiveField(3)
  int salary;

  Employee(
    this.id,
    this.name,
    this.designation,
    this.salary,
  );
}
```

## STEP 4

Create a hive database. You have to open the hive box before performing any operation in database. You can open the hive box using Hive.openBox(‘DataBase name’) function. Here we have created hive database for loading data from database and perform curd operation.

```xml
class EmployeeDatabase extends GetxController {
  String boxName = 'employee_database';

  List<Employee> employeeList = [];


  Future<Box<Employee>> encryptedBox() async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: 'key');
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(key: 'key', value: base64UrlEncode(key));
    }
    var encryptionKey = base64Url.decode(await secureStorage.read(key: 'key'));
    var box = await Hive.openBox<Employee>(boxName,
        encryptionCipher: HiveAesCipher(encryptionKey));
    return box;
  }

  void addEmployee(Employee newEmployee) async {
    var box = await Hive.openBox<Employee>(boxName);
    await box.add(newEmployee);
    employeeList = box.values.toList();
    refresh();
  }

  void getEmployees() async {
    var box = await Hive.openBox<Employee>(boxName);
    employeeList = box.values.toList();
    if (employeeList.isEmpty) {
      box.add(Employee(10001, 'James', 'Project Lead', 20000));
      box.add(Employee(10002, 'Kathryn', 'Manager', 30000));
      box.add(Employee(10003, 'Lara', 'Developer', 15000));
      box.add(Employee(10004, 'Michael', 'Designer', 15000));
      box.add(Employee(10005, 'Martin', 'Developer', 15000));
      box.add(Employee(10006, 'Newberry', 'Developer', 15000));
      box.add(Employee(10007, 'Balnc', 'Developer', 15000));
      box.add(Employee(10008, 'Perry', 'Developer', 15000));
      box.add(Employee(10009, 'Gable', 'Developer', 15000));
      box.add(Employee(10010, 'Grimes', 'Developer', 15000));
    }
    refresh();
  }

  List<Employee> getEmployeesList() {
    getEmployees();
    return employeeList;
  }


  void updateEmployee({Employee employee, int key}) async {
    var box = await Hive.openBox<Employee>(boxName);
    await box.putAt(key, employee);
    employeeList = box.values.toList();
    refresh();
  }

  void deleteEmployee(key) async {
    var box = await Hive.openBox<Employee>(boxName);
    await box.deleteAt(key);
    employeeList = box.values.toList();
    refresh();
  }
}
```

## STEP 5

Create class for TypeAdaptor. Here we have created custom TypeAdaptor for employee class.

```xml
import 'package:hive/hive.dart';
import 'employee.dart';

class EmployeeAdaptor extends TypeAdapter<Employee> {
  @override
  final int typeId = 0;

  @override
  Employee read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Employee(
      fields[0] as int,
      fields[1] as String,
      fields[2] as String,
      fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Employee obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.designation)
      ..writeByte(3)
      ..write(obj.salary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmployeeAdaptor &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
```

## STEP 6

Register the type adapter in main function and add the hive initialization.

```xml
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(EmployeeAdaptor());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: EmployeeListScreen(),
    );
  }
}
```

## STEP 7: 

Create data source class extends with DataGridSource for mapping data to the SfDataGrid.

```xml
class EmployeeDataSource extends DataGridSource {
  EmployeeDataSource({this.employeeDatabase}) {
    initialLoading();
    employeeDatabase.addListener(handleListUpdates);
  }

  EmployeeDatabase employeeDatabase;

  List<Employee> employeeData = [];

  List<DataGridRow> _employeeDataGridRow = [];

  void initialLoading() {
    employeeData = employeeDatabase.getEmployeesList();
    buildDataGridRows();
  }

  void handleListUpdates() {
    employeeData = employeeDatabase.employeeList;
    buildDataGridRows();
    notifyListeners();
  }

  void buildDataGridRows() {
    _employeeDataGridRow = employeeData
        .map<DataGridRow>(
          (employee) => DataGridRow(
            cells: [
              DataGridCell<int>(columnName: 'id', value: employee.id),
              DataGridCell<String>(columnName: 'name', value: employee.name),
              DataGridCell<String>(
                  columnName: 'designation', value: employee.designation),
              DataGridCell<int>(columnName: 'salary', value: employee.salary),
            ],
          ),
        )
        .toList();
  }

  void updateDataGridSource() {
    notifyListeners();
  }

  @override
  List<DataGridRow> get rows => _employeeDataGridRow;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((e) {
      return Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(8.0),
        child: Text(e.value.toString()),
      );
    }).toList());
  }
}
```

## STEP 8  

Wrap the SfDataGrid inside the GetBuilder widget. Initialize the SfDataGrid with all the required details. Here we have provided the option perform the curd operation.

```xml
class EmployeeListScreen extends StatelessWidget {
  EmployeeListScreen() {
    database = Get.put(EmployeeDatabase());
    dataGridSource = EmployeeDataSource(employeeDatabase: database);
  }

  EmployeeDatabase database;
  EmployeeDataSource dataGridSource;
  EmployeeDatabase database;
  EmployeeDataSource dataGridSource;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController employeeIDController = TextEditingController(),
      employeeNameController = TextEditingController(),
      employeeDesignationController = TextEditingController(),
      employeeSalaryController = TextEditingController();  

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DataGrid Sample'),
        backgroundColor: Colors.blue,
        actions: [
          MaterialButton(
            onPressed: () {
              showAddEmployee(context);
            },
            child: Icon(Icons.add),
          ),
          MaterialButton(
            onPressed: () {
              showDeleteEmployee(context);
            },
            child: Icon(Icons.delete),
          ),
        ],
      ),
      body: GetBuilder<EmployeeDatabase>(
        builder: (database) {
          return SfDataGrid(
              source: dataGridSource,
              onCellTap: (DataGridCellTapDetails tapDetails) {
                if (tapDetails.rowColumnIndex.rowIndex == 0) {
                  return;
                }
                showUpdateEmployees(
                    context, tapDetails.rowColumnIndex.rowIndex);
              },
              columnWidthMode: ColumnWidthMode.fill,
              columns: getColumns());
        },
      ),
    );
  }
}
}
```

