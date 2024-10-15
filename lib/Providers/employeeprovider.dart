import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Employee {
  final String uid;
  final String name;
  final String department;

  Employee({required this.uid, required this.name, required this.department});
}

class EmployeeProvider with ChangeNotifier {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref().child('Employee');
  List<Employee> _employees = [];
  List<Employee> get employees => _employees;
  int get totalEmployeeCount => employees.length;

  Future<void> fetchEmployeesByDepartment(String departmentName) async {
    _employees.clear(); // Clear previous employees

    try {
      final snapshot = await _databaseReference
          .orderByChild("departmentName") // Ensure the field name matches your database
          .equalTo(departmentName)
          .once();

      final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _employees = data.entries.map((entry) {
          final employeeData = entry.value as Map<dynamic, dynamic>;
          return Employee(
            uid: entry.key,
            name: employeeData['name'] ?? '',
            department: employeeData['departmentName'] ?? '',
          );
        }).toList();
        print("Employees fetched: ${_employees.length}"); // Log number of employees fetched
      } else {
        print("No employees found for department: $departmentName");
      }
    } catch (e) {
      print("Error fetching employees: $e"); // Log any errors
    }

    notifyListeners(); // Notify listeners that employee data has been updated
  }
}
