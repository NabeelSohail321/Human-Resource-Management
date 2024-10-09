import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/loginpage.dart';
import 'package:provider/provider.dart';
import 'Providers/auth_provider.dart';
import 'auth_page.dart';
import 'firebase_options.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Provide AuthProvider at the top level
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: {
          '/register': (context) => RegisterPage(), // Register page route
          '/login': (context) => LoginPage(), // Login page route
          '/homepage': (context) => HomePage(), // Login page route
        },
        title: 'HCM Performance Enhancement System',
        home: LoginPage(), // Home page or landing page
      ),
    );
  }
}
