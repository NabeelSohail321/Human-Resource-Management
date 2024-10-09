import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:human_capital_management/Front%20side/Registerpage.dart';

import 'dashBoard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth authentication = FirebaseAuth.instance;
  final DatabaseReference dref = FirebaseDatabase.instance.ref();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoggingIn = false; // Track logging in state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen grey container
          Container(
            color: Colors.grey,
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(280),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Image.asset('assets/images/login.png'),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(280),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Centered container on top of the grey container
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          hintText: "Enter Your Email Address",
                          labelText: "Email",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          // Email regex pattern
                          String pattern =
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null; // Return null if the input is valid
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordController,
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
                        onPressed: isLoggingIn
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            loginUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: isLoggingIn
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                          "Log In",
                          style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text("If you have not registered please click on"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
                        },
                        child: const Text("Register"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Login function to authenticate user
  void loginUser() async {
    setState(() {
      isLoggingIn = true; // Set loading state
    });

    try {
      // Sign in with Firebase Auth
      UserCredential userCredential = await authentication.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the user ID
      String uid = userCredential.user?.uid ?? '';

      // References to the Employee, MD, and Manager nodes
      DatabaseReference employeeRef = dref.child("Employee/$uid");
      DatabaseReference mdRef = dref.child("MD/$uid");
      DatabaseReference managerRef = dref.child("Manager/$uid");

      // Check if user is in the Employee node
      DataSnapshot employeeSnapshot = await employeeRef.get();
      if (employeeSnapshot.exists) {
        // Handle successful login for Employee
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) =>  DashboardPage()), // Replace with your Employee page
        );
      } else {
        // Check if user is in the MD node
        DataSnapshot mdSnapshot = await mdRef.get();
        if (mdSnapshot.exists) {
          // Handle successful login for MD
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  DashboardPage()), // Replace with your MD page
          );
        } else {
          // Check if user is in the Manager node
          DataSnapshot managerSnapshot = await managerRef.get();
          if (managerSnapshot.exists) {
            // Handle successful login for Manager
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) =>  DashboardPage()), // Replace with your Manager page
            );
          } else {
            // User not found in any node
            _showSnackbar(context, 'User data not found in Employee, MD, or Manager nodes.');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      // Handle authentication errors
      _showSnackbar(context, 'Error: ${e.message}');
    } finally {
      setState(() {
        isLoggingIn = false; // Reset loading state
      });
    }
  }

  // Helper method to show a snackbar
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
