import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart'; // Adjust the import based on your file structure

class AddDepartmentPage extends StatefulWidget {
  @override
  _AddDepartmentPageState createState() => _AddDepartmentPageState();
}

class _AddDepartmentPageState extends State<AddDepartmentPage> {
  final TextEditingController _departmentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Department"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Department Name:",
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              controller: _departmentController,
              decoration: const InputDecoration(
                hintText: "Enter department name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addDepartment();
              },
              child: const Text("Add Department"),
            ),
          ],
        ),
      ),
    );
  }

  void _addDepartment() {
    final departmentName = _departmentController.text.trim();

    if (departmentName.isNotEmpty) {
      // Call the provider method to add the department to the database
      Provider.of<UserProvider>(context, listen: false).addDepartment(departmentName);
      // Optionally show a success message or navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Department "$departmentName" added successfully!')),
      );
      _departmentController.clear(); // Clear the text field
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a department name.')),
      );
    }
  }
}
