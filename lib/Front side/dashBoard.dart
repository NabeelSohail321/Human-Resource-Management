import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/total_departs.dart';
import 'package:human_capital_management/Front%20side/totalmanagerslistpage.dart';
import 'package:human_capital_management/Front%20side/totalresticationpage.dart';
import 'package:provider/provider.dart';
import '../Providers/usermodel.dart';
import 'drawerfile.dart';
import 'goalassignment.dart'; // Assuming this contains your custom drawer

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});


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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _contentSlideAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0.18, 0.0))
        .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    // Delay fetch operation until the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        Provider.of<UserModel>(context, listen: false).fetchUserDetails(user!.uid);
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
    final userModel = Provider.of<UserModel>(context); // Listen to user model for updates
    final screenSize = MediaQuery.of(context).size; // Get screen size

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
            // child: Row(
            //   children: [
            //     SizedBox(width: screenSize.width*0.02,),
            //     InkWell(
            //       child: Card(
            //         elevation: 5,
            //         child: Container(
            //           width: 200,
            //           height: 200,
            //           child: const Center(child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text("TOTAL",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //               Text("Departs",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //             ],
            //           )),
            //         ),
            //       ),
            //       onTap: (){
            //         Navigator.push(context, MaterialPageRoute(builder: (context)=>DepartmentListPage()));
            //       },
            //     ),
            //     SizedBox(width: screenSize.width*0.02,),
            //     InkWell(
            //       child: Card(
            //         elevation: 5,
            //         child: Container(
            //           width: 200,
            //           height: 200,
            //           child: const Center(child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text("TOTAL",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //               Text("Managers",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //             ],
            //           )),
            //         ),
            //       ),
            //       onTap: (){
            //         Navigator.push(context, MaterialPageRoute(builder: (context)=>const ManagersListPage()));
            //       },
            //     ),
            //     SizedBox(width: screenSize.width*0.02,),
            //     InkWell(
            //       child: Card(
            //         elevation: 5,
            //         child: Container(
            //           width: 200,
            //           height: 200,
            //           child: const Center(child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text("TOTAL",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //               Text("Resticated",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //             ],
            //           )),
            //         ),
            //       ),
            //       onTap: (){
            //         Navigator.push(context, MaterialPageRoute(builder: (context)=>const ResticatedListPage()));
            //       },
            //     ),
            //     InkWell(
            //       child: Card(
            //         elevation: 5,
            //         child: Container(
            //           width: 200,
            //           height: 200,
            //           child: const Center(child: Column(
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text("Goal",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //               Text("Assignment",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.blueGrey)),
            //             ],
            //           )),
            //         ),
            //       ),
            //       onTap: (){
            //         Navigator.push(context, MaterialPageRoute(builder: (context)=> GoalAssignment()));
            //       },
            //     ),
            //
            //   ],
            // ),
          ),

          // Animated Drawer
          SlideTransition(
            position: _slideAnimation,
            child: const Drawerfrontside(), // Replace with your custom drawer
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


class DashboardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onButtonPressed;

  const DashboardItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onButtonPressed,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.teal,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50,
              color: Colors.black87,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
