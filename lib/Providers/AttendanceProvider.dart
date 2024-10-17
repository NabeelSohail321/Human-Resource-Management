import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:html' as html; // Import dart:html

class AttendanceProvider with ChangeNotifier, WidgetsBindingObserver {
  final DatabaseReference _attendanceRef = FirebaseDatabase.instance.ref('attendance');
  final double _officeLatitude = 32.16993010640498;  // Office Latitude
  final double _officeLongitude = 74.20620651107829;   // Office Longitude
  final double _officeRadiusMeters = 300;     // Radius for office attendance
  Timer? _timer;
  User? _user;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isOfficeCheckin = false;
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  String? _userId; // Store user ID

  bool get isCheckedIn => _isCheckedIn;
  bool get isCheckedOut => _isCheckedOut;
  bool get isOfficeCheckin => _isOfficeCheckin;

  AttendanceProvider() {
    WidgetsBinding.instance.addObserver(this);
    _userId = FirebaseAuth.instance.currentUser?.uid; // Store user ID

    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Notify listeners when the authentication state changes
    });
    // Add beforeunload event listener
    html.window.onBeforeUnload.listen((event) {
      if (_isCheckedIn && !_isCheckedOut) {
        markCheckOut(_userId!); // Call markCheckOut if user is checked in
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Get current location
  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  // Check if user is within office radius
  Future<bool> _isInOfficeArea(Position position) async {
    double distance = Geolocator.distanceBetween(
      _officeLatitude, _officeLongitude,
      position.latitude, position.longitude,
    );
    return distance <= _officeRadiusMeters;
  }

  // Check if user has already checked in or checked out today
  Future<void> checkAttendanceStatus(String userId) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}'; // Use formatted date as key

    final snapshot = await _attendanceRef.child(dateKey).child(userId).once();

    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;

      // Check for check-in data
      if (data['checkIn'] != null) {
        _isCheckedIn = true; // User has checked in
        _isOfficeCheckin = data['checkIn']['location'] == 'Office'; // Check if office check-in
      } else {
        _isCheckedIn = false; // User has not checked in
      }

      // Check for check-out data
      if (data['checkOut'] != null) {
        _isCheckedOut = true; // User has checked out
      } else {
        _isCheckedOut = false; // User has not checked out
      }
    } else {
      // If there is no attendance record for today
      _isCheckedIn = false;
      _isCheckedOut = false;
    }
    notifyListeners();
  }

  // Mark user as logged in
  Future<void> markLogin(String userId) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}'; // Use formatted date as key
    String loginTime = now.toIso8601String();

    await _attendanceRef.child(dateKey).child(userId).update({
      'login': {
        'time': loginTime,
      },
    });
    notifyListeners();
  }

  // Mark check-in for both office and home-based work
  Future<void> markCheckIn(String userId, bool isRemoteWork) async {
    if (_isCheckedIn) {
      throw "You have already checked in today!";
    }

    Position? position;
    if (!isRemoteWork) {
      position = await _getCurrentPosition();
      if (!await _isInOfficeArea(position)) {
        throw "You are not in the office area!";
      }
      _isOfficeCheckin = true;
    }

    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}'; // Use formatted date as key
    String checkInTime = DateTime.now().toIso8601String();

    await _attendanceRef.child(dateKey).child(userId).update({
      'checkIn': {
        'time': checkInTime,
        'location': isRemoteWork ? 'Remote' : 'Office',
      },
    });
    _isCheckedIn = true; // Update the checked-in status
    markLogin(userId);
    notifyListeners();

    // Automatically check-out at 6 PM if user forgets
    _scheduleAutoCheckout(userId);
  }

  // Mark check-out
  Future<void> markCheckOut(String userId) async {
    if (_isCheckedOut) {
      throw "You have already checked out today!";
    }

    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}'; // Use formatted date as key
    String checkOutTime = DateTime.now().toIso8601String();

     _attendanceRef.child(dateKey).child(userId).child('checkOut').set({
      'time': checkOutTime,
    });

    // Automatically log out the user
    await markLogout(userId);

    _isCheckedOut = true; // Update the checked-out status
    _cancelAutoCheckout();
    notifyListeners();
  }

  // Mark user as logged out
  Future<void> markLogout(String userId) async {
    final now = DateTime.now();
    final dateKey = '${now.year}-${now.month}-${now.day}'; // Use formatted date as key
    String logoutTime = now.toIso8601String();

     _attendanceRef.child(dateKey).child(userId).update({
      'logout': {
        'time': logoutTime,
      },
    });
     await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  // Automatically mark check-out at 6 PM
  void _scheduleAutoCheckout(String userId) {
    _timer = Timer(
      _calculateTimeUntil6PM(),
          () async {
        if (_isOfficeCheckin) {
          await markCheckOut(userId);
        }
      },
    );
  }

  // Cancel auto-checkout if user manually checks out
  void _cancelAutoCheckout() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  // Calculate time left until 6 PM
  Duration _calculateTimeUntil6PM() {
    DateTime now = DateTime.now();
    DateTime sixPM = DateTime(now.year, now.month, now.day, 18, 0); // 6 PM
    if (now.isAfter(sixPM)) {
      return Duration.zero;
    }
    return sixPM.difference(now);
  }

  // Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (_isCheckedIn && !_isCheckedOut) {
        markCheckOut(_userId!); // Call markCheckOut when the app is paused
      }
    }
  }
}
