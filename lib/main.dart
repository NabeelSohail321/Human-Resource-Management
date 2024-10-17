import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:human_capital_management/Front%20side/Loginpage.dart';
import 'package:human_capital_management/Front%20side/adddepartments.dart';
import 'package:human_capital_management/Front%20side/superadminpanel.dart';
import 'Front side/Attendance.dart';
import 'Front side/EmployeeGoals.dart';
import 'Front side/allcompletedgoalsbyemployee.dart';
import 'Front side/completedgoalsbyemployees.dart';
import 'Front side/dashBoard.dart';
import 'Front side/employeedashboard.dart';
import 'Front side/employeprofile.dart';
import 'Front side/goalassignment.dart';
import 'Front side/goalsbyManager.dart';
import 'Front side/managerDashboard.dart';
import 'Front side/managerprofile.dart';
import 'Front side/rejectedgoalsbymanager.dart';
import 'Front side/total_departs.dart';
import 'Front side/totalempbymanager.dart';
import 'Front side/totalgoalspage.dart';
import 'Front side/totalmanagerslistpage.dart';
import 'Front side/totalresticationpage.dart';
import 'Providers/AttendanceProvider.dart';
import 'Providers/employeeprovider.dart';
import 'Providers/goalprovider.dart';
import 'Providers/managerprovider.dart';
import 'Providers/resticatedprovider.dart';
import 'Providers/usermodel.dart';
import 'Providers/userprovider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with your configuration options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Use the generated options
  );

  // Set persistence to LOCAL to maintain session on app restart
  await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..fetchUsers()),
        ChangeNotifierProvider(create: (context) => UserModel()),
        ChangeNotifierProvider(create: (context) => ManagersProvider()),
        ChangeNotifierProvider(create: (_) => RestrictedUsersProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
        ChangeNotifierProvider(create: (_) => EmployeeProvider()),

      ],
      child: MaterialApp(
        routes: {
          '/frontPage': (context) => const DashboardPage(),
          '/managerpage': (context) => HRDashboard(),
          '/login': (context) => const LoginPage(),
          '/totaldepartments': (context) => DepartmentListPage(),
          '/totalmanagers': (context) => const ManagersListPage(),
          '/totalresticated': (context) => const ResticatedListPage(),
          '/superadminpanel': (context) => SuperAdminPanel(),
          '/adddepartments': (context) => AddDepartmentPage(),
          '/goalassignments': (context) => const GoalAssignment(),
          '/totalgoalslist': (context) => const TotalGoalsPage(),
          '/employeepage': (context) => const EmployeeDashBoard(),
          '/goalsbymanager':(context)=> const Goalsbymanager(),
          '/employeesbymanager':(context)=> const TotalEmpBasedOnManager(),
          '/goalsbyemployee':(context)=> const EmployeeGoals(),
          '/attendancebyemployee': (context) => AttendanceScreen(
            userId: ModalRoute.of(context)!.settings.arguments as String,
          ),
          '/employeeprofile':(context)=> const EmployeeProfile(),
          '/allcompletedgoals':(context)=> const CompletedGoals(),
          '/managerprofile':(context)=> const ManagerProfile(),
          '/completedgoalspageformanager':(context)=> const CompletedGoalsForManager(),
          '/rejectedgoalsbymanager': (context) => RejectedGoalsPage()





        },
        title: 'HCM-Human Capital Management',
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data; // Get the current user

          // Check if user is logged in
          if (user != null) {
            // Fetch the user role from your provider
            return FutureBuilder<String?>(
              future: Provider.of<UserProvider>(context, listen: false).fetchRole(),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator()); // Show loading indicator
                } else if (roleSnapshot.hasError) {
                  return Center(child: Text('Error: ${roleSnapshot.error}'));
                } else {
                  String? userRole = roleSnapshot.data;

                  // Navigate based on user role
                  if (userRole == 'MD') {
                    // Navigate to MD Page
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/frontPage');
                    });
                  } else if (userRole == 'Manager') {
                    // Navigate to Manager Page
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/managerpage');
                    });
                  } else if (userRole == 'Employee') {
                    // Navigate to Employee Page
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/employeepage');
                    });
                  } else {
                    // If role is null, go to login page
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushReplacementNamed(context, '/login');
                    });
                  }
                }
                return Container(); // Empty container while navigating
              },
            );
          } else {
            // User is not logged in, navigate to login page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
          }
        }
        // While checking the user state, show a loading indicator
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
