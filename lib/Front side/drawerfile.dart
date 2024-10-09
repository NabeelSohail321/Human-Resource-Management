import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/superadminpanel.dart';
import 'package:provider/provider.dart';
import '../Providers/usermodel.dart';
import '../Providers/userprovider.dart';
import '../components.dart';
import 'dashBoard.dart';

class Drawerfrontside extends StatelessWidget {
  const Drawerfrontside({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context);

    return Drawer(
      backgroundColor: const Color(0xFFDEE5D4),
      child: ListView(
        children: [
          ListTile(
            title: Center(
              child: Text(
                'Role: ${userModel.role ?? "Role not found"}',
                style: CustomTextStyles.customTextStyle,
              ),
            ),
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
            ListTile(
            leading: const Icon(Icons.logout), // Updated icon for logout
            title: const Text("Log out", style: CustomTextStyles.customTextStyle),
              onTap: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                try {
                  await userProvider.logout(); // Call the logout method
                  // Navigate to the login screen after logging out
                  Navigator.pushReplacementNamed(context, '/login'); // Ensure you have defined this route
                } catch (e) {
                  print(e.toString());
                  // Show a SnackBar if logout fails
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Logout failed: ${e.toString()}")),
                  );
                }
              },
            ),
          ],
      ),
    );
  }
}
