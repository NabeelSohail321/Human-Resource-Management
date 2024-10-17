
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/managermodel.dart';

class ManagersProvider with ChangeNotifier {
  List<Manager> _managers = [];
  Manager? _currentManager;
  Manager? get currentManager => _currentManager; // Getter for current manager
  List<Manager> get managers => _managers;


  Map<String, dynamic>? _managerData;

  Map<String, dynamic>? get managerData => _managerData;

  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref().child('Manager'); // Reference to the Manager node

  ManagersProvider() {
    fetchManagers(); // Fetch managers when the provider is created
  }

  Future<void> fetchManagers() async {
    try {
      final snapshot = await _databaseReference.once();

      if (snapshot.snapshot.exists) {
        final managersData = snapshot.snapshot.value as Map<dynamic, dynamic>;

        _managers = managersData.entries.map((entry) {
          final managerData = entry.value as Map<dynamic, dynamic>;
          return Manager(
            uid: entry.key,
            name: managerData['name'] ?? '',
            email: managerData['email'] ?? '',
            phone: managerData['phone'] ?? '',
            departmentName: managerData['departmentName'] ?? '',
            managerNumber: managerData['managerNumber'] ?? '',
            role: managerData['role'] ?? '',
            status: managerData['user status'] ?? '',
            workLocation: managerData['workLocation'], // Fetch workLocation from the database

          );
        }).toList();
      } else {
        _managers = []; // Ensure the list is empty if no data is available
      }

      notifyListeners(); // Notify listeners after processing the data
    } catch (e) {
      print('Error fetching managers: $e');
    }
  }

  Future<void> fetchCurrentManagerByUid(String uid) async {
    // Ensure the manager list is loaded before trying to find the current manager
    _currentManager = _managers.firstWhere(
          (manager) => manager.uid == uid,
      orElse: () => Manager(
        uid: '',
        name: '',
        email: '',
        phone: '',
        departmentName: '',
        managerNumber: '',
        role: '',
        status: '',
      ),
    );

    // Notify listeners even if the current manager is empty
    notifyListeners();
  }

  void restrictManager(Manager manager) async {
    try {
      // Remove the manager from the Manager node
      await _databaseReference.child(manager.uid).remove();

      // Add the manager to the Restricted node
      await FirebaseDatabase.instance
          .ref()
          .child('Restricted')
          .child(manager.uid)
          .set({
        'uid': manager.uid,
        'name': manager.name,
        'email': manager.email,
        'phone': manager.phone,
        'departmentName': manager.departmentName,
        'managerNumber': manager.managerNumber,
        'role': manager.role,
        'user status': 'Restricted',
      });

      _managers.remove(manager);
      notifyListeners(); // Notify listeners after updating the managers list
    } catch (e) {
      print('Error restricting manager: $e');
    }
  }

  Future<void> fetchmanagerProfile(String uid) async {
    try {
      final snapshot = await _databaseReference.child(uid).get();
      if (snapshot.exists) {
        _managerData = Map<String, dynamic>.from(snapshot.value as Map);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching employee profile: $e');
    }
  }


  Future<void> updateManagerProfile(String uid, Map<String, dynamic> updatedData) async {
    try {
      await _databaseReference.child(uid).update(updatedData);
      _managerData = updatedData;
      notifyListeners();
    } catch (e) {
      print('Error updating manager profile: $e');
    }
  }



}

