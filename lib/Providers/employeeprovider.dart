import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Front side/managerDashboard.dart';

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
  List<WorkLocationData> workLocationCounts = [];

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


  Future<void> fetchWorkLocations() async {
    try {
      // Use the ref() method to get a reference to the Employee node
      final DatabaseReference ref = FirebaseDatabase.instance.ref('Employee');
      DatabaseEvent event = await ref.once(); // Use once() to listen for a single event

      // Initialize the counts for work locations
      Map<String, int> locationCount = {
        'Work from Home': 0,
        'Work from Office': 0,
      };

      // Check if the data is not null
      if (event.snapshot.exists) {
        // Get the employee data from the snapshot
        Map<dynamic, dynamic> employees = event.snapshot.value as Map<dynamic, dynamic>;

        employees.forEach((key, value) {
          // Check work location and increment counts
          if (value['workLocation'] == 'Work from Home') {
            locationCount['Work from Home'] = locationCount['Work from Home']! + 1;
          } else if (value['workLocation'] == 'Work from Office') {
            locationCount['Work from Office'] = locationCount['Work from Office']! + 1;
          }
        });

        // Calculate the percentages based on the total number of employees
        int totalEmployees = locationCount['Work from Home']! + locationCount['Work from Office']!;
        if (totalEmployees > 0) {
          workLocationCounts = [
            WorkLocationData('Work from Home', (locationCount['Work from Home']! * 100) / totalEmployees),
            WorkLocationData('Work from Office', (locationCount['Work from Office']! * 100) / totalEmployees),
          ];
        } else {
          workLocationCounts = [
            WorkLocationData('Work from Home', 0),
            WorkLocationData('Work from Office', 0),
          ];
        }

        notifyListeners(); // Notify listeners to update the UI
      }
    } catch (error) {
      print("Error fetching work locations: $error");
    }
  }




}
