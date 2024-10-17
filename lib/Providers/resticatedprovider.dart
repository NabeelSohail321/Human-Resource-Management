import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';

import '../Models/managermodel.dart';

class RestrictedUsersProvider with ChangeNotifier {
  List<Manager> _restrictedUsers = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<Manager> get restrictedUsers => _restrictedUsers;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading; // Loading state property

  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref().child('Restricted'); // Reference to the restricted node

  void fetchRestrictedUsers() {
    _isLoading = true; // Set loading to true
    notifyListeners();

    _databaseReference.onValue.listen((event) {
      _isLoading = false; // Reset loading when the data is fetched
      _errorMessage = null; // Reset error message
      final restrictedData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (restrictedData != null) {
        _restrictedUsers = restrictedData.entries.map((entry) {
          final userData = entry.value as Map<dynamic, dynamic>;
          return Manager(
            uid: entry.key,
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            phone: userData['phone'] ?? '',
            departmentName: userData['departmentName'] ?? '',
            managerNumber: userData['managerNumber'] ?? '',
            role: userData['role'] ?? '',
            status: userData['user status'] ?? '',
          );
        }).toList();
      } else {
        _restrictedUsers = [];
      }

      notifyListeners();
    }, onError: (error) {
      _isLoading = false; // Reset loading state on error
      _errorMessage = 'Failed to fetch restricted users: ${error.toString()}';
      notifyListeners();
    });
  }

  Future<void> moveUserBack(String userId) async {
    try {
      // Retrieve the user data from the RestrictedUsers node
      DataSnapshot snapshot = await _databaseReference.child(userId).get();

      if (snapshot.exists) {
        // Get the user data
        final userData = snapshot.value as Map<dynamic, dynamic>;

        // Move the user back to the Managers node with updated status
        await _databaseReference.child(userId).remove(); // Remove from RestrictedUsers
        await FirebaseDatabase.instance.ref().child('Manager').child(userId).set({
          ...userData, // Spread the existing user data
          'user status': 'Active', // Set the status to Active
        });
      }

      // Refresh the restricted users
      fetchRestrictedUsers();
    } catch (error) {
      // Handle errors accordingly
      _errorMessage = 'Failed to move user back: ${error.toString()}';
      notifyListeners();
    }
  }


}
