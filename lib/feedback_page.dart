import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _feedbackController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _addFeedback() async {
    final feedback = _feedbackController.text;
    if (feedback.isNotEmpty) {
      await _database.child('feedback').push().set({
        'feedback': feedback,
        'createdAt': DateTime.now().toString(),
      });
      _feedbackController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback')),
      body: Column(
        children: [
          TextField(controller: _feedbackController, decoration: InputDecoration(labelText: 'Enter your feedback')),
          ElevatedButton(onPressed: _addFeedback, child: Text('Add Feedback')),
          Expanded(
            child: StreamBuilder(
              stream: _database.child('feedback').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final feedbacks = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  return ListView.builder(
                    itemCount: feedbacks.length,
                    itemBuilder: (context, index) {
                      final feedback = feedbacks.values.elementAt(index)['feedback'];
                      return ListTile(title: Text(feedback));
                    },
                  );
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
