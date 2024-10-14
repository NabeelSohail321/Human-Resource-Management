import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/managerprovider.dart';

class GoalAssignment extends StatefulWidget {
  const GoalAssignment({super.key});

  @override
  State<GoalAssignment> createState() => _GoalAssignmentState();
}

class _GoalAssignmentState extends State<GoalAssignment> {
  final descripController = TextEditingController();
  String? selectedManager; // To store the selected manager
  String? selectedEmployee; // To store the selected manager



  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<ManagersProvider>(context, listen: false);
    userProvider.fetchManagers();
    userProvider.fetchEmployees();

  }

  @override
  Widget build(BuildContext context) {
    final managersProvider = Provider.of<ManagersProvider>(context);
    final managersList = managersProvider.managers; // Fetch the list of managers from the provider
    final EmployeeList = managersProvider.employees; // Fetch the list of managers from the provider

    return Scaffold(
      appBar: AppBar(
        title: Text("Goal Assignment Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Dropdown to select a manager
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
                      SizedBox(width: 250,),
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
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedEmployee,
              hint: Text('Select Employee'),
              items: managersList.map((manager) {
                return DropdownMenuItem<String>(
                  value: manager.uid, // Assuming each manager has a unique ID
                  child: Text(manager.name), // Display manager's name in the dropdown
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedEmployee = newValue;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),

            // TextFormField for goal description
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
          ],
        ),
      ),
    );
  }
}
