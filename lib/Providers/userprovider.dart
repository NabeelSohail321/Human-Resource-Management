import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  User? _user;

  User? get user => _user;
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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      String userId = userCredential.user!.uid;

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      // If this is the first user, assign them as HR (role 0), otherwise assign them as Employee (role 1)
      String role = _isFirstUser ? "0" : "1";
      String node = _isFirstUser ? "HR" : "Employee";

      // Get the user's UID
      String uid = userCredential.user!.uid;
      // Save user information in the correct node in Firebase Database
      await _dbRef.child(node).child(userId).set({
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
        "password": password,
        "uid": uid,
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

  Future<void> login(String email, String password) async {
    try {
      // First, sign in the user using Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _user = userCredential.user;

      // Check credentials in HR, Employee, and Manager nodes
      final hrSnapshot = await _dbRef.child('HR').orderByChild('email').equalTo(email).once();
      final employeeSnapshot = await _dbRef.child('Employee').orderByChild('email').equalTo(email).once();
      final managerSnapshot = await _dbRef.child('Manager').orderByChild('email').equalTo(email).once();

      // Verify if the user exists in any of the nodes
      if (hrSnapshot.snapshot.exists || employeeSnapshot.snapshot.exists || managerSnapshot.snapshot.exists) {
        // User exists in at least one node
        notifyListeners();
      } else {
        // User does not exist in any node
        throw Exception('User does not exist in any role.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      throw e; // Re-throwing for handling in the UI
    } catch (e) {
      // Handle other errors
      throw Exception(e.toString());
    }
  }
}
