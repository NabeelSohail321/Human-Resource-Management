import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../Providers/goalprovider.dart';
import '../components.dart';

class CompletedGoalsForManager extends StatefulWidget {
  const CompletedGoalsForManager({super.key});

  @override
  State<CompletedGoalsForManager> createState() => _CompletedGoalsForManagerState();
}

class _CompletedGoalsForManagerState extends State<CompletedGoalsForManager> {
  late GoalsProvider goalsProvider;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    goalsProvider = Provider.of<GoalsProvider>(context);

    return Scaffold(
      appBar: CustomAppBar.customAppBar("Completed Goals"),

      body: FutureBuilder(
        future: goalsProvider.fetchGoalsbymanager(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final completedGoals = goalsProvider.goals.where((goal) => goal.isCompleted).toList();

            if (completedGoals.isEmpty) {
              return const Center(child: Text('No completed goals found for this manager.'));
            }

            return ListView.builder(
              itemCount: completedGoals.length,
              itemBuilder: (context, index) {
                final goal = completedGoals[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      "Completed On: ${goal.completionDateTime}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description: ${goal.description}",
                          style: TextStyle(fontSize: 20),
                        ),
                        Text("Manager Name: ${goal.managerName}"),
                        Text("GoalId: ${goal.id}"),
                        const SizedBox(height: 8),
                        Text(
                          "Rating: ${goal.rating}",
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          "Feedback: ${goal.feedback ?? 'No feedback provided'}",
                          style: TextStyle(fontSize: 16),
                        ),

                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () async {
                            await _rejectGoal(goal.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.star),
                          onPressed: () {
                            _showRatingDialog(goal.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _rejectGoal(String goalId) async {
    String? rejectionReason = await _showRejectionReasonDialog();

    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      await goalsProvider.markGoalAsRejected(goalId, rejectionReason);
      setState(() {});
    } else {
      // Optionally show a message that the reason is required
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rejection reason is required to reject the goal.')),
      );
    }
  }

// Show dialog to get the rejection reason
  Future<String?> _showRejectionReasonDialog() async {
    String? reason;
    TextEditingController reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rejection Reason'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Enter reason for rejection',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without doing anything
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                reason = reasonController.text;
                Navigator.of(context).pop(); // Close the dialog after capturing the reason
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );

    return reason; // Return the reason captured from the text field
  }


  void _showRatingDialog(String goalId) {
    final goal = goalsProvider.goals.firstWhere((goal) => goal.id == goalId);

    // Use the existing rating and feedback from the goal
    double rating = goal.rating;
    TextEditingController feedbackController = TextEditingController(text: goal.feedback);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rate and Give Feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RatingBar.builder(
                initialRating: rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (newRating) {
                  rating = newRating;
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without doing anything
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _submitRatingAndFeedback(goalId, rating, feedbackController.text);
                Navigator.of(context).pop(); // Close the dialog after submission
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitRatingAndFeedback(String goalId, double rating, String feedback) async {
    await goalsProvider.updateGoalRatingAndFeedback(goalId, rating, feedback);
    setState(() {});
  }
}
