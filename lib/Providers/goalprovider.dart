import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart'; // Import SchedulerBinding
import '../Models/goalmodels.dart';

class GoalsProvider with ChangeNotifier {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref().child('Goals'); // Reference to the Goals node
  List<Goal> _goals = [];
  List<Goal> get goals => _goals;
  String? currentManagerId; // Change to nullable
  int get totalGoalsCount => _goals.length;

  Future<void> addGoal(Goal newGoal) async {
    final DatabaseReference goalsRef = FirebaseDatabase.instance.ref().child('Goals');

    try {
      // Generate a unique key using push()
      final newGoalRef = goalsRef.push(); // This generates a unique ID for the new goal
      newGoal.id = newGoalRef.key!; // Set the generated ID to the goal's id property

      // Save the goal using the generated ID
      await newGoalRef.set(newGoal.toJson());
      notifyListeners(); // Notify listeners that the state has changed
    } catch (e) {
      throw Exception('Failed to add goal: $e');
    }
  }

  void fetchGoals() async {
    try {
      // Clear previous goals
      _goals.clear();
      // Listen for changes in the Goals node
      _databaseReference.onValue.listen((event) {
        final goalsData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (goalsData != null) {
          _goals = goalsData.entries.map((entry) {
            final goalData = entry.value as Map<dynamic, dynamic>;
            return Goal.fromJson(goalData, entry.key);
          }).toList();

          // Use SchedulerBinding to notify listeners after the current frame
          SchedulerBinding.instance.addPostFrameCallback((_) {
            notifyListeners(); // Notify listeners when goals are fetched
          });
        }
      });
    } catch (e) {
      print('Error fetching goals: $e');
    }
  }


  // Method to fetch the current user's manager ID
  Future<void> fetchCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user

    if (user != null) {
      // Here you would normally fetch user details from your database
      currentManagerId = user.uid; // Example: Replace this with your logic to fetch managerId

      // Log the fetched current manager ID
      print("Current Manager ID: $currentManagerId");
    } else {
      // Handle the case where the user is not logged in
      currentManagerId = null;
      print("No user is logged in.");
    }
  }

  Future<void> fetchGoalsbymanager() async {
    if (currentManagerId == null) return; // Do not proceed if no manager ID is available

    print("Fetching goals for manager ID: $currentManagerId"); // Debug log

    _databaseReference
        .orderByChild("managerId")
        .equalTo(currentManagerId)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _goals = data.entries.map((entry) {
          return Goal.fromJson(entry.value as Map<dynamic, dynamic>, entry.key);
        }).toList();
        print("Goals fetched: ${_goals.length}"); // Log number of goals fetched
      } else {
        _goals = []; // No goals found
        print("No goals found for the current manager ID.");
      }
      notifyListeners();
    });
  }

  Future<void> initialize() async {
    await fetchCurrentUserId(); // Fetch the current user's manager ID
    await fetchGoalsbymanager(); // Then fetch goals
  }

  Future<void> assignGoalToEmployee(Goal goal, String employeeUid) async {
    try {
      // Update the goal in the database with the selected employee's UID
      await _databaseReference.child(goal.id).update({
        'assignedEmployeeId': employeeUid, // Add a field to hold the assigned employee's UID
      });
      notifyListeners(); // Notify listeners that the goal has been updated
    } catch (e) {
      print('Failed to assign goal to employee: $e');
    }
  }

}