import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/goalmodels.dart';
import '../Models/managermodel.dart';
import '../Providers/goalprovider.dart';
import '../Providers/managerprovider.dart';
import '../components.dart';

class GoalAssignment extends StatefulWidget {
  const GoalAssignment({super.key});

  @override
  State<GoalAssignment> createState() => _GoalAssignmentState();
}

class _GoalAssignmentState extends State<GoalAssignment> {
  final descripController = TextEditingController();
  String? selectedManager;
  String? selectedEmployee;



  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<ManagersProvider>(context, listen: false);
    userProvider.fetchManagers();
  }

  @override
  Widget build(BuildContext context) {
    final managersProvider = Provider.of<ManagersProvider>(context);
    final managersList = managersProvider.managers; // Fetch the list of managers from the provider

    return Scaffold(
      appBar: CustomAppBar.customAppBar("Goals Assignment Page"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedManager,
              hint: Text('Select Manager'),
              items: managersList.map((manager) {
                return DropdownMenuItem<String>(
                  value: manager.uid, // Assuming each manager has a unique ID
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(manager.name),
                      SizedBox(width: 300,),
                      Text(manager.departmentName),

                    ],
                  ), // Display manager's name in the dropdown
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedManager = newValue;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            SizedBox(height: 30,),
            TextFormField(
              controller: descripController,
              decoration: InputDecoration(
                hintText: 'Enter description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30,),
            ElevatedButton(
              onPressed: () async {
                await _addGoal(); // Call the method to add the goal
              },
              child: const Text("Add Goal"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addGoal() async {
    final managersProvider = Provider.of<ManagersProvider>(context, listen: false);
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);

    // Check if the selected manager is not null and the description is not empty
    if (selectedManager != null && descripController.text.isNotEmpty) {
      final selectedManagerData = managersProvider.managers.firstWhere(
              (manager) => manager.uid == selectedManager,
          orElse: () => Manager(uid: '', name: '', email: '', phone: '', departmentName: '', managerNumber: '', role: '', status: '')
      );

      // Create a new Goal object without an ID yet
      Goal newGoal = Goal(
        id: '', // Set a placeholder; we'll update this with Firebase key later
        mdId: FirebaseAuth.instance.currentUser!.uid, // Actual MD ID
        managerId: selectedManager!,
        managerName: selectedManagerData.name,
        managerNumber: selectedManagerData.managerNumber,
        departmentName: selectedManagerData.departmentName,
        description: descripController.text,
        dateTime: DateTime.now(), // Current date and time
      );

      try {
        // Add the goal using the GoalsProvider
        await goalsProvider.addGoal(newGoal);
        descripController.clear(); // Clear the text field
        selectedManager = null; // Reset selected manager if necessary
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Goal added successfully!')));

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add goal: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a manager and enter a description.')));
    }
  }

}
