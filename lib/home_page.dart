import 'package:flutter/material.dart';
import 'package:human_capital_management/review_page.dart';

import 'auth_page.dart';
import 'feedback_page.dart';
import 'goal_page.dart';


class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HCM Performance Enhancement System')),
      body: ListView(
        children: [
          ListTile(title: Text('Authentication'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage()))),
          ListTile(title: Text('Set Goals'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GoalPage()))),
          ListTile(title: Text('Performance Reviews'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewPage()))),
          ListTile(title: Text('Feedback'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FeedbackPage()))),
          // ListTile(title: Text('Dashboard'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardPage(seriesList: [])))),
        ],
      ),
    );
  }
}
