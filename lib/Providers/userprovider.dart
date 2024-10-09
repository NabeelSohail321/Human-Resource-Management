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
  String? _userRole; // Variable to hold the user role
  String? get userRole => _userRole; // Getter for user role



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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid;

      // If this is the first user, assign them as HR (role 0), otherwise assign them as Employee (role 1)
      String role = _isFirstUser ? "0" : "1";
      String node = _isFirstUser ? "MD" : "Employee";
      // Get the user's UID
      String uid = userCredential.user!.uid;
      // Save user information in the correct node
      await _dbRef.child(node).child(userId).set({
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "password": password,
        "uid": uid,
        "Date & Time": DateTime.now()
      });

      // If first user, mark it as HR created
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

  Future<void> fetchUserRole() async {
    if (_user == null) {
      throw Exception('User is not authenticated');
    }

    String uid = _user!.uid; // Get the user's UID

    try {
      // Fetch user data from the MD, Employee, and Manager nodes
      final hrSnapshot = await _dbRef.child('MD').child(uid).once();
      final employeeSnapshot = await _dbRef.child('Employee').child(uid).once();
      final managerSnapshot = await _dbRef.child('Manager').child(uid).once();

      // Reset user role before fetching
      _userRole = null;

      // Check if the user exists in the MD node
      if (hrSnapshot.snapshot.exists) {
        final hrData = hrSnapshot.snapshot.value as Map<dynamic, dynamic>?; // Cast to Map
        if (hrData != null && hrData['email'] == _user!.email) {
          _userRole = 'MD';
        }
      }

      // Check if the user exists in the Employee node
      if (employeeSnapshot.snapshot.exists) {
        final employeeData = employeeSnapshot.snapshot.value as Map<dynamic, dynamic>?; // Cast to Map
        if (employeeData != null && employeeData['email'] == _user!.email) {
          _userRole = 'Employee';
        }
      }

      // Check if the user exists in the Manager node
      if (managerSnapshot.snapshot.exists) {
        final managerData = managerSnapshot.snapshot.value as Map<dynamic, dynamic>?; // Cast to Map
        if (managerData != null && managerData['email'] == _user!.email) {
          _userRole = 'Manager';
        }
      }

      // Notify listeners of the change in user role
      notifyListeners();

      // If the user role is still null, throw an exception
      if (_userRole == null) {
        throw Exception('User does not exist in any role.');
      }

    } catch (e) {
      throw Exception('Failed to fetch user role: ${e.toString()}');
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
          'password':userData['password'] ?? '',
          'phone':userData['phone'] ?? '',
          'role': newRole,

        });

        fetchUsers(); // Refresh users
      }
    } catch (e) {
      print('Error updating user role: $e');
    }
  }
}