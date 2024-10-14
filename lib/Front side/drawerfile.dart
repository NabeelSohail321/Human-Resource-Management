import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/superadminpanel.dart';
import 'package:provider/provider.dart';

import '../Providers/usermodel.dart';
import '../Providers/userprovider.dart';
import 'adddepartments.dart';
import 'dashBoard.dart';


class Drawerfrontside extends StatelessWidget {
  const Drawerfrontside({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel?>(context);

    // Handle loading state or null case
    if (userModel == null) {
      return Center(child: CircularProgressIndicator());
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double getFontSize() {
      if (screenWidth < 400) {
        return 10; // Small screens (phones)
      } else if (screenWidth < 600) {
        return 12; // Small to medium screens (large phones/small tablets)
      } else if (screenWidth < 900) {
        return 14; // Medium screens (tablets)
      } else if (screenWidth < 1200) {
        return 16; // Large screens (small laptops)
      } else {
        return 18; // Extra large screens (desktops)
      }
    }

    double getDrawerSize() {
      if (screenWidth < 400) {
        return screenWidth * 0.75; // For small screens, drawer is 75% of screen width
      } else if (screenWidth < 600) {
        return screenWidth * 0.5; // For medium screens, drawer is 50%
      } else {
        return screenWidth * 0.35; // For larger screens, drawer is 35%
      }
    }

    double fontSize = getFontSize();
    double drawerSize = getDrawerSize();

    // Ensure the Icon does not take the entire width of the ListTile
    Widget buildListTile(IconData icon, String title, VoidCallback onTap) {
      return ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0), // Responsive padding
        leading: SizedBox(
          width: 40,
          child: Icon(icon, size: fontSize + 4), // Icon size responsive to font size
        ),
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Lora',
            fontSize: fontSize,
            color: Colors.black,
          ),
        ),
        onTap: onTap,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Drawer(
        width: drawerSize,
        backgroundColor: const Color(0xFFDEE5D4),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // Responsive padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Role: ${userModel.role != null ? (userModel.role == 0 ? "MD" : userModel.role == 1 ? "Employee" : "Manager") : "Role not found"}',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: fontSize,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    'Name: ${userModel.name ?? "Not Available"}',
                    style: TextStyle(
                      fontFamily: 'Lora',
                      fontSize: fontSize * 0.9,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            if (userModel.role == 0) ...[
              buildListTile(Icons.admin_panel_settings, "MD Management", () {
                Navigator.pushNamed(context, '/superadminpanel');

              }),
            ],

            buildListTile(Icons.logout, "Log out", () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              try {
                await userProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                print(e.toString());
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Logout failed: ${e.toString()}")),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}



