import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/goalProvider.dart';

class GoalSettingPage extends StatelessWidget {
  final TextEditingController goalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Set Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: goalController,
              decoration: InputDecoration(labelText: 'New Goal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await Provider.of<GoalProvider>(context, listen: false)
                    .addGoal(goalController.text);
                goalController.clear();
              },
              child: Text('Add Goal'),
            ),
            Expanded(
              child: Consumer<GoalProvider>(
                builder: (context, goalProvider, child) {
                  return ListView.builder(
                    itemCount: goalProvider.goals.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(goalProvider.goals[index]['goal']),
                        subtitle: Text(goalProvider.goals[index]['createdAt']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
