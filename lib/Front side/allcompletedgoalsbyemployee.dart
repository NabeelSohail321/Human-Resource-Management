import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/goalprovider.dart';

class CompletedGoals extends StatefulWidget {
  const CompletedGoals({super.key});

  @override
  State<CompletedGoals> createState() => _CompletedGoalsState();
}

class _CompletedGoalsState extends State<CompletedGoals> {
  @override
  void initState() {
    super.initState();

    // Fetch completed goals when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GoalsProvider>(context, listen: false).fetchCompletedGoals(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Goals'),
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, goalsProvider, child) {
          final completedGoals = goalsProvider.employyeGoals
              .where((goal) => goal['isCompleted'] == true)
              .toList(); // Filter for completed goals

          if (completedGoals.isEmpty) {
            return const Center(child: Text('No Completed Goals Found'));
          }

          return ListView.builder(
            itemCount: completedGoals.length,
            itemBuilder: (context, index) {
              final goal = completedGoals[index];
              return Card(
                elevation: 5,
                child: ListTile(
                  title: Text(goal['departmentName']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description: ${goal['description']}"),
                      Text("Manager: ${goal['managerName']} (${goal['managerNumber']})"),
                      Text("Date: ${goal['dateTime']}"), // Original date
                      if (goal['completionDateTime'] != null) // Show completion date if available
                        Text(
                          "Completed On: ${goal['completionDateTime']}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
