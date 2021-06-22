import 'employee.dart';
import 'database.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

// ignore: must_be_immutable
class EmployeeListScreen extends StatelessWidget {
  EmployeeListScreen() {
    database = Get.put(EmployeeDatabase());
    dataGridSource = EmployeeDataSource(employeeDatabase: database);
  }

  EmployeeDatabase database;
  EmployeeDataSource dataGridSource;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController employeeIDController = TextEditingController(),
      employeeNameController = TextEditingController(),
      employeeDesignationController = TextEditingController(),
      employeeSalaryController = TextEditingController();

  Widget buildEditableFormField(
      {TextEditingController controller, String columnName, String value}) {
    // Determine the keyboard type
    final keyboardType = ['Name', 'Designation'].contains(columnName)
        ? TextInputType.text
        : TextInputType.number;

    // Determine the keyboard input type
    final inputFormatter = ['Name', 'Designation'].contains(columnName)
        ? FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
        : FilteringTextInputFormatter.allow(RegExp('[0-9]'));

    return Expanded(
      child: Row(
        children: [
          Container(
              width: 100,
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text(columnName)),
          Container(
            width: 120,
            child: TextFormField(
              initialValue: value,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Field must not be empty';
                }
                return null;
              },
              enabled: true,
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: [inputFormatter],
            ),
          )
        ],
      ),
    );
  }

  List<GridColumn> getColumns() {
    return <GridColumn>[
      GridTextColumn(
          columnName: 'id',
          label: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.center,
              child: Text(
                'ID',
              ))),
      GridTextColumn(
          columnName: 'name',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('Name'))),
      GridTextColumn(
          columnName: 'designation',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text(
                'Designation',
                overflow: TextOverflow.ellipsis,
              ))),
      GridTextColumn(
          columnName: 'salary',
          label: Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.center,
              child: Text('Salary'))),
    ];
  }

  void updateDataGrid() {
    dataGridSource.buildDataGridRows();
    dataGridSource.updateDataGridSource();
    employeeIDController.clear();
    employeeNameController.clear();
    employeeDesignationController.clear();
    employeeSalaryController.clear();
  }

  void showUpdateEmployees(BuildContext context, int index) {
    final int considerHeaderRowIndex = 1;
    final int rowIndex = index - considerHeaderRowIndex;
    final Employee employee = dataGridSource.employeeData[rowIndex];
    employeeIDController.text = employee.id.toString();
    employeeNameController.text = employee.name;
    employeeDesignationController.text = employee.designation;
    employeeSalaryController.text = employee.salary.toString();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      database.updateEmployee(
                          employee: Employee(
                              int.tryParse(employeeIDController.text),
                              employeeNameController.text,
                              employeeDesignationController.text,
                              int.tryParse(employeeSalaryController.text)),
                          key: rowIndex);
                      updateDataGrid();

                      Navigator.pop(context);
                    }
                  },
                  child: Text('Save')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'))
            ],
            content: Container(
              height: 240,
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildEditableFormField(
                          controller: employeeIDController, columnName: 'ID'),
                      buildEditableFormField(
                          controller: employeeNameController,
                          columnName: 'Name'),
                      buildEditableFormField(
                          controller: employeeDesignationController,
                          columnName: 'Designation'),
                      buildEditableFormField(
                          controller: employeeSalaryController,
                          columnName: 'Salary')
                    ],
                  )),
            ),
          );
        });
  }

  showAddEmployee(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    database.addEmployee(Employee(
                        int.tryParse(employeeIDController.text),
                        employeeNameController.text,
                        employeeDesignationController.text,
                        int.tryParse(employeeSalaryController.text)));
                    updateDataGrid();
                    Navigator.pop(context);
                  },
                  child: Text('Save')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'))
            ],
            content: Container(
              height: 240,
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      buildEditableFormField(
                          controller: employeeIDController, columnName: 'ID'),
                      buildEditableFormField(
                          controller: employeeNameController,
                          columnName: 'Name'),
                      buildEditableFormField(
                          controller: employeeDesignationController,
                          columnName: 'Designation'),
                      buildEditableFormField(
                          controller: employeeSalaryController,
                          columnName: 'Salary')
                    ],
                  )),
            ),
          );
        });
  }

  showDeleteEmployee(BuildContext context) {
    TextEditingController index = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            actions: [
              TextButton(
                  onPressed: () {
                    database.deleteEmployee(int.tryParse(index.text));
                    updateDataGrid();
                    Navigator.pop(context);
                  },
                  child: Text('delete')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'))
            ],
            content: Container(
              height: 50,
              child: Form(
                  child: Column(
                children: [
                  buildEditableFormField(
                      controller: index, columnName: 'Index'),
                ],
              )),
            ),
          );
        });
  }

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
