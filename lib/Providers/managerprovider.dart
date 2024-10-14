import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/managermodel.dart';

class ManagersProvider with ChangeNotifier {
  List<Manager> _managers = [];
  List<Employee> _employees = []; // Updated to private list for employees

  List<Manager> get managers => _managers;
  List<Employee> get employees => _employees; // Getter to access the list of employees

  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref().child('Manager'); // Reference to the Manager node
  final DatabaseReference _employeesReference =
  FirebaseDatabase.instance.ref().child('Employee'); // Reference to the Employee node

  void fetchManagers() async {
    try {
      _databaseReference.onValue.listen((event) {
        final managersData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (managersData != null) {
          _managers = managersData.entries.map((entry) {
            final managerData = entry.value as Map<dynamic, dynamic>;
            return Manager(
              uid: entry.key,
              name: managerData['name'] ?? '',
              email: managerData['email'] ?? '',
              phone: managerData['phone'] ?? '',
              departmentName: managerData['departmentName'] ?? '',
              managerNumber: managerData['managerNumber'] ?? '',
              role: managerData['role'] ?? '',
              status: managerData['user status'] ?? '',
            );
          }).toList();
        }

        notifyListeners();
      });
    } catch (e) {
      print('Error fetching managers: $e');
    }
  }

  void restrictManager(Manager manager) async {
    try {
      // Remove the manager from the Manager node
      await _databaseReference.child(manager.uid).remove();

      // Add the manager to the Restricted node
      await FirebaseDatabase.instance
          .ref()
          .child('Restricted')
          .child(manager.uid)
          .set({
        'uid':manager.uid,
        'name': manager.name,
        'email': manager.email,
        'phone': manager.phone,
        'departmentName': manager.departmentName,
        'managerNumber': manager.managerNumber,
        'role': manager.role,
        'user status': 'Restricted',
      });

      _managers.remove(manager);
      notifyListeners();
    } catch (e) {
      print('Error restricting manager: $e');
    }
  }

  void fetchEmployees() async {
    try {
      _employeesReference.onValue.listen((event) {
        final employeesData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (employeesData != null) {
          _employees = employeesData.entries.map((entry) {
            final employeeData = entry.value as Map<dynamic, dynamic>;
            return Employee(
              uid: entry.key,
              name: employeeData['name'] ?? '',
              email: employeeData['email'] ?? '',
              phone: employeeData['phone'] ?? '',
              departmentName: employeeData['departmentName'] ?? '',
              role: employeeData['role'] ?? '',
              status: employeeData['user status'] ?? '',
            );
          }).toList();
        }

        notifyListeners();
      });
    } catch (e) {
      print('Error fetching employees: $e');
    }
  }


  List<Employee> getEmployeesByDepartment(String departmentName) {
    return employees.where((employee) => employee.departmentName == departmentName).toList();
  }

}
