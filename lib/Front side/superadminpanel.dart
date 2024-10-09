import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../components.dart';

class SuperAdminPanel extends StatefulWidget {
  @override
  _SuperAdminPanelState createState() => _SuperAdminPanelState();
}

class _SuperAdminPanelState extends State<SuperAdminPanel> {
  final DatabaseReference _employeeRef = FirebaseDatabase.instance.ref("Employees"); // Employee node reference
  final DatabaseReference _hrRef = FirebaseDatabase.instance.ref("HR"); // HR node reference

  List<Map<String, dynamic>> _users = [];
  Map<String, String> _userNames = {};
  int _nextAdminNumber = 1; // Removed nextRiderNumber as it's no longer needed
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() {
      _isLoading = true;
    });

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
            'role': '1', // Assuming role '1' for employees
          };
        }).toList());
      }

      // Fetching HR users
      final hrSnapshot = await _hrRef.once();
      if (hrSnapshot.snapshot.value != null) {
        final hrData = Map<String, dynamic>.from(hrSnapshot.snapshot.value as Map);
        _users.addAll(hrData.values.map((user) {
          final map = Map<String, dynamic>.from(user);
          return {
            'uid': map['uid'] ?? '',
            'name': map['name'] ?? 'Unknown',
            'email': map['email'] ?? 'No Email',
            'role': '0', // Assuming role '0' for HR
          };
        }).toList());
      }

      setState(() {
        _userNames = Map.fromEntries(
            _users.map((user) => MapEntry(user['uid'], user['name'] ?? 'Unknown'))
        );
      });
    } catch (e) {
      print('Error fetching users: $e');
    } finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
  }

  Future<void> updateUserRole(String uid, String role) async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      DataSnapshot employeeSnapshot = await _employeeRef.child(uid).get();
      DataSnapshot hrSnapshot = await _hrRef.child(uid).get();
      Map<String, dynamic>? userData;

      if (employeeSnapshot.exists) {
        userData = Map<String, dynamic>.from(employeeSnapshot.value as Map);
      } else if (hrSnapshot.exists) {
        userData = Map<String, dynamic>.from(hrSnapshot.value as Map);
      }

      if (userData != null) {
        // Role updating logic based on the new structure
        if (role == '0') { // Move to HR node
          await _hrRef.child(uid).set({
            'uid': uid,
            'name': userData['name'] ?? '',
            'email': userData['email'] ?? '',
            // Include other fields as necessary
          });
          await _employeeRef.child(uid).remove();
        } else if (role == '1') { // Remain in employees
          await _employeeRef.child(uid).set({
            'uid': uid,
            'name': userData['name'] ?? '',
            'email': userData['email'] ?? '',
            // Include other fields as necessary
          });
          await _hrRef.child(uid).remove();
        }

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User role updated successfully")));
        await fetchUsers(); // Refresh the users list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User not found")));
      }
    } catch (e) {
      print('Error updating user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error updating user role")));
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.customAppBar("Admin Panel"),
      body: _isLoading // Conditionally display the loading indicator
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Users List
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Users",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  title: Text(user['name'] ?? 'Unknown User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("E-Mail: ${user['email'] ?? 'No Email'}"),
                      Text("Role: ${user['role'] == '0' ? 'HR' : 'Employee'}"),
                    ],
                  ),
                  trailing: DropdownButton<String>(
                    value: user['role'],
                    items: [
                      const DropdownMenuItem(value: '0', child: Text('HR')),
                      const DropdownMenuItem(value: '1', child: Text('Employee')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        updateUserRole(user['uid'], value);
                      }
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
