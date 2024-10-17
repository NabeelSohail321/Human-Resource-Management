// class _HRDashboardState extends State<HRDashboard> with SingleTickerProviderStateMixin {
//   // ... existing code ...
//
//   List<WorkLocationData> workLocationData = [];
//
//   @override
//   void initState() {
//     super.initState();
//
//     // ... existing initialization code ...
//
//     // Fetch work location data after fetching the current user
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       await fetchWorkLocationData();
//     });
//   }
//
//   Future<void> fetchWorkLocationData() async {
//     final empProvider = Provider.of<EmployeeProvider>(context, listen: false);
//     await empProvider.fetchWorkLocations(); // Fetch work locations from EmployeeProvider
//
//     setState(() {
//       workLocationData = empProvider.workLocationCounts; // Get the updated work location counts
//     });
//   }
//
//   // ... existing code ...
//
//   @override
//   Widget build(BuildContext context) {
//     final managerProvider = Provider.of<ManagersProvider>(context);
//     final goalsProvider = Provider.of<GoalsProvider>(context);
//     final empProvider = Provider.of<EmployeeProvider>(context);
//
//     final screenSize = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.menu),
//           onPressed: toggleDrawer,
//         ),
//         title: const Text(
//           "Manager Dashboard",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
//         ),
//       ),
//       body: Stack(
//         children: [
//           SlideTransition(
//             position: _contentSlideAnimation,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   bool isMobile = constraints.maxWidth < 600; // Threshold for mobile layout
//                   return Column(
//                     children: [
//                       // ... your existing widget structure ...
//
//                       // Charts Section - Responsive layout based on screen size
//                       Expanded(
//                         child: SfCircularChart(
//                           title: ChartTitle(text: 'Employee Work Location Breakdown'),
//                           legend: Legend(isVisible: true, position: LegendPosition.bottom),
//                           series: <CircularSeries>[
//                             PieSeries<WorkLocationData, String>(
//                               dataSource: workLocationData, // Use the fetched work location data
//                               xValueMapper: (WorkLocationData data, _) => data.location,
//                               yValueMapper: (WorkLocationData data, _) => data.percentage,
//                               dataLabelSettings: const DataLabelSettings(isVisible: true),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),
//           ),
//           // ... your existing drawer code ...
//         ],
//       ),
//     );
//   }
// }
