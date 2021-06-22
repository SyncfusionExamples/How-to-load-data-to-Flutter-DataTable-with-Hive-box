import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'employee.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:convert';

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
