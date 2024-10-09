import 'package:firebase_auth/firebase_auth.dart' as auth; // Alias Firebase User
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/superadminpanel.dart';
import '../components.dart';
import 'dashBoard.dart';

class Drawerfrontside extends StatefulWidget {
  const Drawerfrontside({super.key});

  @override
  State<Drawerfrontside> createState() => _DrawerfrontsideState();
}

class _DrawerfrontsideState extends State<Drawerfrontside> {
  int? _role;
  auth.User? currentUser;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final currentUser = this.currentUser;
    if (currentUser != null) {
      try {
        // Check the HR node first
        final hrRef = FirebaseDatabase.instance.ref("HR/${currentUser.uid}");
        final hrSnapshot = await hrRef.child("role").get();

        if (hrSnapshot.exists) {
          setState(() {
            _role = int.parse(hrSnapshot.value.toString());
          });
        } else {
          // If the role is not found in the HR node, check in the Employee node
          final employeeRef = FirebaseDatabase.instance.ref("Employee/${currentUser.uid}");
          final employeeSnapshot = await employeeRef.child("role").get();

          if (employeeSnapshot.exists) {
            setState(() {
              _role = int.parse(employeeSnapshot.value.toString());
            });
          } else {
            // Handle case where role is not found in either node
            print("User role not found in HR or Employee nodes.");
          }
        }
      } catch (e) {
        print('Error fetching user role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFDEE5D4),
      child: ListView(
        children: [
          ListTile(
            title: Center(
              child: Text(
                'Role: ${_role ?? "Role not found"}',
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
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("HR Management", style: CustomTextStyles.customTextStyle),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SuperAdminPanel()),
              );
            },
          ),
        ],
      ),
    );
  }
}
