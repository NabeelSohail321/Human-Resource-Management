import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/managermodel.dart';

class resticatedUsersProvider with ChangeNotifier {
  List<Manager> _resticatedUsers = [];

  List<Manager> get resticatedUsers => _resticatedUsers;

  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref().child('Resticated'); // Reference to the resticateed node

  void fetchresticatedUsers() {
    _databaseReference.onValue.listen((event) {
      final resticatedData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (resticatedData != null) {
        _resticatedUsers = resticatedData.entries.map((entry) {
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
        _resticatedUsers = [];
      }

      notifyListeners();
    });
  }
}
