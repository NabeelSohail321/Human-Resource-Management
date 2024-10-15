import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/goalmodels.dart';
import '../Providers/employeeprovider.dart';
import '../Providers/goalprovider.dart';

class Goalsbymanager extends StatefulWidget {
  const Goalsbymanager({super.key});

  @override
  State<Goalsbymanager> createState() => _GoalsbymanagerState();
}

class _GoalsbymanagerState extends State<Goalsbymanager> {
  @override
  void initState() {
    super.initState();
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

    // Check if user is logged in before initializing
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      goalsProvider.initialize();
    } else {
      // Handle case where user is not authenticated
      print("User is not logged in.");
    }
  }

  // Function to show the dialog for assigning the goal
  void _showAssignEmployeeDialog(Goal goal) async {
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

    // Fetch employees in the same department
    await employeeProvider.fetchEmployeesByDepartment(goal.departmentName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Assign Goal to Employee"),
          content: SizedBox(
            height: 300, // Set height to accommodate the employee list
            width: 300, // Set width for the dialog
            child: ListView.builder(
              itemCount: employeeProvider.employees.length,
              itemBuilder: (context, index) {
                final employee = employeeProvider.employees[index];

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1),
                  ),
                  child: ListTile(
                    title: Text(employee.name),
                    subtitle: Text(employee.department),
                    onTap: () {
                      // Assign the goal to the selected employee
                      goalsProvider.assignGoalToEmployee(goal, employee.uid);

                      // Update the goal's assignedEmployeeId property
                      goal.assignedEmployeeId = employee.uid;

                      Navigator.of(context).pop(); // Close the dialog
                      setState(() {}); // Refresh the UI
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalsProvider = Provider.of<GoalsProvider>(context);
    final goals = goalsProvider.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Goals for Current Manager"),
      ),
      body: goals.isEmpty
          ? const Center(child: Text("No goals found."))
          : ListView.builder(
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(goal.description),
                  subtitle: Text(
                    "Department: ${goal.departmentName}\nManager: ${goal.managerName} (${goal.managerNumber})\nDate: ${goal.dateTime.toIso8601String()}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: goal.assignedEmployeeId == null
                      ? IconButton(
                    onPressed: () {
                      _showAssignEmployeeDialog(goal);
                    },
                    icon: const Icon(Icons.person_add),
                  )
                      : null, // Hide the icon if assignedEmployeeId is not null
                ),
                // Show assignment message if it is set
                if (goal.assignedEmployeeId != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Goal assigned to Employee ID: ${goal.assignedEmployeeId}',
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
