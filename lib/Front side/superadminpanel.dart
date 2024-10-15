import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';
import '../components.dart';

class SuperAdminPanel extends StatefulWidget {
  @override
  _SuperAdminPanelState createState() => _SuperAdminPanelState();
}

class _SuperAdminPanelState extends State<SuperAdminPanel> {

  String selectedWorkplace = "None Selected";
  List<String> workplace = ["None Selected", "Work From Home", "Work From Office"];
  @override
  void initState() {
    super.initState();

    // Delay the fetch operation until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // userProvider.fetchUsers();
      userProvider.fetchDepartments(); // Fetch departments when the widget is initialized
    });
  }


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final Map<String, String> departmentMap = userProvider.departments;

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
                "All Employee Details",
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

                // Get the currently selected department ID for the user, default to 'no_department' if none
                String selectedDepartmentId = user['department'] ?? 'no_department';

                return ListTile(
                  title: Text(user['name'] ?? 'Unknown User'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("E-Mail: ${user['email'] ?? 'No Email'}"),
                      Text("Role: ${user['role'] == '0' ? 'HR' : user['role'] == '1' ? 'Employee' : 'Manager'}"),
                      Text("Department: ${user['departmentName'] ?? 'No Department'}"), // Add this line
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Role Dropdown
                      DropdownButton<String>(
                        value: user['role'],
                        items: const [
                          DropdownMenuItem(value: '0', child: Text('HR')),
                          DropdownMenuItem(value: '1', child: Text('Employee')),
                          DropdownMenuItem(value: '2', child: Text('Manager')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            userProvider.updateUserRole(user['uid'], value,context);
                          }
                        },
                      ),
                      DropdownButton<String>(
                        value: selectedDepartmentId, // Use selectedDepartmentId here
                        items: [
                          DropdownMenuItem(
                            value: 'no_department',
                            child: Text('${user['departmentName'] ?? 'No Department'}'),
                          ),
                          ...departmentMap.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key, // departmentId
                              child: Text(entry.value), // departmentName
                            );
                          }).toList(),
                        ],
                        onChanged: (newDepartmentId) {
                          if (newDepartmentId != null) {
                            // Update department using the selected department ID
                            String newDepartmentName = departmentMap[newDepartmentId] ?? '';
                            userProvider.updateUserDepartment(user['uid'], newDepartmentName,context);
                          }
                        },                      ),
                      const SizedBox(width: 10), // Spacing between dropdowns
                      Text("Status: ${user['user status'] ?? 'No Status'}", style: const TextStyle(color: Colors.blue)),
                    ],
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