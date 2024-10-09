// auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dref = FirebaseDatabase.instance.ref();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

   Future<void> registerUser({
    required String name,
    required String phone,
    required String email,
    required String cnic,
    required String password,
    required BuildContext context,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Check if CNIC already exists
      DatabaseEvent userEvent = await _dref.child('users').orderByChild('cnic').equalTo(cnic).once();
      DatabaseEvent adminEvent = await _dref.child('admin').orderByChild('cnic').equalTo(cnic).once();

      if (userEvent.snapshot.exists || adminEvent.snapshot.exists) {
        throw Exception("CNIC already exists.");
      }

      // Register the user with email and password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      // Reference to the users and admin nodes
      final DatabaseReference usersRef = _dref.child('users');
      final DatabaseReference adminRef = _dref.child('admin');

      // Determine if this is the first user
      DatabaseEvent adminDataEvent = await adminRef.once();
      bool isFirstUser = !adminDataEvent.snapshot.exists || adminDataEvent.snapshot.children.isEmpty;

      String userRole = isFirstUser ? '0' : '1';
      DatabaseReference userRef = isFirstUser ? adminRef.child(uid) : usersRef.child(uid);

      // Determine user number
      int userNumber = 1; // Default value
      if (!isFirstUser) {
        DatabaseEvent usersDataEvent = await usersRef.orderByChild('userNumber').limitToLast(1).once();
        if (usersDataEvent.snapshot.exists) {
          var lastUserNumber = usersDataEvent.snapshot.children.last.child('userNumber').value as int;
          userNumber = lastUserNumber + 1;
        }
      }

      // Determine admin number
      int adminNumber = 1; // Default value
      if (isFirstUser) {
        DatabaseEvent adminData = await adminRef.orderByChild('adminNumber').limitToLast(1).once();
        if (adminData.snapshot.exists) {
          var lastAdminNumber = adminData.snapshot.children.last.child('adminNumber').value as int;
          adminNumber = lastAdminNumber + 1;
        }
      }

      // Create user model and save data without password
      Map<String, dynamic> userData = {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'cnic': cnic,
        'role': userRole,
      };

      if (isFirstUser) {
        userData['adminNumber'] = adminNumber.toString();
        await adminRef.child(uid).set(userData);
      } else {
        userData['userNumber'] = userNumber.toString();
        await usersRef.child(uid).set(userData);
      }

      // Send verification email
      User? user = _auth.currentUser;
      if (user != null) {
        await user.sendEmailVerification();

        // Navigate to a different page, informing the user to check their email
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent! Please check your inbox.')),
        );
        await user.reload();
        if(user.emailVerified) {
          Navigator.pushNamed(context, '/login').then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login Successfull')),
            );
          });
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('please verify the email Again')),
          );
          await user.reload();
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())), // Provide more user-friendly messages if needed
      );
    }
  }

}
