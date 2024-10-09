import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final _reviewController = TextEditingController();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _addReview() async {
    final review = _reviewController.text;
    if (review.isNotEmpty) {
      await _database.child('reviews').push().set({
        'review': review,
        'createdAt': DateTime.now().toString(),
      });
      _reviewController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Performance Reviews')),
      body: Column(
        children: [
          TextField(controller: _reviewController, decoration: InputDecoration(labelText: 'Enter your review')),
          ElevatedButton(onPressed: _addReview, child: Text('Add Review')),
          Expanded(
            child: StreamBuilder(
              stream: _database.child('reviews').onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  final reviews = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  return ListView.builder(
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews.values.elementAt(index)['review'];
                      return ListTile(title: Text(review));
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
