// import 'package:flutter/material.dart';
//
// import 'package:provider/provider.dart';
// import '../Providers/userprovider.dart';
// import 'Registerpage.dart';
// import 'dashBoard.dart';
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});
//
//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }
//
// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController ec = TextEditingController();
//   final TextEditingController pass = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           double containerWidth = constraints.maxWidth < 600 ? 0.85 : 0.4;
//
//           return Stack(
//             children: [
//               Center(
//                 child: Container(
//                   width: MediaQuery.of(context).size.width * containerWidth,
//                   decoration: BoxDecoration(
//                     border: Border.all(width: 1),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const SizedBox(height: 10),
//                         TextField(
//                           controller: ec,
//                           decoration: const InputDecoration(
//                             hintText: "Enter Your Email Address",
//                             labelText: "Email",
//                             border: OutlineInputBorder(
//                               borderRadius:
//                               BorderRadius.all(Radius.circular(15)),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         TextField(
//                           controller: pass,
//                           decoration: const InputDecoration(
//                             hintText: "Enter Your Password",
//                             labelText: "Password",
//                             border: OutlineInputBorder(
//                               borderRadius:
//                               BorderRadius.all(Radius.circular(15)),
//                             ),
//                           ),
//                           obscureText: true,
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                           onPressed: () async {
//                             String email = ec.text.trim();
//                             String password = pass.text.trim();
//                             try {
//                               await Provider.of<UserProvider>(context,
//                                   listen: false)
//                                   .login(email, password);
//                               await ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text("Login Successfull")),
//                               );
//                               Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (context) => DashboardPage()));
//                             } catch (e) {
//                               // Handle the error (e.g., show a Snackbar with the error message)
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text(e.toString())),
//                               );
//                             }
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             minimumSize: const Size(double.infinity, 50),
//                           ),
//                           child: const Text(
//                             "Log In",
//                             style: TextStyle(
//                                 fontSize: 25,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         const Text(
//                             "If you are not registered, please click on"),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) =>
//                                     const RegisterPage()));
//                           },
//                           child: const Text("Register"),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
Center(
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
TextField(
controller: nc,
decoration: const InputDecoration(
hintText: "Enter Your Name",
labelText: "Name",
border: OutlineInputBorder(
borderRadius: BorderRadius.all(Radius.circular(15)),
),
),
),
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
controller: phonec,
decoration: const InputDecoration(
hintText: "Enter Your Phone No",
labelText: "Phone No",
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
registerUser();
},
style: ElevatedButton.styleFrom(
backgroundColor: Colors.black,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(20),
),
minimumSize: const Size(double.infinity, 50), // Make button full width
),
child: const Text(
"Register",
style: TextStyle(fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
),
),
const SizedBox(height: 10),
const Text("If you are already registered, please click on"),
TextButton(
onPressed: () {
Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
},
child: const Text("Login"),
),
],
),
),
),
);