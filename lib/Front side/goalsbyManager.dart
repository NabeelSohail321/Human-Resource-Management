import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/goalmodels.dart';
import '../Providers/employeeprovider.dart';
import '../Providers/goalprovider.dart';
import '../components.dart';

class Goalsbymanager extends StatefulWidget {
  const Goalsbymanager({super.key});

  @override
  State<Goalsbymanager> createState() => _GoalsbymanagerState();
}

class _GoalsbymanagerState extends State<Goalsbymanager> {
  DateTime? selectedDeadline;

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
            height: 400, // Adjust height for employee list and date picker
            width: 300,
            child: Column(
              children: [
                Expanded(
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employee.department),
                              Text(employee.uid),
                            ],
                          ),
                          onTap: () async {
                            print("Clicked");
                            // Show the date picker after selecting the employee
                            await _selectDeadline(goal, employee.uid); // Await for date picker to finish
                            // The dialog will close in _selectDeadline
                          },

                        ),
                      );
                    },
                  ),
                ),
              ],
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

// Function to show the date picker
  Future<void> _selectDeadline(Goal goal, String employeeId) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null) {
      // Save the deadline and assign the goal to the selected employee
      setState(() {
        goal.deadline = selectedDate; // Update the goal's deadline
      });

      // Assign the goal to the employee and save the deadline
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      await goalsProvider.assignGoalToEmployee(goal, employeeId, selectedDate); // Ensure this method accepts the date

      // Update the goal's properties
      goal.assignedEmployeeId = employeeId;


      // Close the dialog after successfully assigning the goal
      Navigator.of(context).pop(); // Close the dialog here
    }
  }


  @override
  Widget build(BuildContext context) {
    final goalsProvider = Provider.of<GoalsProvider>(context);
    final goals = goalsProvider.goals;

    return Scaffold(
      appBar: CustomAppBar.customAppBar("Goals for Manager"),
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
                    "Department: ${goal.departmentName}\nManager: ${goal.managerName} (${goal.managerNumber})\nDate: ${goal.dateTime.toIso8601String()}\nDeadline: ${goal.deadline?.toIso8601String() ?? 'Not Set'}",
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
