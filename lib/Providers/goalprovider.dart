import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../Models/goalmodels.dart';


class GoalProvider with ChangeNotifier {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  List<Goal> _managerGoals = [];
  List<Employee> _employeeList = [];

  List<Goal> get managerGoals => _managerGoals;
  List<Employee> get employeeList => _employeeList;

  Future<void> fetchManagerGoals(String managerId) async {
    _databaseRef.child('Managers/$managerId/assignedGoals').onValue.listen((event) {
      final data = event.snapshot.value as List<dynamic>;
      _managerGoals = data.map((goalId) => Goal(id: goalId, title: goalId)).toList();
      notifyListeners();
    });
  }

  Future<void> fetchEmployeeList(String managerId) async {
    _databaseRef.child('Managers/$managerId/Employees').onValue.listen((event) {
      final data = event.snapshot.value as List<dynamic>;
      _employeeList = data.map((employeeId) => Employee(id: employeeId, name: employeeId)).toList();
      notifyListeners();
    });
  }

  Future<void> assignGoalToEmployee(String employeeId, Goal goal) async {
    await _databaseRef.child('employees/$employeeId/assignedGoals').update({
      goal.id: goal.status,
    });
    notifyListeners();
  }
}
