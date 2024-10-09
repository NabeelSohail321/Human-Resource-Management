import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/usermodel.dart';
import 'drawerfile.dart';
import 'goalsettingPage.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool isDrawerOpen = false;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController for controlling the sliding drawer
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Fetch user details when the dashboard initializes
    final userModel = Provider.of<UserModel>(context, listen: false);

    // Get the currently logged-in user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch user details by UID
      userModel.fetchUserDetails(user.uid);
    } else {
      // Handle the case when the user is not logged in
      // You can navigate to a login page or show a message
      print("User not logged in.");
    }
  }



  void toggleDrawer() {
    if (isDrawerOpen) {
      _animationController.reverse(); // Close drawer
    } else {
      _animationController.forward(); // Open drawer
    }
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: toggleDrawer, // Toggle drawer open/close
          ),
        ),
        body: Stack(
          children: <Widget>[
            // Main Page Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Welcome to the Dashboard'),
                  SizedBox(height: 20),

                  // Use Consumer to listen for changes in UserModel
                  Consumer<UserModel>(builder: (context, userModel, child) {
                    if (userModel.currentUser == null) {
                      return Text('Loading user data...');
                    } else if (userModel.role == null) {
                      return Text('Role not found.');
                    } else {
                      String roleText;
                      switch (userModel.role) {
                        case 0:
                          roleText = "MD";
                          break;
                        case 1:
                          roleText = "Employee";
                          break;
                        case 2:
                          roleText = "Manager";
                          break;
                        default:
                          roleText = "Unknown role";
                      }
                      return Text('Your Role: $roleText');
                    }
                  }),

                  SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => GoalSettingPage()),
                      );
                    },
                    child: Text('Manage Goals'),
                  ),
                  // Add more buttons for other functionalities
                ],
              ),
            ),
            // Sliding Drawer
            SlideTransition(
              position: _slideAnimation,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0), // Rounded top right corner
                    bottomRight: Radius.circular(20.0), // Rounded bottom right corner
                  ),
                ),
                width: 250, // Set the width for the drawer
                child: Drawerfrontside(), // Your custom drawer content
              ),
            ),
          ],
        ),
      ),
    );
  }
}
