import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/goalprovider.dart';

class EmployeeGoals extends StatefulWidget {
  const EmployeeGoals({super.key});

  @override
  State<EmployeeGoals> createState() => _EmployeeGoalsState();
}

class _EmployeeGoalsState extends State<EmployeeGoals> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    String uid = FirebaseAuth.instance.currentUser!.uid;
    Provider.of<GoalsProvider>(context, listen: false).fetchEmployeeGoals(uid, context);

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Employee Goals'),
      ),
      body: Consumer<GoalsProvider>(
        builder: (context, goalsprovider, child){
          final goals = goalsprovider.employyeGoals;
          if (goals.isEmpty) {
            return const Center(child: Text('No Goals Found')); // Show loading indicator while fetching
          }
          return ListView.builder(itemCount: goals.length,
            itemBuilder: (context, index) {
            final goal = goals[index];
            return Card(
              elevation: 5,
              child: ListTile(
                title: Text(goal['departmentName']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Description: ${goal['description']}"),
                    Text("Manager: ${goal['managerName']} (${goal['managerNumber']})"),
                    Text("Date: ${goal['dateTime'].toString()}"), // Displaying date in local format
                  ],
                ),
              ),
            );
          },);
        },
      )
    );
  }
}
