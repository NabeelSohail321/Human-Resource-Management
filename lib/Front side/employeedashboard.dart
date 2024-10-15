import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/usermodel.dart';
import 'Attendance.dart';
import 'drawerfile.dart';

class EmployeeDashBoard extends StatefulWidget {
  const EmployeeDashBoard({super.key});

  @override
  State<EmployeeDashBoard> createState() => _EmployeeDashBoardState();
}

class _EmployeeDashBoardState extends State<EmployeeDashBoard> with SingleTickerProviderStateMixin  {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _contentSlideAnimation; // For the content slide
  bool isDrawerOpen = false;
  User? user; // Store the user information

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _contentSlideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.18, 0.0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Delay fetch operation until the first frame is rendered
    user = FirebaseAuth.instance.currentUser;
    WidgetsBinding.instance.addPostFrameCallback((_) {
       // Get the current user
      if (user != null) {
        Provider.of<UserModel>(context).fetchUserDetails(user!.uid);
      }
    });
  }
  void toggleDrawer() {
    if (isDrawerOpen) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size; // Get screen size dynamically

    return user!=null? Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: toggleDrawer,
        ),
        title: const Text("Employee Dash Board",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
      ),
      body: Stack(
        children: [
          // Animated content that moves to the side when the drawer is open
          SlideTransition(
            position: _contentSlideAnimation,
          ),
          // Drawer widget that slides in/out
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: screenSize.width * 0.18, // Adjust width of the drawer (80% of the screen)
              child:  Drawerfrontside(), // Your custom drawer widget
            ),
          ),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AttendanceScreen(userId: user!.uid,);
            },));
          }, child: Text("Attendance"))
        ],
      ),

    ):Scaffold(
      body: Center(child: Text('Login First')),
    );
  }
}
