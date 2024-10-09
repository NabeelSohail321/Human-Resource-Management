import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  bool _isFirstUser = true;

  bool get isFirstUser => _isFirstUser;

  Future<void> checkFirstUser() async {
    final hrSnapshot = await _dbRef.child("HR").once();
    _isFirstUser = hrSnapshot.snapshot.value == null; // Check if no HR user exists
    notifyListeners();
  }

  Future<void> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Register user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      String userId = userCredential.user!.uid;

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // If this is the first user, assign them as HR (role 0), otherwise assign them as Employee (role 1)
      String role = _isFirstUser ? "0" : "1";
      String node = _isFirstUser ? "HR" : "Employee";

      // Save user information in the correct node in Firebase Database
      await _dbRef.child(node).child(userId).set({
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "password": password,
      });

      // If first user, mark it as HR created
      if (_isFirstUser) {
        _isFirstUser = false;
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception("Error registering user: ${e.message}");
    }
  }

  Future<bool> isEmailVerified() async {
    User? user = _auth.currentUser;

    // Reload the user to check the latest verification status
    await user?.reload();
    user = _auth.currentUser;

    return user?.emailVerified ?? false;
  }

  Future<void> loginUser(String email, String password) async {
    try {
      // Sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Check if the email is verified
      if (!userCredential.user!.emailVerified) {
        // If the email is not verified, sign out and show an error
        await _auth.signOut();
        throw Exception("Email not verified. Please verify your email before logging in.");
      }

      notifyListeners();
    } on FirebaseAuthException catch (e) {
      throw Exception("Error logging in: ${e.message}");
    }
  }
}
