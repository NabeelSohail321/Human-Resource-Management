import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/totalgoalsachieved.dart';
import 'package:provider/provider.dart';
import '../Providers/usermodel.dart';
import 'drawerfile.dart'; // Assuming this contains your custom drawer

class DashboardPage extends StatefulWidget {
  final String role;

  const DashboardPage({Key? key, required this.role}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _contentSlideAnimation; // For the content slide
  bool isDrawerOpen = false;
  User? user; // Store the user information

  @override
  void initState() {
    super.initState();

    // Fetch user details when the DashboardPage is initialized
    user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      Provider.of<UserModel>(context, listen: false).fetchUserDetails(user!.uid);
    }

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Content slide animation
    _contentSlideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.18, 0.0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
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
    final userModel = Provider.of<UserModel>(context); // Listen to user model for updates

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: toggleDrawer,
        ),
        title: const Text("Dash Board"),
      ),
      body: Stack(
        children: [
          // Animated content that moves to the side
          SlideTransition(
            position: _contentSlideAnimation,
            child: Row(
              children: [
                SizedBox(width: 10,),
                InkWell(
                  child: Card(
                    elevation: 5,
                    child: Container(
                      width: 200,
                      height: 200,
                      child: Center(child: Text("TOTAL\nGOALS",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey))),
                    ),
                  ),
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>totalgoalsforEmployee()));
                  },
                ),

              ],
            ),
          ),

          // Animated Drawer
          SlideTransition(
            position: _slideAnimation,
            child: Drawerfrontside(), // Replace with your custom drawer
          ),

          // Placeholder or content while loading user details
          // if (userModel.isLoading) // Assuming you have a loading state in UserModel
          //   Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
