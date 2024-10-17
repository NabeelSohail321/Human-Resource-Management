import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Models/goalmodels.dart';
import '../Providers/goalprovider.dart';
import '../Providers/usermodel.dart';
import 'drawerfile.dart';
import 'graph.dart'; // Import Syncfusion Charts

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
  List<Goal> _goalsData = [];
  List<Goal> employeeGoals = []; // To store the fetched goals

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

      if (user != null) {
        Provider.of<UserModel>(context, listen: false).fetchUserDetails(user!.uid);
      }
    });

    // Delay fetch operation until the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        Provider.of<UserModel>(context, listen: false).fetchUserDetails(user!.uid);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadGoals();
    });

  }


  Future<void> loadGoals() async {
    employeeGoals = await fetchGoalsForCurrentEmployee();
    setState(() {
      _goalsData = employeeGoals; // Update the _goalsData state
    });
  }



  Future<List<Goal>> fetchGoalsForCurrentEmployee() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      final DatabaseReference goalsRef = FirebaseDatabase.instance.ref('Goals');

      try {
        final DatabaseEvent event = await goalsRef.once();
        final DataSnapshot snapshot = event.snapshot; // Get the DataSnapshot from the event

        List<Goal> goals = [];
        if (snapshot.exists) {
          final goalsMap = snapshot.value as Map<dynamic, dynamic>;

          goalsMap.forEach((key, value) {
            // Use the fromJson factory method to create Goal objects
            final goal = Goal.fromJson(Map<String, dynamic>.from(value), key);
            if (goal.assignedEmployeeId == user.uid) { // Filter by current employee ID
              goals.add(goal);
            }
          });
        }
        return goals;
      } catch (e) {
        print("Error fetching goals: $e");
        return []; // Return an empty list on error
      }
    }
    return []; // Return an empty list if no user is logged in
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

  Widget _buildGridView(double screenWidth) {
    int crossAxisCount;

    // Determine the number of columns based on screen width using MediaQuery
    if (screenWidth < 600) {
      crossAxisCount = 2; // Mobile screens
    } else if (screenWidth < 1200) {
      crossAxisCount = 3; // Tablet screens
    } else {
      crossAxisCount = 5; // Large screens (like laptops and desktops)
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 20.0,
      mainAxisSpacing: 20.0,
      padding: const EdgeInsets.all(16.0), // Add padding if necessary
      children: [
        DashboardItem(
          icon: Icons.work_outline,
          label: 'Total Goals',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/goalsbyemployee');
          },
        ),
        DashboardItem(
          icon: Icons.work_outline,
          label: 'Attendance',
          onButtonPressed: () {
            Navigator.pushNamed(
              context,
              '/attendancebyemployee',
              arguments: user!.uid,
            );          },
        ),
        // Add other DashboardItems as needed
        DashboardItem(
          icon: Icons.people_alt_outlined,
          label: 'Profile',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/employeeprofile');
            // Navigator.push(context, MaterialPageRoute(builder: (context)=>const ManagersListPage()));
          },
        ),
        DashboardItem(
          icon: Icons.rule,
          label: 'Completed Goals',
          onButtonPressed: () {
            Navigator.pushNamed(context, '/allcompletedgoals');
          },
        ),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final screenSize = MediaQuery.of(context).size; // Get screen size dynamically
  //   List<GoalData> chartData = [
  //     GoalData("Total Goals", _goalsData.length),
  //     GoalData("Completed Goals", _goalsData.where((goal) => goal.isCompleted).length),
  //   ];
  //   return user!=null? Scaffold(
  //     key: _scaffoldKey,
  //     appBar: AppBar(
  //       leading: IconButton(
  //         icon: const Icon(Icons.menu),
  //         onPressed: toggleDrawer,
  //       ),
  //       title: const Text("Employee Dash Board",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
  //     ),
  //     body: Stack(
  //       children: [
  //         // Animated content that moves to the side when the drawer is open
  //         SlideTransition(
  //           position: _contentSlideAnimation,
  //           child: Center(
  //             child: Column(
  //               children: [
  //                 _buildGridView(screenSize.width),const SizedBox(height: 20),
  //                 GoalsBarChart(data: chartData),
  //
  //               ],
  //             ),
  //
  //             // Pass screen width for responsive grid
  //             // child: Column(
  //             //   children: [
  //             //     // Container(
  //             //     //   width: screenSize.width*0.2,
  //             //     //   child: ElevatedButton(onPressed: (){
  //             //     //     Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             //     //       return AttendanceScreen(userId: user!.uid,);
  //             //     //     },));
  //             //     //   }, child: Text("Attendance")),
  //             //     // ),
  //             //     // Container(
  //             //     //   width: screenSize.width*0.2,
  //             //     //   child: ElevatedButton(onPressed: (){
  //             //     //     Navigator.push(context, MaterialPageRoute(builder: (context) {
  //             //     //       return EmployeeGoals();
  //             //     //     },));
  //             //     //   }, child: Text("Goals")),
  //             //     // ),
  //             //   ],
  //             // ),
  //           ),
  //         ),
  //         // Drawer widget that slides in/out
  //         SlideTransition(
  //           position: _slideAnimation,
  //           child: Container(
  //             width: screenSize.width * 0.18, // Adjust width of the drawer (80% of the screen)
  //             child:  const Drawerfrontside(), // Your custom drawer widget
  //           ),
  //         ),
  //       ],
  //     ),
  //   ):const Scaffold(
  //     body: Center(child: Text('Login First')),
  //   );
  // }


  @override
  Widget build(BuildContext context) {
    final goalsProvider = Provider.of<GoalsProvider>(context);

    final screenSize = MediaQuery.of(context).size; // Get screen size dynamically
    List<GoalData> chartData = [
      GoalData("Total Goals", employeeGoals.length),
      GoalData("Completed Goals", _goalsData.where((goal) => goal.isCompleted==true).length),
    ];

    return user != null
        ? Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: toggleDrawer,
        ),
        title: const Text("Employee Dash Board", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
      ),
      body: Stack(
        children: [
          SlideTransition(
            position: _contentSlideAnimation,
            child: Center(
              child: Column(
                children: [
                  Expanded( // Wrap this in an Expanded widget to take available space
                    child: _buildGridView(screenSize.width),
                  ),
                  const SizedBox(height: 10),
                  GoalsBarChart(data: chartData),
                ],
              ),
            ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: screenSize.width * 0.18, // Adjust width of the drawer
              child: const Drawerfrontside(),
            ),
          ),
        ],
      ),
    )
        : const Scaffold(
      body: Center(child: Text('Login First')),
    );
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

