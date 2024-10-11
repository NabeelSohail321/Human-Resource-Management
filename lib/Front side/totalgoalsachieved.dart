import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class totalgoalsforEmployee extends StatefulWidget {
  const totalgoalsforEmployee({super.key});

  @override
  State<totalgoalsforEmployee> createState() => _totalgoalsforEmployeeState();
}

class _totalgoalsforEmployeeState extends State<totalgoalsforEmployee> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("YOUR GOALS"),
      ),
    );
  }
}
