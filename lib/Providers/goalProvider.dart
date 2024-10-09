import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseReference _db = FirebaseDatabase.instance.ref().child('goals');

  List<Map<String, dynamic>> _goals = [];
  List<Map<String, dynamic>> get goals => _goals;

  GoalProvider() {
    _loadGoals();
  }

  void _loadGoals() {
    _db.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>? ?? {};
      _goals = data.entries.map((entry) {
        return {
          'id': entry.key,
          'goal': entry.value['goal'],
          'createdAt': entry.value['createdAt'],
        };
      }).toList();
      notifyListeners();
    });
  }

  Future<void> addGoal(String goal) async {
    final newGoal = {
      'goal': goal,
      'createdAt': DateTime.now().toIso8601String(),
    };
    await _db.push().set(newGoal);
  }
}
