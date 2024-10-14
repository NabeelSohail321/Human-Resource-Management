import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/goalprovider.dart';

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
      appBar: AppBar(
        title: const Text("Total Goals"),
      ),
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
                  title: Text(goal.departmentName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Description: ${goal.description}"),
                      Text("Manager: ${goal.managerName} (${goal.managerNumber})"),
                      Text("Date: ${goal.dateTime.toLocal().toIso8601String()}"), // Displaying date in local format
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
        child: Icon(Icons.add,color: Colors.teal,),
      ),
    );
  }
}
