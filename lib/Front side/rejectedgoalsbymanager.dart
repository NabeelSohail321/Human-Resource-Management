import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Providers/goalprovider.dart';
import '../components.dart'; // Adjust the path to your Goal model

class RejectedGoalsPage extends StatefulWidget {
  const RejectedGoalsPage({super.key});

  @override
  State<RejectedGoalsPage> createState() => _RejectedGoalsPageState();
}

class _RejectedGoalsPageState extends State<RejectedGoalsPage> {
  late GoalsProvider goalsProvider;

  @override
  void initState() {
    super.initState();
    // Initialize fetching rejected goals if needed
  }

  @override
  Widget build(BuildContext context) {
    // Access the GoalsProvider using Provider
    goalsProvider = Provider.of<GoalsProvider>(context);

    return Scaffold(
      appBar: CustomAppBar.customAppBar("Rejected Goals"),

      body: FutureBuilder(
        future: goalsProvider.fetchGoalsbymanager(), // Fetch goals based on current manager
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
          } else {
            // Filter rejected goals
            final rejectedGoals = goalsProvider.goals.where((goal) => goal.status == 'Rejected').toList();

            if (rejectedGoals.isEmpty) {
              return const Center(child: Text('No rejected goals found.'));
            }

            return ListView.builder(
              itemCount: rejectedGoals.length,
              itemBuilder: (context, index) {
                final goal = rejectedGoals[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      "Rejected On: ${goal.completionDateTime}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description: ${goal.description}", style: const TextStyle(fontSize: 20)),
                        Text("Manager Name: ${goal.managerName}"),
                        Text("Reason: ${goal.rejectionReason}"),

                      ],
                    ),
                    // trailing: IconButton(
                    //   onPressed: () {
                    //     // Add any action you want to perform when this button is pressed
                    //   },
                    //   icon: const Icon(Icons.info), // Example icon
                    // ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
