import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  User? _user;
  User? get user => _user;
  final bool _isFirstUser = true;
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
  Map<String, String> departments = {};
  List<Map<String, dynamic>>_departments = [];
  List<Map<String, dynamic>> get depart => _departments;



  Future<void> fetchtotalDepartments() async {
    try {
      final DatabaseEvent event = await _dbRef.child('departments').once();
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> departmentsData = event.snapshot.value as Map<dynamic, dynamic>;
        _departments = departmentsData.entries.map((entry) {
          return {
            'departId': entry.key,
            'departName': entry.value['departName'],
          };
        }).toList();
        notifyListeners(); // Notify listeners that data has changed
      }
    } catch (error) {
      print('Error fetching departments: $error');
    }
  }

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

  Future<void> registerUser(String name, String email, String phone, String password) async {
    try {
      // Create a new user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // User's UID
      String uid = userCredential.user!.uid;

      // Check if there are any registered users in the MD node
      DatabaseEvent event = await _dbRef.child('MD').once();
      bool isFirstUser = event.snapshot.children.isEmpty; // Check if the MD node is empty

      // Prepare user data
      Map<String, dynamic> userData = {
        'name': name.trim(),
        'email': email.trim(),
        'phone': phone.trim(),
        'password': password.trim(),
        'uid': uid,
        'user status': "Active",
        'Registration Date': DateTime.now().toString(),
        'role': isFirstUser ? 0 : 1, // Role for MD is 0, for Employee is 1
      };

      if (isFirstUser) {
        // Add the first user to the MD node
        await _dbRef.child('MD').child(uid).set(userData);
      } else {
        // Add all subsequent users to the Employees node
        int employeeNumber = (await _dbRef.child('Employee').once()).snapshot.children.length + 1; // Generate employee number
        // userData['employeeNumber'] = employeeNumber;
        userData['employeeNumber'] = "EMP- ${employeeNumber}";

        // Add subsequent users to the Employees node
        await _dbRef.child('Employee').child(uid).set(userData);
      }

      // Clear text fields after registration
      // Optional: notifyListeners() can be called if you have UI to update
    } on FirebaseAuthException catch (e) {
      throw e; // Rethrow the error to handle it in the UI
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
          // Check user status before adding to _users
          if (map['user status'] == 'Active') {
            return {
              'uid': map['uid'] ?? '',
              'name': map['name'] ?? 'Unknown',
              'email': map['email'] ?? 'No Email',
              'departmentName': map['departmentName'] ?? 'Unknown',
              'role': '1', // Role 1 for Employee
              'user status': map['user status'] ?? 'No Status', // Ensure you add this line

            };
          }
          return null; // return null if not active
        }).whereType<Map<String, dynamic>>()); // Only keep non-null maps
      }

      // Fetching HR (MD)
      final hrSnapshot = await _mdRef.once();
      if (hrSnapshot.snapshot.value != null) {
        final hrData = Map<String, dynamic>.from(hrSnapshot.snapshot.value as Map);
        _users.addAll(hrData.values.map((user) {
          final map = Map<String, dynamic>.from(user);
          // Check user status before adding to _users
          if (map['user status'] == 'Active') {
            return {
              'uid': map['uid'] ?? '',
              'name': map['name'] ?? 'Unknown',
              'email': map['email'] ?? 'No Email',
              'departmentName': map['departmentName'] ?? 'Unknown',
              'role': '0', // Role 0 for MD
              'user status': map['user status'] ?? 'No Status', // Ensure you add this line

            };
          }
          return null; // return null if not active
        }).whereType<Map<String, dynamic>>()); // Only keep non-null maps
      }

      // Fetching Managers
      final managerSnapshot = await _managerRef.once();
      if (managerSnapshot.snapshot.value != null) {
        final managerData = Map<String, dynamic>.from(managerSnapshot.snapshot.value as Map);
        _users.addAll(managerData.values.map((user) {
          final map = Map<String, dynamic>.from(user);
          // Check user status before adding to _users
          if (map['user status'] == 'Active') {
            return {
              'uid': map['uid'] ?? '',
              'name': map['name'] ?? 'Unknown',
              'email': map['email'] ?? 'No Email',
              'departmentName': map['departmentName'] ?? 'Unknown',
              'role': '2', // Role 2 for Manager
              'user status': map['user status'] ?? 'No Status', // Ensure you add this line

            };
          }
          return null; // return null if not active
        }).whereType<Map<String, dynamic>>()); // Only keep non-null maps
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

  Future<void> updateUserRole(String uid, String newRole, BuildContext context) async {
    try {
      // Check which node the user is currently in
      DataSnapshot employeeSnapshot = await _employeeRef.child(uid).get();
      DataSnapshot hrSnapshot = await _mdRef.child(uid).get();
      DataSnapshot managerSnapshot = await _managerRef.child(uid).get();
      Map<String, dynamic>? userData;

      // Retrieve the user data without removing them yet
      if (employeeSnapshot.exists) {
        userData = Map<String, dynamic>.from(employeeSnapshot.value as Map);
      } else if (hrSnapshot.exists) {
        userData = Map<String, dynamic>.from(hrSnapshot.value as Map);
      } else if (managerSnapshot.exists) {
        userData = Map<String, dynamic>.from(managerSnapshot.value as Map);
      }

      if (userData != null) {
        // Determine the new node for the user based on the new role
        DatabaseReference newRef;
        String? employeeNumber = userData['employeeNumber'];
        String? managerNumber;
        String roleChangeDate = DateTime.now().toString();
        String departmentName = userData['departmentName'] ?? '';

        // If new role is Manager (role = '2'), ensure no other manager exists in the department
        if (newRole == '2') {
          Query departmentManagerQuery = _managerRef
              .orderByChild('departmentName')
              .equalTo(departmentName);
          DataSnapshot departmentManagersSnapshot = await departmentManagerQuery.get();

          if (departmentManagersSnapshot.exists) {
            // If the department already has a manager, stop the role update
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: Department $departmentName already has a manager.')));
            return; // Prevent multiple managers for the same department
          }

          newRef = _managerRef;
          employeeNumber = null;

          // Generate a manager number if the user is transitioning to a manager role
          int highestManagerNumber = await _getHighestManagerNumber();
          managerNumber = 'MGR-${highestManagerNumber + 1}';
          print('Generated new manager number: $managerNumber');
        } else if (newRole == '1') { // Employee role
          newRef = _employeeRef;
          managerNumber = null;

          // Generate a new employee number if it doesn't exist
          if (employeeNumber == null) {
            int highestEmployeeNumber = await _getHighestEmployeeNumber();
            employeeNumber = 'EMP-${highestEmployeeNumber + 1}';
            print('Generated new employee number: $employeeNumber');
          }
        } else if (newRole == '0') { // MD role
          newRef = _mdRef;
          employeeNumber = null;
          managerNumber = null;
        } else {
          return; // Invalid role, do nothing
        }

        // Remove the user from their current role node if transitioning to a new role
        if (employeeSnapshot.exists) {
          await _employeeRef.child(uid).remove();
        } else if (hrSnapshot.exists) {
          await _mdRef.child(uid).remove();
        } else if (managerSnapshot.exists) {
          await _managerRef.child(uid).remove();
        }

        // Save the user data to the new role node, preserving relevant fields and adding the role change date
        await newRef.child(uid).set({
          'uid': uid,
          'name': userData['name'] ?? '',
          'email': userData['email'] ?? '',
          'password': userData['password'] ?? '',
          'phone': userData['phone'] ?? '',
          'role': newRole,
          'departmentName': userData['departmentName'] ?? '',
          'user status': userData['user status'],
          'employeeNumber': employeeNumber,
          'managerNumber': managerNumber,
          'Registration Date': userData['Registration Date'] ?? '',
          'Role Change Date': roleChangeDate,
        });

        print('User role updated successfully with manager number: $managerNumber');
        fetchUsers(); // Refresh the list of users after the update
      }
    } catch (e) {
      print('Error updating user role: $e');
    }
  }

  Future<String?> fetchRole() async {
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

      // Return the user role
      return _userRole; // Return the user's role if found
    } catch (e) {
      throw Exception('Failed to fetch user role: ${e.toString()}');
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
    _isLoggingIn = true; // Set loading state
    notifyListeners(); // Notify listeners about the loading state

    try {
      // Authenticate the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // Get the user's UID
      _user = userCredential.user;

      // Check user role
      String? role = await checkUserRole(_user!.uid);
      return role; // Return the user's role if found
    } on FirebaseAuthException catch (e) {
      throw Exception('Login failed: ${e.message}');
    } finally {
      _isLoggingIn = false; // Reset loading state
      notifyListeners(); // Notify listeners about the loading state
    }
  }

  Future<String?> checkUserRole(String uid) async {
    // Define references for all roles
    DatabaseReference employeeRef = _dbRef.child("Employee");
    DatabaseReference mdRef = _dbRef.child("MD");

    // Check if the user exists in the Employee node
    DatabaseEvent employeeEvent = await employeeRef.child(uid).once();
    if (employeeEvent.snapshot.exists) {
      // User is an Employee
      return "1"; //Employee
    }

    // Check if the user exists in the MD node
    DatabaseEvent mdEvent = await mdRef.child(uid).once();
    if (mdEvent.snapshot.exists) {
      // User is an MD
      return "0"; //MD
    }

    // If you have a Manager node, check it here
    DatabaseReference managerRef = _dbRef.child("Manager");
    DatabaseEvent managerEvent = await managerRef.child(uid).once();
    if (managerEvent.snapshot.exists) {
      // User is a Manager
      return "2"; // Adjust as necessary Manager role
    }

    // User role not found
    return null;
  }

  Future<bool> addDepartment(String departmentName) async {
    try {
      // Check if the department name already exists
      final DatabaseEvent existingDepartmentsEvent = await _dbRef.child('departments').once();
      final DataSnapshot existingDepartmentsSnapshot = existingDepartmentsEvent.snapshot;
      final Map<dynamic, dynamic>? existingDepartments = existingDepartmentsSnapshot.value as Map<dynamic, dynamic>?;

      bool departmentExists = false;

      // Convert the input department name to lowercase
      String lowerCaseDepartmentName = departmentName.toLowerCase();

      // Check if any existing department matches the new department name (case-insensitive)
      if (existingDepartments != null) {
        existingDepartments.forEach((key, value) {
          if (value['departName'].toLowerCase() == lowerCaseDepartmentName) {
            departmentExists = true;
          }
        });
      }

      if (departmentExists) {
        print('Department "$departmentName" already exists.'); // Optionally log this
        return false; // Return false if the department already exists
      }

      // Add the new department if it doesn't already exist
      final newDepartmentRef = _dbRef.child('departments').push();
      final departmentId = newDepartmentRef.key; // Get the unique ID generated by Firebase

      await newDepartmentRef.set({
        'departId': departmentId, // Add the departId to the node
        'departName': departmentName,
      });

      notifyListeners(); // Notify listeners about the change
      return true; // Return true if the department was added successfully
    } catch (error) {
      print('Error adding department: $error');
      return false; // Optionally return false in case of an error
    }
  }

  Future<void> fetchDepartments() async {
    // Example Firebase logic (adjust based on your database):
    final departmentData = await FirebaseDatabase.instance.ref('departments').get();

    // Clear existing departments
    departments.clear();

    if (departmentData.exists) {
      // Explicitly cast the fetched value to a Map<dynamic, dynamic>
      Map<dynamic, dynamic> departmentMap = departmentData.value as Map<dynamic, dynamic>;

      departmentMap.forEach((key, value) {
        // Ensure that the value is a Map and has the 'name' field before assigning
        if (value is Map && value.containsKey('departName')) {
          departments[key] = value['departName'];
        }
      });
    }

    notifyListeners();
  }

  Future<void> updateUserDepartment(String uid, String newDepartmentName, BuildContext context) async {
    try {
      // Check which node the user is currently in
      DataSnapshot employeeSnapshot = await _employeeRef.child(uid).get();
      DataSnapshot hrSnapshot = await _mdRef.child(uid).get();
      DataSnapshot managerSnapshot = await _managerRef.child(uid).get();
      Map<String, dynamic>? userData;
      DatabaseReference currentUserRef;

      // Identify the user's current node and retrieve their data
      if (employeeSnapshot.exists) {
        userData = Map<String, dynamic>.from(employeeSnapshot.value as Map);
        currentUserRef = _employeeRef.child(uid);
      } else if (hrSnapshot.exists) {
        userData = Map<String, dynamic>.from(hrSnapshot.value as Map);
        currentUserRef = _mdRef.child(uid);
      } else if (managerSnapshot.exists) {
        userData = Map<String, dynamic>.from(managerSnapshot.value as Map);
        currentUserRef = _managerRef.child(uid);
      } else {
        print('User not found in any node.');
        return; // Exit if the user is not found in any node
      }

      // Update the user's department within their current node
      if (userData != null) {

        final department = userData['departmentName'];

        final role = userData['role'].toString();

        if(role == '2'){
          final snapshot = await _managerRef.orderByChild('departmentName').equalTo(department).get();
          if(snapshot.exists){
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Manager Already Exist for that department $department')));
            return;
          }
        }

        // Add or update the department field in the user's data
        await currentUserRef.update({
          'departmentName': newDepartmentName, // Use the department name
        });

        print('User department updated successfully to $newDepartmentName.');

        fetchUsers(); // Refresh the list of users after the update
      }
    } catch (e) {
      print('Error updating user department: $e');
    }
  }

  Future<void> deleteDepartment(String departmentId) async {
    try {
      // Delete the department from the database using its ID
      await _dbRef.child('departments').child(departmentId).remove();
      // Remove the department from the local list
      _departments.removeWhere((department) => department['departId'] == departmentId);
      notifyListeners(); // Notify listeners about the change
    } catch (error) {
      print('Error deleting department: $error');
      // Optionally, you can handle errors here (e.g., show a Snackbar)
    }
  }


}