import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/goalprovider.dart';
import '../components.dart';
import 'allcompletedgoalsbyemployee.dart';

class EmployeeGoals extends StatefulWidget {
  const EmployeeGoals({super.key});

  @override
  State<EmployeeGoals> createState() => _EmployeeGoalsState();
}

class _EmployeeGoalsState extends State<EmployeeGoals> {
  @override
  void initState() {
    super.initState();

    // Delay the fetch operation until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      Provider.of<GoalsProvider>(context, listen: false).fetchEmployeeGoals(uid, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.customAppBar("Your New Goals"),

      body: Consumer<GoalsProvider>(
        builder: (context, goalsprovider, child) {
          final goals = goalsprovider.employyeGoals;
          if (goals.isEmpty) {
            return const Center(child: Text('No Goals Found'));
          }
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final isCompleted = goal['isCompleted'] ?? false;

              return Card(
                elevation: 5,
                child: Stack(
                  children: [
                    ListTile(
                      title: Text(goal['departmentName']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Description: ${goal['description']}"),
                          Text("Manager: ${goal['managerName']} (${goal['managerNumber']})"),
                          Text("Date: ${goal['dateTime']}"),
                          if (goal['completionDateTime'] != null) // Show completion date if available
                            Text(
                              "Completed On: ${goal['completionDateTime']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          Text("Rating: ${goal['rating']}",style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold
                          ),),
                          Text("Feedback: ${goal['feedback']}",style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                          ),),

                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                          color: isCompleted ? Colors.green : null,
                        ),
                        onPressed: () {
                          // Mark the goal as complete
                          Provider.of<GoalsProvider>(context, listen: false)
                              .markGoalAsComplete(goal['goalId']); // Assuming goal has a 'goalId' field
                          setState(() {}); // Update the UI to reflect the changes
                        },
                      ),
                    ),
                    if (isCompleted)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          color: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: const Text(
                            'Completed',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
