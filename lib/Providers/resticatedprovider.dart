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
}
