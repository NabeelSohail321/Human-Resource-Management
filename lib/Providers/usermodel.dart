import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class UserModel with ChangeNotifier {
  User? _currentUser;
  int? _role; // 0: MD, 1: Employee, 2: Manager
  String? _name;
  String? _email;
  bool _isLoading = false; // Loading state

  User? get currentUser => _currentUser;
  int? get role => _role;
  String? get name => _name;
  String? get email => _email;
  bool get isLoading => _isLoading; // Getter for loading state

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch user details based on UID
  Future<void> fetchUserDetails(String uid) async {
    _isLoading = true; // Set loading to true
    notifyListeners(); // Notify listeners about loading state

    try {
      // Fetch current user data
      _currentUser = FirebaseAuth.instance.currentUser;

      if (_currentUser != null) {
        _email = _currentUser!.email;

        // Check which node the user belongs to (MD, Employee, Manager)
        await _checkUserRole();
      }
    } catch (e) {
      print('Error fetching user details: $e');
    } finally {
      _isLoading = false; // Set loading to false
      notifyListeners(); // Notify listeners about loading state
    }
  }

  // Function to check the user role by email
  Future<void> _checkUserRole() async {
    String email = _currentUser!.email!;

    // Check if user is in the MD node
    final DatabaseEvent mdEvent = await _dbRef.child('MD').orderByChild('email').equalTo(email).once();
    if (mdEvent.snapshot.exists) {
      _role = 0; // MD
      _name = _getNameFromSnapshot(mdEvent.snapshot); // Extract name from snapshot
      notifyListeners();
      return;
    }

    // Check if user is in the Employee node
    final DatabaseEvent employeeEvent = await _dbRef.child('Employee').orderByChild('email').equalTo(email).once();
    if (employeeEvent.snapshot.exists) {
      _role = 1; // Employee
      _name = _getNameFromSnapshot(employeeEvent.snapshot); // Extract name from snapshot
      notifyListeners();
      return;
    }

    // Check if user is in the Manager node
    final DatabaseEvent managerEvent = await _dbRef.child('Manager').orderByChild('email').equalTo(email).once();
    if (managerEvent.snapshot.exists) {
      _role = 2; // Manager
      _name = _getNameFromSnapshot(managerEvent.snapshot); // Extract name from snapshot
      notifyListeners();
      return;
    }

    _role = null; // No role found
  }

  // Helper function to extract 'name' from the snapshot
  String? _getNameFromSnapshot(DataSnapshot snapshot) {
    if (snapshot.value != null) {
      // Extract the list or map from the snapshot
      Map<dynamic, dynamic> userData = snapshot.value as Map<dynamic, dynamic>;

      // If the snapshot contains multiple records, iterate over them
      if (userData.isNotEmpty) {
        var firstKey = userData.keys.first; // Get the first key (if only one record is expected)
        Map<dynamic, dynamic> userRecord = userData[firstKey] as Map<dynamic, dynamic>;

        // Return the name if it exists in the record
        return userRecord['name'] ?? "Name not available";
      }
    }
    return null;
  }





}
