import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:human_capital_management/Front%20side/Loginpage.dart';
import 'Front side/Registerpage.dart';
import 'Front side/dashBoard.dart';
import 'Providers/userprovider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()), // Provide the UserProvider
      ],
      child: MaterialApp(
        routes: {
          '/frontPage': (context) => const Dashboard(),
          //sdasdasd
        },
        debugShowCheckedModeBanner: false,
        home: const LoginPage(), // Ensure RegisterPage is used properly
      ),
    );
  }
}
