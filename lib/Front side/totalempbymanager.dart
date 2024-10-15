import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/employeeprovider.dart';
import '../Providers/managerprovider.dart';

class TotalEmpBasedOnManager extends StatefulWidget {
  const TotalEmpBasedOnManager({super.key});

  @override
  State<TotalEmpBasedOnManager> createState() => _TotalEmpBasedOnManagerState();
}

class _TotalEmpBasedOnManagerState extends State<TotalEmpBasedOnManager> {
  List<Employee> _employees = []; // List to hold fetched employees
  String? _departmentName; // Variable to hold the department name
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchEmployees(); // Fetch employees on initialization
  }

  Future<void> _fetchEmployees() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      final managerProvider = Provider.of<ManagersProvider>(context, listen: false);

      // Fetch the current manager by UID
      managerProvider.fetchCurrentManagerByUid(user.uid); // This is your existing function

      // After fetching the manager, get the department name
      _departmentName = managerProvider.currentManager?.departmentName;

      // Fetch employees based on the department name
      if (_departmentName != null && _departmentName!.isNotEmpty) {
        final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);

        // Await the employee fetching method
        await employeeProvider.fetchEmployeesByDepartment(_departmentName!);

        setState(() {
          _employees = employeeProvider.employees; // Update the employee list
          _isLoading = false; // Set loading to false after fetching
        });
      } else {
        setState(() {
          _isLoading = false; // Set loading to false if department name is null or empty
        });
      }
    } else {
      setState(() {
        _isLoading = false; // Set loading to false if user is null
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Total Employees"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : _employees.isEmpty
          ? const Center(child: Text("No employees found in your department."))
          : ListView.builder(
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(employee.name),
              subtitle: Text("ID: ${employee.uid}\nDepartment: ${employee.department}"),
            ),
          );
        },
      ),
    );
  }
}