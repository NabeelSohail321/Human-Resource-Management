import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart'; // Import SchedulerBinding
import '../Models/goalmodels.dart';

class GoalsProvider with ChangeNotifier {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.ref().child('Goals'); // Reference to the Goals node
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

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
}
