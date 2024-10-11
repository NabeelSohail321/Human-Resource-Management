import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';
import '../components.dart';

class ManageEmployeePanel extends StatefulWidget {
  @override
  _ManageEmployeePanelState createState() => _ManageEmployeePanelState();
}

class _ManageEmployeePanelState extends State<ManageEmployeePanel> {
  @override
  void initState() {
    super.initState();
    // Fetch only employees when the widget is initialized
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchEmployees(); // Adjusted to fetch only employees
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: CustomAppBar.customAppBar("Manager Panel"),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Employees",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userProvider.users.length,
              itemBuilder: (context, index) {
                final user = userProvider.users[index];
                // Determine user status color
                Color statusColor = user['isActive'] == true ? Colors.green : Colors.red;

                return ListTile(
                  title: Text(
                    user['name'] ?? 'Unknown User',
                    style: TextStyle(color: statusColor), // Change color based on status
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("E-Mail: ${user['email'] ?? 'No Email'}"),
                      Text("Role: ${user['role'] == '0' ? 'HR' : user['role'] == '1' ? 'Employee' : 'Manager'}"),
                    ],
                  ),
                  trailing: DropdownButton<String>(
                    value: user['role'],
                    items: const [
                      DropdownMenuItem(value: '0', child: Text('HR')),
                      DropdownMenuItem(value: '1', child: Text('Employee')),
                      DropdownMenuItem(value: '2', child: Text('Manager')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        userProvider.updateUserRole(user['uid'], value);
                      }
                    },
                  ),
                  // Actions for inactive and delete
                  onTap: () {
                    // Show actions to make inactive or delete
                    _showUserActions(context, user);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUserActions(BuildContext context, Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Actions for ${user['name']}"),
          content: Text("What would you like to do?"),
          actions: <Widget>[
            // TextButton(
            //   child: Text(user['isActive'] == true ? 'Make Inactive' : 'Make Active'),
            //   onPressed: () {
            //        // Handle make inactive/active
            //     Provider.of<UserProvider>(context, listen: false).toggleUserActiveStatus(user['uid']);
            //     Navigator.of(context).pop();
            //   },
            // ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // Handle delete user
                Provider.of<UserProvider>(context, listen: false).deleteUser(user['uid']);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
