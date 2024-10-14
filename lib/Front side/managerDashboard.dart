import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class HRDashboard extends StatefulWidget {
  @override
  _HRDashboardState createState() => _HRDashboardState();
}

class _HRDashboardState extends State<HRDashboard> {
  DateTimeRange selectedDateRange = DateTimeRange(
    start: DateTime.now().subtract(Duration(days: 30)),
    end: DateTime.now(),
  );

  String selectedDepartment = "All";
  List<String> departments = ["All", "Finance", "IT", "Sales", "HR", "Marketing"];

  // ScrollController for GridView
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HR Attendance Dashboard'),
      ),
      body: Padding(
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
                        items: departments.map((String department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Departments",
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

