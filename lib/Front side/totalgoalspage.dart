import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/goalprovider.dart';
import '../components.dart';

class TotalGoalsPage extends StatefulWidget {
  const TotalGoalsPage({super.key});

  @override
  State<TotalGoalsPage> createState() => _TotalGoalsPageState();
}

class _TotalGoalsPageState extends State<TotalGoalsPage> {
  @override
  void initState() {
    super.initState();
    // Fetch goals when the page loads
    Provider.of<GoalsProvider>(context, listen: false).fetchGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.customAppBar("Total Assigned Goals"),

      body: Consumer<GoalsProvider>(
        builder: (context, goalsProvider, child) {
          final goals = goalsProvider.goals;
          if (goals.isEmpty) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator while fetching
          }
          return ListView.builder(
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];

              return Card(
                elevation: 5,
                child: ListTile(
                  title: Text("${goal.departmentName}"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description: ${goal.description}"),
                      Text("Manager: ${goal.managerName} (${goal.managerNumber})"),
                      Text("Date: ${goal.dateTime.toLocal().toIso8601String()}"),// Displaying date in local format
                      if (goal.completionDateTime != null) // Show completion date if available
                        Text(
                          "Completed On: ${goal.completionDateTime}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      Text("Rating: ${goal.rating}",style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),),
                      Text(
                        "Feedback: ${goal.feedback}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold
                      ),),
                      if(goal.isCompleted==true)
                        Text("Completed by employee: ${goal.assignedEmployeeId}"),
                      if(goal.status == 'Rejected')
                        Text("Goal was regected by manager and reason is ${goal.rejectionReason}",style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          color: Colors.red
                        ),)
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            Navigator.pushNamed(context, '/goalassignments');
          },
        child: const Icon(Icons.add,color: Colors.teal,),
      ),
    );
  }



}
