import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/userprovider.dart';
import 'Loginpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final authentication = FirebaseAuth.instance;
  final nc = TextEditingController();
  final ec = TextEditingController();
  final phonec = TextEditingController();
  final pass = TextEditingController();
  final DatabaseReference dref = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    // Check if the first user is registering to assign the role correctly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false).checkFirstUser();
    });
  }

  void registerUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.registerUser(
        name: nc.text.trim(),
        email: ec.text.trim(),
        phone: phonec.text.trim(),
        password: pass.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User registered successfully!')));
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    }
  }

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
              height: MediaQuery
                  .of(context)
                  .size
                  .height * 0.3,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  // bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(280),

                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Image(image: AssetImage('assets/images/login.png'),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.3,
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    // bottomLeft: Radius.circular(0),
                    topLeft: Radius.circular(280),

                  ),
                ),
              ),
            )

          ],
        ),
      ),

      // Centered container on top of the grey container
      Center(
        child: Container(

          width: MediaQuery
              .of(context)
              .size
              .width * 0.85, // Responsive width
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            // Added padding around the container
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
                    minimumSize: const Size(
                        double.infinity, 50), // Make button full width
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                const Text("If you are already registered, please click on"),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const LoginPage()));
                  },
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      )
      ],
    ),);
  }
}
