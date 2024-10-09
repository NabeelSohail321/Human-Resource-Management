import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class UserModel with ChangeNotifier {
  User? _currentUser; // Holds the current user
  int? _role; // Role of the user (0: MD, 1: Employee, 2: Manager)

  User? get currentUser => _currentUser; // Getter for current user
  int? get role => _role; // Getter for user role

  // Method to set current user and role
  void setUser(User? user, int? role) {
    _currentUser = user;
    _role = role;
    notifyListeners(); // Notify listeners of changes
  }

  // Fetch user details from MD, Employee, and Manager nodes
  Future<void> fetchUserDetails(String uid) async {
    try {
      print("Fetching details for UID: $uid"); // Debug print

      // Create references to each node
      DatabaseReference mdRef = FirebaseDatabase.instance.ref('MD/$uid');
      DatabaseReference employeeRef = FirebaseDatabase.instance.ref('Employee/$uid');

      // Check MD node
      DataSnapshot mdSnapshot = await mdRef.get();
      if (mdSnapshot.exists) {
        print("User found in MD node"); // Debug print
        _role = 0; // Set role for MD
        _currentUser = FirebaseAuth.instance.currentUser; // Get current user
      } else {
        // Check Employee node
        DataSnapshot employeeSnapshot = await employeeRef.get();
        if (employeeSnapshot.exists) {
          print("User found in Employee node"); // Debug print
          _role = 1; // Set role for Employee
          _currentUser = FirebaseAuth.instance.currentUser; // Get current user
        } else {
          // Handle case where user data doesn't exist in any node
          _currentUser = null;
          _role = null;
          print("User not found in any node."); // Debug print
        }
      }

      notifyListeners(); // Notify listeners of changes
    } catch (e) {
      print("Error fetching user details: $e");
      _currentUser = null; // Reset user details on error
      _role = null;
      notifyListeners(); // Notify listeners of changes
    }
  }
}
