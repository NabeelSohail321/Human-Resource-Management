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
  bool _isLoggingIn = false;
  bool get isLoggingIn => _isLoggingIn;


  Future<int> _getHighestManagerNumber() async {
    int highestManagerNumber = 0;
    try {
      DataSnapshot managerSnapshot = await _managerRef.get();
      if (managerSnapshot.exists) {
        for (var manager in managerSnapshot.children) {
          Map<String, dynamic> managerData = Map<String, dynamic>.from(manager.value as Map);
          String? managerNumber = managerData['managerNumber'];
          if (managerNumber != null && managerNumber.startsWith('MGR-')) {
            int number = int.parse(managerNumber.split('-')[1]);
            if (number > highestManagerNumber) {
              highestManagerNumber = number;
            }
          }
        }
      }
    } catch (e) {
      print('Error retrieving highest manager number: $e');
    }
    return highestManagerNumber;
  }

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

      // If this is the first user, assign them as MD (role 0), otherwise assign them as Employee (role 1)
      String role = _isFirstUser ? "0" : "1";
      String node = _isFirstUser ? "MD" : "Employee";

      String uid = userCredential.user!.uid;

      // If the user is not the first user (i.e., they are an employee), generate an employee number
      String? employeeNumber;
      if (!_isFirstUser) {
        // Get the current number of employees and managers to generate the next employee number
        DataSnapshot employeeSnapshot = await _dbRef.child("Employee").get();
        DataSnapshot managerSnapshot = await _dbRef.child("Manager").get();

        // Find the highest existing employee number from both Employee and Manager nodes
        int highestEmployeeNumber = 0;
        for (var snapshot in [employeeSnapshot, managerSnapshot]) {
          if (snapshot.exists) {
            final data = Map<String, dynamic>.from(snapshot.value as Map);
            for (var user in data.values) {
              final userMap = Map<String, dynamic>.from(user);
              if (userMap['employeeNumber'] != null) {
                final numberString = (userMap['employeeNumber'] as String).split('-').last;
                final number = int.tryParse(numberString) ?? 0;
                if (number > highestEmployeeNumber) {
                  highestEmployeeNumber = number;
                }
              }
            }
          }
        }
        employeeNumber = 'EMP-${highestEmployeeNumber + 1}'; // Generate a new unique employee number
      }

      // Save user information in the correct node with employee number if applicable
      await _dbRef.child(node).child(userId).set({
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "password": password,
        "uid": uid,
        "employeeNumber": employeeNumber, // Add employee number if applicable
        "Registration Date": DateTime.now().toString(),
      });

      // If the first user is registered, mark the first user flag as false
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

      // Remove the user from their current role node and retrieve their data
      if (employeeSnapshot.exists) {
        userData = Map<String, dynamic>.from(employeeSnapshot.value as Map);
        await _employeeRef.child(uid).remove(); // Remove from Employee node
      } else if (hrSnapshot.exists) {
        userData = Map<String, dynamic>.from(hrSnapshot.value as Map);
        await _mdRef.child(uid).remove(); // Remove from MD node
      } else if (managerSnapshot.exists) {
        userData = Map<String, dynamic>.from(managerSnapshot.value as Map);
        await _managerRef.child(uid).remove(); // Remove from Manager node
      }

      if (userData != null) {
        // Determine the new node for the user based on the new role
        DatabaseReference newRef;
        String? employeeNumber = userData['employeeNumber']; // Preserve the employee number if present
        String? managerNumber; // Manager number for managers
        String roleChangeDate = DateTime.now().toString(); // Get the current date and time for the role change

        // Handle different roles
        if (newRole == '0') { // MD role
          newRef = _mdRef;
          employeeNumber = null; // Remove employee number for MD role
          managerNumber = null; // Remove manager number for MD role
        } else if (newRole == '1') { // Employee role
          newRef = _employeeRef;
          managerNumber = null; // Remove manager number for Employee role

          // Generate a new employee number if it doesn't exist
          if (employeeNumber == null) {
            int highestEmployeeNumber = await _getHighestEmployeeNumber();
            employeeNumber = 'EMP-${highestEmployeeNumber + 1}'; // Generate a new unique employee number
            print('Generated new employee number: $employeeNumber');
          }
        } else if (newRole == '2') { // Manager role
          newRef = _managerRef;
          employeeNumber = null; // Remove employee number for Manager role

          // Generate a manager number if the user is transitioning to a manager role
          int highestManagerNumber = await _getHighestManagerNumber();
          managerNumber = 'MGR-${highestManagerNumber + 1}'; // Generate a new unique manager number
          print('Generated new manager number: $managerNumber');
        } else {
          return; // Invalid role, do nothing
        }

        // Save the user data to the new role node, preserving relevant fields and adding the role change date
        await newRef.child(uid).set({
          'uid': uid,
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
          'password': userData['password'] ?? '',
          'phone': userData['phone'] ?? '',
          'role': newRole,
          'employeeNumber': employeeNumber, // Add or retain employee number as necessary
          'managerNumber': managerNumber, // Add manager number for Manager role
          'Registration Date': userData['Registration Date'] ?? '',
          'Role Change Date': roleChangeDate, // Add the role change date
        });

        print('User role updated successfully with manager number: $managerNumber');

        fetchUsers(); // Refresh the list of users after the update
      }
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<int> _getHighestEmployeeNumber() async {
    int highestEmployeeNumber = 0;
    try {
      DataSnapshot employeeSnapshot = await _employeeRef.get();
      if (employeeSnapshot.exists) {
        for (var employee in employeeSnapshot.children) {
          Map<String, dynamic> employeeData = Map<String, dynamic>.from(employee.value as Map);
          String? employeeNumber = employeeData['employeeNumber'];
          if (employeeNumber != null && employeeNumber.startsWith('EMP-')) {
            int number = int.parse(employeeNumber.split('-')[1]);
            if (number > highestEmployeeNumber) {
              highestEmployeeNumber = number;
            }
          }
        }
      }
    } catch (e) {
      print('Error retrieving highest employee number: $e');
    }
    return highestEmployeeNumber;
  }

  Future<String?> loginUser(String email, String password) async {
    _isLoggingIn = true;
    notifyListeners(); // Notify listeners about the loading state

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      _user = userCredential.user;

      // After successful login, check user roles
      String? role = await checkUserRole();
      return role; // Return the role if found
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } finally {
      _isLoggingIn = false;
      notifyListeners(); // Notify listeners about the loading state
    }
  }


  Future<String?> checkUserRole() async {
    if (_user == null) {
      return null; // User not logged in
    }

    // Define references for all roles
    DatabaseReference employeeRef = _dbRef.child("Employee");
    DatabaseReference mdRef = _dbRef.child("MD");
    DatabaseReference managerRef = _dbRef.child("Manager");

    // Check if the user exists in Employee node
    DatabaseEvent employeeEvent = await employeeRef.orderByChild('email').equalTo(_user!.email).once();
    DataSnapshot employeeSnapshot = employeeEvent.snapshot;
    print('Employee Snapshot: ${employeeSnapshot.value}');
    if (employeeSnapshot.exists) {
      return "Employee"; // User is an Employee
    }

    // Check if the user exists in MD node
    DatabaseEvent mdEvent = await mdRef.orderByChild('email').equalTo(_user!.email).once();
    DataSnapshot mdSnapshot = mdEvent.snapshot;
    print('MD Snapshot: ${mdSnapshot.value}');
    if (mdSnapshot.exists) {
      return "MD"; // User is an MD
    }

    // Check if the user exists in Manager node
    // DatabaseEvent managerEvent = await managerRef.orderByChild('email').equalTo(_user!.email).once();
    DatabaseEvent managerEvent = await managerRef.orderByChild('email').equalTo(_user!.email!.toLowerCase()).once();

    DataSnapshot managerSnapshot = managerEvent.snapshot;
    print('Manager Snapshot: ${managerSnapshot.value}');
    if (managerSnapshot.exists) {
      return "Manager"; // User is a Manager
    }

    return null; // User role not found
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;  // Set loading state to true
    _users.clear();     // Clear the existing users list
    notifyListeners();  // Notify listeners to update the UI

    try {
      // Fetching employees from the Employee node
      final employeeSnapshot = await _employeeRef.once();

      if (employeeSnapshot.snapshot.value != null) {
        final employeesData = Map<String, dynamic>.from(employeeSnapshot.snapshot.value as Map);

        // Add each employee's data to the _users list
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
    } catch (e) {
      print("Error fetching employees: $e");
    } finally {
      _isLoading = false;  // Set loading state to false
      notifyListeners();    // Notify listeners to update the UI
    }
  }

  Future<void> toggleUserActiveStatus(String uid, bool isActive) async {
    try {
      // Determine the current user's node (MD, Employee, or Manager)
      DataSnapshot employeeSnapshot = await _employeeRef.child(uid).get();
      DataSnapshot mdSnapshot = await _mdRef.child(uid).get();
      DataSnapshot managerSnapshot = await _managerRef.child(uid).get();

      if (employeeSnapshot.exists) {
        // User is an employee, update their active status
        await _employeeRef.child(uid).update({
          'isActive': !isActive, // Toggle active status
        });
      } else if (mdSnapshot.exists) {
        // User is MD, update their active status
        await _mdRef.child(uid).update({
          'isActive': !isActive,
        });
      } else if (managerSnapshot.exists) {
        // User is a manager, update their active status
        await _managerRef.child(uid).update({
          'isActive': !isActive,
        });
      } else {
        throw Exception("User not found");
      }

      // Refresh users list after updating
      await fetchUsers(); // You may want to refresh the users list after toggling status
    } catch (e) {
      print("Error toggling user active status: $e");
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Check each node to find the user and delete them
      DataSnapshot employeeSnapshot = await _employeeRef.child(uid).get();
      DataSnapshot mdSnapshot = await _mdRef.child(uid).get();
      DataSnapshot managerSnapshot = await _managerRef.child(uid).get();

      if (employeeSnapshot.exists) {
        // User is an employee, delete them
        await _employeeRef.child(uid).remove();
      } else if (mdSnapshot.exists) {
        // User is MD, delete them
        await _mdRef.child(uid).remove();
      } else if (managerSnapshot.exists) {
        // User is a manager, delete them
        await _managerRef.child(uid).remove();
      } else {
        throw Exception("User not found");
      }

      // Optionally, refresh users list after deletion
      await fetchUsers(); // Refresh users list after deletion
    } catch (e) {
      print("Error deleting user: $e");
    }
  }

  Future<void> addDepartment(String departmentName) async {
    try {
      // Assuming you have a database reference to add a new department
      final newDepartmentRef = _dbRef.child('departments').push();
      await newDepartmentRef.set({'name': departmentName});
      notifyListeners(); // Notify listeners about the change
    } catch (error) {
      print('Error adding department: $error');
    }
  }

  Future<void> updateUserDepartment(String userId, String department) async {
    try {
      // Assuming you have a database reference to update the department
      await _dbRef.child('users/$userId').update({'department': department});
      notifyListeners(); // Notify listeners about the change
    } catch (error) {
      print('Error updating department: $error');
    }
  }


}