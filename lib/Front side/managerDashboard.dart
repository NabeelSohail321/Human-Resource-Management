import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/Providers/managerprovider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../Providers/employeeprovider.dart';
import '../Providers/goalprovider.dart';
import '../Providers/usermodel.dart';
import 'drawerfile.dart';

class HRDashboard extends StatefulWidget {
  @override
  _HRDashboardState createState() => _HRDashboardState();
}

class _HRDashboardState extends State<HRDashboard> with SingleTickerProviderStateMixin{
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _contentSlideAnimation; // For the content slide
  bool isDrawerOpen = false;
  User? user; // Store the user information
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );


  // ScrollController for GridView
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

    _scrollController.addListener(_scrollListener);

    // Ensure we fetch the current manager's details after the managers have been loaded
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        final managerProvider = Provider.of<ManagersProvider>(context, listen: false);
        await managerProvider.fetchManagers(); // Ensure managers are fetched
        managerProvider.fetchCurrentManagerByUid(user.uid); // Fetch the current manager using UID
      }
    });

    // Get the current user and fetch user details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        Provider.of<UserModel>(context, listen: false).fetchUserDetails(user.uid);
      }
    });

    // Fetch goals for the current manager when the widget is initialized
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    goalsProvider.initialize(); // Ensure this is called to fetch goals


    // Fetch the current manager's department
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final managerProvider = Provider.of<ManagersProvider>(context, listen: false);
      await managerProvider.fetchManagers(); // Fetch managers

      final currentManager = managerProvider.currentManager;
      if (currentManager != null) {
        // Call the fetchTotalEmployeeCount method with the current manager's department
        final employeeProvider = Provider.of<EmployeeProvider>(context, listen: false);
        await employeeProvider.fetchTotalEmployeeCount(currentManager.departmentName);
      }
    });


  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() {
        _isAtBottom = true;
      });
    } else if (_scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      setState(() {
        _isAtBottom = false;
      });
    }
  }

  void _scrollToPosition() {
    if (_isAtBottom) {
      // Scroll to the top of the GridView
      _scrollController.animateTo(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      // Scroll to the bottom of the GridView
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
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
    final managerProvider = Provider.of<ManagersProvider>(context);
    final currentManager = managerProvider.currentManager;
    final goalsProvider = Provider.of<GoalsProvider>(context);
    final empProvider = Provider.of<EmployeeProvider>(context);

    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: toggleDrawer,
        ),
        title: const Text("Manager DashBoard",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30),),
      ),
      body: Stack(
        children: [
          SlideTransition(
              position: _contentSlideAnimation,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    bool isMobile = constraints.maxWidth < 600; // Threshold for mobile layout
                    return Column(
                      children: [
                        // Date Picker and Department Filter Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  DateTimeRange? picked = await showDateRangePicker(
                                    context: context,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now(),
                                    initialDateRange: selectedDateRange,
                                  );
                                  if (picked != null) {
                                    setState(() {
                                      selectedDateRange = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${DateFormat('MM/dd/yyyy').format(selectedDateRange.start)} - ${DateFormat('MM/dd/yyyy').format(selectedDateRange.end)}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: currentManager != null // Check if currentManager is not null
                                  ? DropdownButtonFormField<String>(
                                value: currentManager.departmentName, // Set the value to the current manager's department
                                onChanged: (newValue) {
                                  // On change, you can choose to do nothing or handle it
                                  // If you don't want any changes, you can leave this empty
                                  // For example, just remove the setState if you don't need to do anything
                                },
                                items: [
                                  // Create a single DropdownMenuItem using the current manager's department name
                                  DropdownMenuItem(
                                    value: currentManager.departmentName,
                                    child: Text(currentManager.departmentName),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Department",
                                ),
                              )
                                  : Container( // Display a placeholder or empty widget when the manager is not available
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: const Text("Loading..."), // Indicate loading state or show nothing
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Metrics Grid - Responsive based on screen size
                        Expanded(
                          child: Stack(
                            children: [
                              GridView.count(
                                childAspectRatio: 2,
                                controller: _scrollController, // Attach controller to GridView
                                crossAxisCount: isMobile ? 2 : 4, // Adjust columns based on screen size
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                children: [
                                  buildMetricTile("Total Goals", "${goalsProvider.totalGoalsCount}", () {
                                    Navigator.pushNamed(context, ('/goalsbymanager'));
                                    print("Employee Days Absent tapped!");
                                    // You could navigate to a detailed page or show a modal with more information.
                                  }),
                                  buildMetricTile("Total Employees", "${empProvider.totalEmployeeCount}", () {
                                    Navigator.pushNamed(context, ('/employeesbymanager'));

                                    print("Total Employees tapped!");
                                  }),
                                  buildMetricTile("Manager Profile", "", () {
                                    Navigator.pushNamed(context, ('/managerprofile'));

                                    print("Pre-approved Absences tapped!");
                                  }),
                                  buildMetricTile("Overtime Hours", "156", () {
                                    print("Overtime Hours tapped!");
                                  }),
                                  buildMetricTile("Unscheduled Days Leave", "108", () {
                                    print("Unscheduled Days Leave tapped!");
                                  }),
                                  buildMetricTile("Employee Days Present", "1248", () {
                                    print("Employee Days Present tapped!");
                                  }),
                                  buildMetricTile("Sick Leave vs. Casual Leave", "78 / 76", () {
                                    print("Sick Leave vs. Casual Leave tapped!");
                                  }),
                                  buildMetricTile("Employees on Probation", "8", () {
                                    print("Employees on Probation tapped!");
                                  }),
                                ],
                              ),
                              // Floating Action Button
                              Positioned(
                                bottom: 16,
                                right: MediaQuery.of(context).size.width*0.478,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: FloatingActionButton(
                                    mouseCursor: MaterialStateMouseCursor.clickable,
                                    isExtended: true,
                                    focusElevation: 200,
                                    tooltip: _isAtBottom ?'scroll up': 'scroll down',
                                    onPressed: _scrollToPosition,
                                    child: Icon(_isAtBottom ? Icons.arrow_upward : Icons.arrow_downward,size: 30,),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Charts Section - Responsive layout based on screen size
                        Expanded(
                          child: isMobile
                              ? Column( // For mobile, display charts vertically
                            children: [
                              Expanded(
                                child: SfCircularChart(
                                  title: ChartTitle(text: 'Employee Work Location Breakdown'),
                                  legend: Legend(isVisible: true, position: LegendPosition.bottom),
                                  series: <CircularSeries>[
                                    PieSeries<WorkLocationData, String>(
                                      dataSource: getWorkLocationData(),
                                      xValueMapper: (WorkLocationData data, _) => data.location,
                                      yValueMapper: (WorkLocationData data, _) => data.percentage,
                                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SfCartesianChart(
                                  title: ChartTitle(text: 'Attendance by Department'),
                                  primaryXAxis: CategoryAxis(),
                                  series: <ChartSeries>[
                                    BarSeries<DepartmentAttendanceData, String>(
                                      dataSource: getDepartmentAttendanceData(),
                                      xValueMapper: (DepartmentAttendanceData data, _) => data.department,
                                      yValueMapper: (DepartmentAttendanceData data, _) => data.attendanceRate,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                              : Row( // For larger screens, display charts side by side
                            children: [
                              Expanded(
                                child: SfCircularChart(
                                  title: ChartTitle(text: 'Employee Work Location Breakdown'),
                                  legend: Legend(isVisible: true, position: LegendPosition.right),
                                  series: <CircularSeries>[
                                    PieSeries<WorkLocationData, String>(
                                      dataSource: getWorkLocationData(),
                                      xValueMapper: (WorkLocationData data, _) => data.location,
                                      yValueMapper: (WorkLocationData data, _) => data.percentage,
                                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                child: SfCartesianChart(
                                  title: ChartTitle(text: 'Attendance by Department'),
                                  primaryXAxis: CategoryAxis(),
                                  series: <ChartSeries>[
                                    BarSeries<DepartmentAttendanceData, String>(
                                      dataSource: getDepartmentAttendanceData(),
                                      xValueMapper: (DepartmentAttendanceData data, _) => data.department,
                                      yValueMapper: (DepartmentAttendanceData data, _) => data.attendanceRate,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ),
          SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: screenSize.width * 0.18, // Adjust width of the drawer (80% of the screen)
              child:  const Drawerfrontside(), // Your custom drawer widget
            ),
          ),

        ],
      ),
    );
  }

  Widget buildMetricTile(String title, String value, VoidCallback onPress) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Colors.grey[200],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }


  List<WorkLocationData> getWorkLocationData() {
    return [
      WorkLocationData('Home', 45.43),
      WorkLocationData('Office', 54.57),
    ];
  }

  List<DepartmentAttendanceData> getDepartmentAttendanceData() {
    return [
      DepartmentAttendanceData('Finance', 83),
      DepartmentAttendanceData('IT', 80),
      DepartmentAttendanceData('Sales', 78),
      DepartmentAttendanceData('HR', 75),
      DepartmentAttendanceData('Marketing', 73),
      DepartmentAttendanceData('Admin', 72),
      DepartmentAttendanceData('Support', 70),
      DepartmentAttendanceData('Accounting', 68),
    ];
  }
}

class WorkLocationData {
  final String location;
  final double percentage;

  WorkLocationData(this.location, this.percentage);
}

class DepartmentAttendanceData {
  final String department;
  final double attendanceRate;

  DepartmentAttendanceData(this.department, this.attendanceRate);
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
