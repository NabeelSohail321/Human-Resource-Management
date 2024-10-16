// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../Providers/userprovider.dart';
// import 'Registerpage.dart';
// import 'dashBoard.dart';
// import 'managerDashboard.dart';
// import 'mdDashboard.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Full-screen grey container
//           Container(
//             color: Colors.grey,
//             width: double.infinity,
//             height: double.infinity,
//             child: Stack(
//               children: [
//                 Container(
//                   height: MediaQuery.of(context).size.height * 0.3,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                     borderRadius: BorderRadius.only(
//                       bottomRight: Radius.circular(280),
//                     ),
//                   ),
//                   child: Align(
//                     alignment: Alignment.bottomLeft,
//                     child: Image.asset('assets/images/login.png'),
//                   ),
//                 ),
//                 Align(
//                   alignment: Alignment.bottomCenter,
//                   child: Container(
//                     height: MediaQuery.of(context).size.height * 0.3,
//                     decoration: BoxDecoration(
//                       color: Colors.green,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(280),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Centered container on top of the grey container
//           Center(
//             child: Container(
//               width: MediaQuery.of(context).size.width * 0.85,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border.all(width: 1),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Consumer<UserProvider>(
//                     builder: (context, authProvider, child) {
//                       return Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           TextFormField(
//                             controller: emailController,
//                             decoration: const InputDecoration(
//                               hintText: "Enter Your Email Address",
//                               labelText: "Email",
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(Radius.circular(15)),
//                               ),
//                             ),
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your email address';
//                               }
//                               String pattern =
//                                   r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
//                               RegExp regex = RegExp(pattern);
//                               if (!regex.hasMatch(value)) {
//                                 return 'Please enter a valid email address';
//                               }
//                               return null;
//                             },
//                           ),
//                           const SizedBox(height: 10),
//                           TextFormField(
//                             controller: passwordController,
//                             decoration: const InputDecoration(
//                               hintText: "Enter Your Password",
//                               labelText: "Password",
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.all(Radius.circular(15)),
//                               ),
//                             ),
//                             obscureText: true,
//                           ),
//                           const SizedBox(height: 20),
//                           ElevatedButton(
//                             onPressed: authProvider.isLoggingIn
//                                 ? null
//                                 : () {
//                               if (_formKey.currentState!.validate()) {
//                                 loginUser(authProvider);
//                               }
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.black,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               minimumSize: const Size(double.infinity, 50),
//                             ),
//                             child: authProvider.isLoggingIn
//                                 ? const CircularProgressIndicator(color: Colors.white)
//                                 : const Text(
//                               "Log In",
//                               style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
//                             ),
//                           ),
//                           const SizedBox(height: 10),
//                           const Text("If you have not registered please click on"),
//                           TextButton(
//                             onPressed: () {
//                               Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterPage()));
//                             },
//                             child: const Text("Register"),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void loginUser(UserProvider authProvider) async {
//     try {
//       String? role = await authProvider.loginUser(
//         emailController.text.trim(),
//         passwordController.text.trim(),
//       );
//
//       if (role == 0) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => DashboardScreen()), // Pass the role if needed
//         );
//       }else if(role == 2){
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => HRDashboard()), // Pass the role if needed
//         );
//       }else if(role == 1){
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => DashboardPage()), // Pass the role if needed
//         );
//       } else {
//         _showSnackbar(context, 'User data not found in Employee, MD, or Manager nodes.');
//       }
//     } catch (e) {
//       _showSnackbar(context, 'Error: $e');
//     }
//   }
//
//   void _showSnackbar(BuildContext context, String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }
// }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/userprovider.dart';
import 'Registerpage.dart';
import 'dashBoard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                  child: Consumer<UserProvider>(
                    builder: (context, authProvider, child) {
                      return Column(
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
                              String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                              RegExp regex = RegExp(pattern);
                              if (!regex.hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
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
                            onPressed: authProvider.isLoggingIn
                                ? null
                                : () {
                              if (_formKey.currentState!.validate()) {
                                loginUser(authProvider);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                            ),
                            child: authProvider.isLoggingIn
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                            },
                            child: const Text("Register"),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void loginUser(UserProvider authProvider) async {
    try {
      String? role = await authProvider.loginUser(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Use a switch-case or if-else for clearer role handling
      switch (role) {
        case '0':
          Navigator.pushReplacementNamed(context, '/frontPage');
          break;
        case '1':
          Navigator.pushReplacementNamed(context, '/employeepage');

          break;
        case '2':
          Navigator.pushReplacementNamed(context, '/managerpage');

          break;
        default:
          _showSnackbar(context, 'User data not found in Employee, MD, or Manager nodes.');
      }
    } catch (e) {
      _showSnackbar(context, 'Error: ${e.toString()}');
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
