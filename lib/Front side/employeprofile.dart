import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Providers/employeeprovider.dart';
import '../components.dart';

class EmployeeProfile extends StatefulWidget {
  const EmployeeProfile({super.key});

  @override
  State<EmployeeProfile> createState() => _EmployeeProfileState();
}

class _EmployeeProfileState extends State<EmployeeProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();
  final _empnumberController = TextEditingController();
  final _locationController = TextEditingController();



  @override
  void initState() {
    super.initState();

    // Fetch the employee profile using the provider
    final uid = FirebaseAuth.instance.currentUser!.uid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EmployeeProvider>(context, listen: false).fetchEmployeeProfile(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final employeeProvider = Provider.of<EmployeeProvider>(context);
    final employeeData = employeeProvider.employeeData;

    // Populate fields when data is available
    if (employeeData != null) {
      _nameController.text = employeeData['name'] ?? '';
      _phoneController.text = employeeData['phone'] ?? '';
      _emailController.text = employeeData['email'] ?? '';
      _departmentController.text = employeeData['departmentName'] ?? ''; // Display department name
      _empnumberController.text = employeeData['employeeNumber']?? '';
      _locationController.text = employeeData['workLocation']?? '';

    }

    return Scaffold(
      appBar: CustomAppBar.customAppBar("Employee Profile"),

      body: employeeData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners, change as needed
                      borderSide: BorderSide(
                        color: Colors.grey, // Color of the border
                        width: 1.5, // Width of the border
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0, // Vertical padding
                      horizontal: 16.0, // Horizontal padding
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Name is required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners, change as needed
                      borderSide: BorderSide(
                        color: Colors.grey, // Color of the border
                        width: 1.5, // Width of the border
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0, // Vertical padding
                      horizontal: 16.0, // Horizontal padding
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Phone is required' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  readOnly: true,
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners, change as needed
                      borderSide: BorderSide(
                        color: Colors.grey, // Color of the border
                        width: 1.5, // Width of the border
                      ),
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0, // Vertical padding
                      horizontal: 16.0, // Horizontal padding
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  readOnly: true,
                  controller: _departmentController,
                  decoration: InputDecoration(
                    labelText: 'Department',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners, change as needed
                      borderSide: BorderSide(
                        color: Colors.grey, // Color of the border
                        width: 1.5, // Width of the border
                      ),
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0, // Vertical padding
                      horizontal: 16.0, // Horizontal padding
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  readOnly: true,
                  controller: _empnumberController,
                  decoration: InputDecoration(
                    labelText: 'Employee Number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners, change as needed
                      borderSide: BorderSide(
                        color: Colors.grey, // Color of the border
                        width: 1.5, // Width of the border
                      ),
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0, // Vertical padding
                      horizontal: 16.0, // Horizontal padding
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextFormField(
                  readOnly: true,
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Employee Location of Work',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners, change as needed
                      borderSide: BorderSide(
                        color: Colors.grey, // Color of the border
                        width: 1.5, // Width of the border
                      ),
                    ),

                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.0, // Vertical padding
                      horizontal: 16.0, // Horizontal padding
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _updateProfile(employeeProvider);
                  }
                },
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProfile(EmployeeProvider provider) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final updatedData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'email': _emailController.text, // Include email if you want it to be updated
      'departmentName': _departmentController.text, // Include department name
      'employeeNumber': _empnumberController.text, // Include employee number
    };

    provider.updateEmployeeProfile(uid, updatedData).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $error')),
      );
    });
  }
}
