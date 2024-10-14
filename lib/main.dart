import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:human_capital_management/Front%20side/Loginpage.dart';
import 'Front side/dashBoard.dart';
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
        ChangeNotifierProvider(create: (_) => resticatedUsersProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
      ],
      child: MaterialApp(
        routes: {
          '/frontPage': (context) => DashboardPage(role: ''),
          '/login': (context) => LoginPage(),
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
            return DashboardPage(role: ''); // Redirect to dashboard
          } else {
            return LoginPage(); // Redirect to login page
          }
        }
        // While checking the user state, show a loading indicator
        return Center(child: CircularProgressIndicator());
      },
    );
  }

}
