import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  User? _user;
  User? get user => _user;
  bool _isFirstUser = true;
  bool get isFirstUser => _isFirstUser;
  List<Map<String, dynamic>> get users => _users;
  bool get isLoading => _isLoading;
  final DatabaseReference _employeeRef = FirebaseDatabase.instance.ref("Employee");
  final DatabaseReference _mdRef = FirebaseDatabase.instance.ref("MD");
  final DatabaseReference _managerRef = FirebaseDatabase.instance.ref("Manager");
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;


  Future<void> checkFirstUser() async {
    final hrSnapshot = await _dbRef.child("MD").once();
    _isFirstUser = hrSnapshot.snapshot.value == null;
    notifyListeners();
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Register user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      String userId = userCredential.user!.uid;

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      String role = _isFirstUser ? "0" : "1";
      String node = _isFirstUser ? "MD" : "Employee";

      // Get the user's UID
      String uid = userCredential.user!.uid;
      // Save user information in the correct node in Firebase Database
      await _dbRef.child(node).child(userId).set({
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "password": password,
        "uid": uid,
      });

      if (_isFirstUser) {
        _isFirstUser = false;
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception("Error registering user: ${e.message}");
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;

    // Reload the user to check the latest verification status
    await user?.reload();
    user = _auth.currentUser;

    return user?.emailVerified ?? false;
  }

  Future<void> login(String email, String password) async {
    try {
      // First, sign in the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Check credentials in HR, Employee, and Manager nodes
      final hrSnapshot = await _dbRef.child('MD').orderByChild('email').equalTo(email).once();
      final employeeSnapshot = await _dbRef.child('Employee').orderByChild('email').equalTo(email).once();
      final managerSnapshot = await _dbRef.child('Manager').orderByChild('email').equalTo(email).once();

      // Verify if the user exists in any of the nodes
      if (hrSnapshot.snapshot.exists || employeeSnapshot.snapshot.exists || managerSnapshot.snapshot.exists) {
        // User exists in at least one node
        notifyListeners();
      } else {
        // User does not exist in any node
        throw Exception('User does not exist in any role.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      throw e; // Re-throwing for handling in the UI
    } catch (e) {
      // Handle other errors
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut(); // Sign out the user from Firebase
      _user = null; // Clear the user variable
      notifyListeners(); // Notify listeners about the change
    } catch (e) {
      throw Exception("Error logging out: ${e.toString()}"); // Handle any errors
    }
  }

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
