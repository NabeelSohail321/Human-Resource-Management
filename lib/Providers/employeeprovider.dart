import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class Employee {
  final String uid;
  final String name;
  final String department;
  String? workLocation; // Add workLocation as a nullable property

  Employee({
    required this.uid,
    required this.name,
    required this.department,
    this.workLocation, // Make it optional
  }
  );
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
            workLocation: employeeData['workLocation'], // Fetch workLocation from the database


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

  // Fetch total employee count for the current manager's department
  Future<void> fetchTotalEmployeeCount(String currentManagerDepartment) async {
    _employees.clear(); // Clear previous employees

    try {
      final snapshot = await _databaseReference
          .orderByChild("departmentName") // Filter employees by department
          .equalTo(currentManagerDepartment)
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
        print("Total employees fetched for department $currentManagerDepartment: ${_employees.length}"); // Log number of employees fetched
      } else {
        print("No employees found in the department: $currentManagerDepartment.");
      }
    } catch (e) {
      print("Error fetching total employee count: $e"); // Log any errors
    }

    notifyListeners(); // Notify listeners that employee data has been updated
  }



  Map<String, dynamic>? _employeeData;

  Map<String, dynamic>? get employeeData => _employeeData;

  Future<void> fetchEmployeeProfile(String uid) async {
    try {
      final snapshot = await _databaseReference.child(uid).get();
      if (snapshot.exists) {
        _employeeData = Map<String, dynamic>.from(snapshot.value as Map);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching employee profile: $e');
    }
  }

  Future<void> updateEmployeeProfile(String uid, Map<String, dynamic> updatedData) async {
    try {
      await _databaseReference.child(uid).update(updatedData);
      _employeeData = updatedData;
      notifyListeners();
    } catch (e) {
      print('Error updating employee profile: $e');
    }
  }


}
