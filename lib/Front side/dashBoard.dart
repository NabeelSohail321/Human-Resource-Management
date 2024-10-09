import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/usermodel.dart';
import 'drawerfile.dart';
import 'goalsettingPage.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawerfrontside(),
        appBar: AppBar(
          title: Text('Dashboard'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Welcome to the Dashboard'),
              SizedBox(height: 20),

              // Use Consumer to listen for changes in UserModel
              Consumer<UserModel>(
                builder: (context, userModel, child) {
                  if (userModel.currentUser == null) {
                    return Text('Loading user data...');
                  } else if (userModel.role == null) {
                    return Text('Role not found.');
                  } else {
                    return Text('Your Role: ${userModel.role == 0 ? "HR" : userModel.role == 1 ? "Employee" : "Manager"}');
                  }
                },
              ),

              SizedBox(height: 20),

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
      ),
    );
  }
}
