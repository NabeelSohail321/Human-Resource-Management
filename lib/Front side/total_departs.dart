import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart'; // Adjust the import based on your file structure

class DepartmentListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Departments'),
      ),
      body: FutureBuilder(
        future: Provider.of<UserProvider>(context, listen: false).fetchtotalDepartments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading departments.'));
          } else {
            return Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                final departments = userProvider.depart ?? [];
                if (departments.isEmpty) {
                  return const Center(child: Text('No departments available.'));
                }
                return ListView.builder(
                  itemCount: departments.length,
                  itemBuilder: (context, index) {
                    final department = departments[index];
                    final departmentName = department['name'] ?? 'Unknown';
                    final departmentId = department['departId'] ?? 'Unknown';
                    return ListTile(
                      title: Text(departmentName),
                      subtitle: Text('ID: $departmentId'),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
