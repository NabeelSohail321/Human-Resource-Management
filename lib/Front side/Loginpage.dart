import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/Registerpage.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final authentication = FirebaseAuth.instance;
  final nc = TextEditingController();
  final ec = TextEditingController();
  final phonec = TextEditingController();
  final pass = TextEditingController();
  final DatabaseReference dref = FirebaseDatabase.instance.ref();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determine the width to use based on screen size
          double containerWidth = constraints.maxWidth < 600 ? 0.85 : 0.4; // 85% for small screens, 40% for large screens

          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width * containerWidth, // Responsive width
              decoration: BoxDecoration(
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Added padding around the container
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Wrap content tightly
                  children: [
                    const SizedBox(height: 10), // Add spacing between fields
                    TextField(
                      controller: ec,
                      decoration: const InputDecoration(
                        hintText: "Enter Your Email Address",
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pass,
                      decoration: const InputDecoration(
                        hintText: "Enter Your Password",
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, '/frontPage'); // Replace the current route
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: const Size(double.infinity, 50), // Make button full width
                      ),
                      child: const Text(
                        "Log In",
                        style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("If you not registered , please click on"),
                    TextButton(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                      },
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
