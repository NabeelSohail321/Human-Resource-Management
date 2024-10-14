import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/Models/managermodel.dart';
import 'package:human_capital_management/Providers/managerprovider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../Providers/usermodel.dart';
import '../Providers/userprovider.dart';
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
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  );

  String selectedDepartment = "All";

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

    // Ensure we fetch the current manager's details after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final managerProvider = Provider.of<ManagersProvider>(context, listen: false);
        managerProvider.fetchCurrentManagerByUid(user.uid); // Fetch the current manager using UID
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      user = FirebaseAuth.instance.currentUser; // Get the current user
      if (user != null) {
        Provider.of<UserModel>(context, listen: false).fetchUserDetails(user!.uid);
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
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      // Scroll to the bottom of the GridView
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
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
    String selectedDepartment = currentManager?.departmentName ?? "All";

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
                                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today),
                                      SizedBox(width: 8),
                                      Text(
                                        '${DateFormat('MM/dd/yyyy').format(selectedDateRange.start)} - ${DateFormat('MM/dd/yyyy').format(selectedDateRange.end)}',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedDepartment,
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedDepartment = newValue!;
                                  });
                                },
                                items: [
                                  DropdownMenuItem(value: currentManager?.departmentName, child: Text(currentManager?.departmentName ?? "All")),
                                ],
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: "Department",
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

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
                                  buildMetricTile("Employee Days Absent", "296"),
                                  buildMetricTile("Total Employees", "28"),
                                  buildMetricTile("Pre-approved Absences", "188"),
                                  buildMetricTile("Overtime Hours", "156"),
                                  buildMetricTile("Unscheduled Days Leave", "108"),
                                  buildMetricTile("Employee Days Present", "1248"),
                                  buildMetricTile("Sick Leave vs. Casual Leave", "78 / 76"),
                                  buildMetricTile("Employees on Probation", "8"),
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
                                      dataLabelSettings: DataLabelSettings(isVisible: true),
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
                                      dataLabelSettings: DataLabelSettings(isVisible: true),
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
              child:  Drawerfrontside(), // Your custom drawer widget
            ),
          ),

        ],
      ),
    );
  }

  Widget buildMetricTile(String title, String value) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
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

