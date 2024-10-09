import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GoalPage extends StatefulWidget {
  @override
  _GoalPageState createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final _goalController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _addGoal() async {
    final goal = _goalController.text;
    if (goal.isNotEmpty) {
      await _database.child('goals').push().set({
        'goal': goal,
        'createdAt': DateTime.now().toString(),
      });
      _goalController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Goals')),
      body: Column(
        children: [
          TextField(controller: _goalController, decoration: InputDecoration(labelText: 'Enter your goal')),
          ElevatedButton(onPressed: _addGoal, child: Text('Add Goal')),
          Expanded(
            child: StreamBuilder(
              stream: _database.child('goals').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final goals = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  return ListView.builder(
                    itemCount: goals.length,
                    itemBuilder: (context, index) {
                      final goal = goals.values.elementAt(index)['goal'];
                      return ListTile(title: Text(goal));
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
