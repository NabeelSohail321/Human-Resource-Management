import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/superadminpanel.dart';
import 'package:provider/provider.dart';
import '../Providers/usermodel.dart';
import '../Providers/userprovider.dart';
import '../components.dart';
import 'adddepartments.dart';
import 'dashBoard.dart';

class Drawerfrontside extends StatelessWidget {
  const Drawerfrontside({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20.0), // Rounded top right corner
        bottomRight: Radius.circular(20.0), // Rounded bottom right corner
      ),
      child: Drawer(
        width: 230,
        backgroundColor: const Color(0xFFDEE5D4),
        child: ListView(
          children: [
            ListTile(
              title: Center(
                child: Text(
                  'Role: ${userModel.role != null ? (userModel.role == 0 ? "MD" : userModel.role == 1 ? "Employee" : "Manager") : "Role not found"}',
                  style: CustomTextStyles.customTextStyle,
                ),
              ),
              subtitle:Center(child: Text('Name: ${userModel.name ?? "Not Available"}')),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home", style: CustomTextStyles.customTextStyle),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DashboardPage()),
                );
              },
            ),
            if (userModel.role == 0)
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("MD Management", style: CustomTextStyles.customTextStyle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SuperAdminPanel()),
                  );
                },
              ),
            if (userModel.role == 0)
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text("Add Departments", style: CustomTextStyles.customTextStyle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddDepartmentPage()),
                  );
                },
              ),

            // Additional options based on roles can be added here.
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Log out", style: CustomTextStyles.customTextStyle),
              onTap: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                try {
                  await userProvider.logout(); // Call the logout method
                  Navigator.pushReplacementNamed(context, '/login'); // Ensure you have defined this route
                } catch (e) {
                  print(e.toString());
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Logout failed: ${e.toString()}")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
