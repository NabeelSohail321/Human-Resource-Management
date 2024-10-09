import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';
import '../components.dart';

class SuperAdminPanel extends StatefulWidget {
  @override
  _SuperAdminPanelState createState() => _SuperAdminPanelState();
}

class _SuperAdminPanelState extends State<SuperAdminPanel> {
  @override
  void initState() {
    super.initState();
    // Fetch users when the widget is initialized
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: CustomAppBar.customAppBar("Admin Panel"),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Users",
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
                return ListTile(
                  title: Text(user['name'] ?? 'Unknown User'),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
