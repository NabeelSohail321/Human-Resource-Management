import 'package:flutter/material.dart';
import 'goalsettingPage.dart';


class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Welcome to the Dashboard'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => GoalSettingPage()),
                );
              },
              child: Text('Manage Goals'),
            ),
            // Add more buttons for other functionalities
          ],
        ),
      ),
    );
  }
}
