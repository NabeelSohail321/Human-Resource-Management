import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/employeeprovider.dart';
import '../Providers/managerprovider.dart';
import '../components.dart';

class TotalEmpBasedOnManager extends StatefulWidget {
  const TotalEmpBasedOnManager({super.key});

  @override
  _TotalEmpBasedOnManagerState createState() => _TotalEmpBasedOnManagerState();
}

class _TotalEmpBasedOnManagerState extends State<TotalEmpBasedOnManager> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final Map<String, String> _selectedLocations = {};

  Future<List<Employee>> _fetchEmployees() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      final managerProvider = Provider.of<ManagersProvider>(context, listen: false);

      // Fetch the current manager by UID
      await managerProvider.fetchCurrentManagerByUid(user.uid); // Ensure this returns a Future

      // Get the department name
      final departmentName = managerProvider.currentManager?.departmentName;

      // Fetch employees based on the department name
      if (departmentName != null && departmentName.isNotEmpty) {
        final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
        await employeeProvider.fetchEmployeesByDepartment(departmentName); // Call the new method
        return employeeProvider.employees; // Return the employee list
      }
    }
    return []; // Return an empty list if no employees found
  }

  void _updateWorkLocation(String employeeId, String location) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Update the work location in the database under the current user node
      _databaseReference.child('Employee').child(employeeId).update({
        'workLocation': location,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Work location updated to $location")),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update work location: $error")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.customAppBar("Total Employees"),
      body: FutureBuilder<List<Employee>>(
        future: _fetchEmployees(), // Call the fetch method directly here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}")); // Handle errors
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No employees found in your department.")); // No employees case
          }

          // Employees data available
          final employees = snapshot.data!;
          return ListView.builder(
            itemCount: employees.length,
            itemBuilder: (context, index) {
              final employee = employees[index];

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(employee.name),
                  subtitle: Text("ID: ${employee.uid}\nDepartment: ${employee.department}"),
                  trailing: DropdownButton<String>(
                    value:  employee.workLocation, // Get the selected value for this employee
                    hint: const Text('Select Location'),
                    items: const [
                      DropdownMenuItem(
                        value: 'Work from Home',
                        child: Text('Work from Home'),
                      ),
                      DropdownMenuItem(
                        value: 'Work from Office',
                        child: Text('Work from Office'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLocations[employee.uid] = value; // Update selected location for this employee
                        });
                        _updateWorkLocation(employee.uid, value); // Save selected option to the database
                      }
                    },
                  ),


                ),
              );
            },
          );
        },
      ),
    );
  }
}


