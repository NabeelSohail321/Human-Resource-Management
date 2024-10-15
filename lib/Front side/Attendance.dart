import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Providers/AttendanceProvider.dart';

class AttendanceScreen extends StatelessWidget {
  final String userId;

  AttendanceScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    User? user = FirebaseAuth.instance.currentUser;
    
    

    // Check attendance status when the screen loads
    attendanceProvider.checkAttendanceStatus(userId);

    return user!=null? Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!attendanceProvider.isCheckedIn) ...[
              ElevatedButton(
                onPressed: () async {
                  try {
                    await attendanceProvider.markCheckIn(userId, false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Checked in at office")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text('Check In (Office)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await attendanceProvider.markCheckIn(userId, true);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Checked in remotely")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text('Check In (Remote)'),
              ),
            ],
            if (!attendanceProvider.isCheckedOut && attendanceProvider.isCheckedIn) ...[
              ElevatedButton(
                onPressed: () async {
                  try {
                    await attendanceProvider.markCheckOut(userId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Checked out")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
                child: Text('Check Out'),
              ),
            ],
          ],
        ),
      ),
    ):Scaffold(
      body: Center(child: Text('Please Login')),
    );
  }
}
