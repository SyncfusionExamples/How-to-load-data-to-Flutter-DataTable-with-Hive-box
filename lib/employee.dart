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
