import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  int? _role;
  User? _currentUser; // Use User from firebase_auth

  UserModel() {
    fetchUserRole(); // Fetch the role when the model is instantiated
  }

  int? get role => _role; // Getter for role
  User? get currentUser => _currentUser; // Getter for current user

  // Method to fetch the current user's role
  Future<void> fetchUserRole() async {
    _currentUser = FirebaseAuth.instance.currentUser; // Get current Firebase user

    if (_currentUser != null) {
      String uid = _currentUser!.uid; // Get the current user's UID

      try {
        // Check for role in MD (HR) node
        final mdRef = FirebaseDatabase.instance.ref("MD/$uid");
        final mdSnapshot = await mdRef.child("role").get();

        if (mdSnapshot.exists) {
          _role = int.parse(mdSnapshot.value.toString());
        } else {
          // If not found in MD, check the Employee node
          final employeeRef = FirebaseDatabase.instance.ref("Employee/$uid");
          final employeeSnapshot = await employeeRef.child("role").get();

          if (employeeSnapshot.exists) {
            _role = int.parse(employeeSnapshot.value.toString());
          } else {
            // If not found in Employee, check the Manager node
            final managerRef = FirebaseDatabase.instance.ref("Manager/$uid");
            final managerSnapshot = await managerRef.child("role").get();

            if (managerSnapshot.exists) {
              _role = int.parse(managerSnapshot.value.toString());
            } else {
              // Handle case where the role is not found in any node
              print("User role not found in MD, Employee, or Manager nodes.");
            }
          }
        }
      } catch (e) {
        print('Error fetching user role: $e'); // Handle any errors that occur
      }
    }

    notifyListeners(); // Notify listeners after fetching the role
  }
}
