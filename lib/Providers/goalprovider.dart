// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// import '../Models/goalmodels.dart';
//
// class GoalsProvider with ChangeNotifier {
//   Future<void> addGoal(Goal newGoal) async {
//     final DatabaseReference goalsRef = FirebaseDatabase.instance.ref().child('Goals');
//
//     try {
//       await goalsRef.child(newGoal.id).set(newGoal.toJson());
//       notifyListeners(); // Notify listeners that the state has changed
//     } catch (e) {
//       throw Exception('Failed to add goal: $e');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../Models/goalmodels.dart';
class GoalsProvider with ChangeNotifier {
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
}
