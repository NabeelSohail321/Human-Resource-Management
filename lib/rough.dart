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

      // If this is the first user, assign them as HR (role 0), otherwise assign them as Employee (role 1)
      String role = _isFirstUser ? "0" : "1";
      String node = _isFirstUser ? "HR" : "Employee";

      // Save user information in the correct node
      await _dbRef.child(node).child(userId).set({
        "name": name,
        "email": email,
        "phone": phone,
        "role": role,
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
}
