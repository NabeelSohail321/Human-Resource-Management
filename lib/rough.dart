import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseReference _employeeRef = FirebaseDatabase.instance.ref("Employee");
  final DatabaseReference _mdRef = FirebaseDatabase.instance.ref("MD");
  final DatabaseReference _managerRef = FirebaseDatabase.instance.ref("Manager");

  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _users.clear();
    notifyListeners();

    try {
      // Fetching employees
      final employeeSnapshot = await _employeeRef.once();
      if (employeeSnapshot.snapshot.value != null) {
        final employeesData = Map<String, dynamic>.from(employeeSnapshot.snapshot.value as Map);
        _users.addAll(employeesData.values.map((user) {
          final map = Map<String, dynamic>.from(user);
          return {
            'uid': map['uid'] ?? '',
            'name': map['name'] ?? 'Unknown',
            'email': map['email'] ?? 'No Email',
            'role': '1', // Role 1 for Employee
          };
        }).toList());
      }

      // Fetching HR (MD)
      final hrSnapshot = await _mdRef.once();
      if (hrSnapshot.snapshot.value != null) {
        final hrData = Map<String, dynamic>.from(hrSnapshot.snapshot.value as Map);
        _users.addAll(hrData.values.map((user) {
          final map = Map<String, dynamic>.from(user);
          return {
            'uid': map['uid'] ?? '',
            'name': map['name'] ?? 'Unknown',
            'email': map['email'] ?? 'No Email',
            'role': '0', // Role 0 for MD
          };
        }).toList());
      }

      // Fetching Managers
      final managerSnapshot = await _managerRef.once();
      if (managerSnapshot.snapshot.value != null) {
        final managerData = Map<String, dynamic>.from(managerSnapshot.snapshot.value as Map);
        _users.addAll(managerData.values.map((user) {
          final map = Map<String, dynamic>.from(user);
          return {
            'uid': map['uid'] ?? '',
            'name': map['name'] ?? 'Unknown',
            'email': map['email'] ?? 'No Email',
            'role': '2', // Role 2 for Manager
          };
        }).toList());
      }
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    try {
      // Check which node the user is currently in
      DataSnapshot employeeSnapshot = await _employeeRef.child(uid).get();
      DataSnapshot hrSnapshot = await _mdRef.child(uid).get();
      DataSnapshot managerSnapshot = await _managerRef.child(uid).get();
      Map<String, dynamic>? userData;

      if (employeeSnapshot.exists) {
        userData = Map<String, dynamic>.from(employeeSnapshot.value as Map);
        await _employeeRef.child(uid).remove(); // Remove from Employee node
      } else if (hrSnapshot.exists) {
        userData = Map<String, dynamic>.from(hrSnapshot.value as Map);
        await _mdRef.child(uid).remove(); // Remove from HR node
      } else if (managerSnapshot.exists) {
        userData = Map<String, dynamic>.from(managerSnapshot.value as Map);
        await _managerRef.child(uid).remove(); // Remove from Manager node
      }

      if (userData != null) {
        DatabaseReference newRef;
        if (newRole == '0') {
          newRef = _mdRef; // Move to HR node
        } else if (newRole == '1') {
          newRef = _employeeRef; // Move to Employee node
        } else if (newRole == '2') {
          newRef = _managerRef; // Move to Manager node
        } else {
          return; // Invalid role
        }

        await newRef.child(uid).set({
          'uid': uid,
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
        });

        fetchUsers(); // Refresh users
      }
    } catch (e) {
      print('Error updating user role: $e');
    }
  }
}
