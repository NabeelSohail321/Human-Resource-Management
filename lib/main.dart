import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:human_capital_management/Front%20side/Loginpage.dart';
import 'Front side/dashBoard.dart';
import 'Providers/goalProvider.dart';
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

  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // Provide the UserProvider
        ChangeNotifierProvider(create: (context) => GoalProvider()),
        ChangeNotifierProvider(create: (context) => UserModel()),
      ],
      child: MaterialApp(
        routes: {
          '/frontPage': (context) =>  DashboardPage(),
          '/login': (context) =>  LoginPage(),

          //sdjkaslkd
        },
        title: 'HCM-Human Capital Management',
        debugShowCheckedModeBanner: false,
        home: const LoginPage(), // Ensure RegisterPage is used properly
      ),
    );
  }
}
