import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/scheduler.dart'; // Import SchedulerBinding
import '../Models/goalmodels.dart';

class GoalsProvider with ChangeNotifier {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance
      .ref()
      .child('Goals'); // Reference to the Goals node
  List<Goal> _goals = [];
  List<dynamic> _employeeGoals = [];

  List<dynamic> get employyeGoals => _employeeGoals;

  List<Goal> get goals => _goals;
  String? currentManagerId; // Change to nullable
  int get totalGoalsCount => _goals.length;

  Future<void> addGoal(Goal newGoal) async {
    final DatabaseReference goalsRef =
        FirebaseDatabase.instance.ref().child('Goals');

    try {
      // Generate a unique key using push()
      final newGoalRef =
          goalsRef.push(); // This generates a unique ID for the new goal
      newGoal.id =
          newGoalRef.key!; // Set the generated ID to the goal's id property

      // Save the goal using the generated ID
      await newGoalRef.set(newGoal.toJson());
      _goals.add(newGoal);

      _goals.sort((a, b) => b.dateTime.compareTo(a.dateTime));

      notifyListeners(); // Notify listeners that the state has changed
    } catch (e) {
      throw Exception('Failed to add goal: $e');
    }
  }


  Future<void> fetchEmployeeGoals(String uid, BuildContext context) async {
    _employeeGoals.clear();

    try {
      await _databaseReference
          .orderByChild('assignedEmployeeId')
          .equalTo(uid)
          .onValue
          .listen((event) {
        final employeeGoalsData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (employeeGoalsData != null && employeeGoalsData.isNotEmpty) {
          _employeeGoals = employeeGoalsData.values.toList();



          // Current time for deadline checks
          DateTime now = DateTime.now();

          // Check deadlines and update status if needed
          for (var goal in _employeeGoals) {
            DateTime deadline = DateTime.parse(goal['deadline']);
            if (now.isAfter(deadline) && !goal['isCompleted']) {
              goal['status'] = 'Failed'; // Update status to Failed if deadline has passed
            }
          }

          // Sort goals by 'dateTime' in descending order
          _employeeGoals.sort((a, b) {
            final dateTimeA = DateTime.parse(a['dateTime']);
            final dateTimeB = DateTime.parse(b['dateTime']);
            return dateTimeB.compareTo(dateTimeA); // Most recent first
          });
          notifyListeners(); // Notify listeners after updating goals
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No Goals Assigned to Employee')));
        }
      });
    } catch (e) {
      print('Error fetching goals: $e');
    }
  }


  void fetchGoals() async {
    try {
      // Clear previous goals
      _goals.clear();
      // Listen for changes in the Goals node
      _databaseReference.onValue.listen((event) {
        final goalsData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (goalsData != null) {
          _goals = goalsData.entries.map((entry) {
            final goalData = entry.value as Map<dynamic, dynamic>;
            return Goal.fromJson(goalData, entry.key);
          }).toList();
          // Sort the goals by dateTime in descending order to show the latest goals first
          _goals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          // Use SchedulerBinding to notify listeners after the current frame
          SchedulerBinding.instance.addPostFrameCallback((_) {
            notifyListeners(); // Notify listeners when goals are fetched
          });
        }
      });
    } catch (e) {
      print('Error fetching goals: $e');
    }
  }

  // Method to fetch the current user's manager ID
  Future<void> fetchCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser; // Get current user

    if (user != null) {
      // Here you would normally fetch user details from your database
      currentManagerId =
          user.uid; // Example: Replace this with your logic to fetch managerId

      // Log the fetched current manager ID
      print("Current Manager ID: $currentManagerId");
    } else {
      // Handle the case where the user is not logged in
      currentManagerId = null;
      print("No user is logged in.");
    }
  }

  Future<void> fetchGoalsbymanager() async {
    if (currentManagerId == null)
      return; // Do not proceed if no manager ID is available

    print("Fetching goals for manager ID: $currentManagerId"); // Debug log

    _databaseReference
        .orderByChild("managerId")
        .equalTo(currentManagerId)
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        _goals = data.entries.map((entry) {
          return Goal.fromJson(entry.value as Map<dynamic, dynamic>, entry.key);
        }).toList();
        // Sort goals by dateTime in descending order
        _goals.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        print("Goals fetched: ${_goals.length}"); // Log number of goals fetched
      } else {
        _goals = []; // No goals found
        print("No goals found for the current manager ID.");
      }
      notifyListeners();
    });
  }

  Future<void> initialize() async {
    await fetchCurrentUserId(); // Fetch the current user's manager ID
    await fetchGoalsbymanager(); // Then fetch goals
  }

  Future<void> assignGoalToEmployee(Goal goal, String employeeUid, DateTime deadline) async {
    try {
      // Update the goal in the database with the selected employee's UID
      await _databaseReference.child(goal.id).update({
        'assignedEmployeeId': employeeUid,
        'deadline': deadline.toIso8601String(), // Add the deadline field in ISO8601 format

        // Add a field to hold the assigned employee's UID
      });
      // Update the goal's local instance
      goal.assignedEmployeeId = employeeUid; // Update local property
      goal.deadline = deadline; // Update local property
      notifyListeners(); // Notify listeners that the goal has been updated
    } catch (e) {
      print('Failed to assign goal to employee: $e');
    }
  }


  Future<void> markGoalAsComplete(String goalId) async {
    try {
      // Get the current date and time
      String completionDateTime = DateTime.now().toIso8601String(); // Format the date/time in ISO 8601 format

      // Update the 'isCompleted' field and 'completionDateTime' in the database for the specified goal
      await _databaseReference.child(goalId).update({
        'isCompleted': true,
        'completionDateTime': completionDateTime, // New field to hold the completion date and time
      });

      // Optionally, update the local list to reflect the change
      for (var goal in _employeeGoals) {
        if (goal['goalId'] == goalId) { // Use the correct field name
          goal['isCompleted'] = true; // Update the local state
          goal['completionDateTime'] = completionDateTime; // Update local completion date and time
          break;
        }
      }
      notifyListeners(); // Notify listeners to rebuild the UI
    } catch (e) {
      print('Error marking goal as complete: $e');
    }
  }

  Future<void> fetchCompletedGoals(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await fetchEmployeeGoals(currentUser.uid, context); // Fetch goals for the current user

      // Filter completed goals
      _employeeGoals = _employeeGoals.where((goal) =>
      goal['assignedEmployeeId'] == currentUser.uid && goal['isCompleted'] == true).toList();

      notifyListeners(); // Notify listeners to update the UI
    } else {
      print('No user is logged in.');
    }
  }

  Future<List<Goal>> fetchGoalsForCurrentEmployee() async {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    if (user != null) {
      final DatabaseReference goalsRef = FirebaseDatabase.instance.ref('Goals');

      // Retrieve the data event
      final DatabaseEvent event = await goalsRef.once();
      final DataSnapshot snapshot = event.snapshot; // Get the DataSnapshot from the event

      List<Goal> goals = [];
      if (snapshot.exists) {
        final goalsMap = snapshot.value as Map<dynamic, dynamic>;

        goalsMap.forEach((key, value) {
          // Use the fromJson factory method to create Goal objects
          final goal = Goal.fromJson(Map<String, dynamic>.from(value), key);
          if (goal.assignedEmployeeId == user.uid) { // Filter by current employee ID
            goals.add(goal);
          }
        });
      }
      return goals;
    }
    return []; // Return an empty list if no user is logged in
  }

  Future<void> fetchCompletedGoalsForManagerId(String managerId) async {
    if (managerId.isEmpty) return; // Early return if managerId is empty

    _goals.clear(); // Clear the existing goals list to avoid duplicates

    try {
      // Listen for changes in the Goals node where managerId matches and isCompleted is true
      _databaseReference
          .orderByChild('managerId')
          .equalTo(managerId)
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          // Filter goals where isCompleted is true
          _goals = data.entries.map((entry) {
            final goalData = entry.value as Map<dynamic, dynamic>;
            // Only include completed goals
            if (goalData['isCompleted'] == true) {
              return Goal.fromJson(goalData, entry.key);
            }
            return null; // Return null for non-completed goals
          }).whereType<Goal>().toList(); // Remove nulls from the list

          print("Completed goals fetched for manager ID $managerId: ${_goals.length}");
        } else {
          _goals = []; // No goals found
          print("No goals found for the manager ID: $managerId.");
        }
        notifyListeners(); // Notify listeners to update the UI
      });
    } catch (e) {
      print('Error fetching completed goals for manager ID $managerId: $e');
    }
  }


  Future<void> markGoalAsRejected(String goalId, String reason) async {
    try {
      // Update the goal status in the database
      await _databaseReference.child(goalId).update({
        'isCompleted': false, // Set isCompleted to false
        'status': 'Rejected',
        'rejectionReason': reason, // Add rejection reason to the database

      });

      // Optionally, update the local goals list
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        _goals[goalIndex].isCompleted = false; // Update local state
        _goals[goalIndex].status = 'Rejected'; // Update local status
        _goals[goalIndex].rejectionReason = reason; // Update local rejection reason

        notifyListeners(); // Notify listeners
      }
    } catch (e) {
      print('Error rejecting goal: $e');
    }
  }


  // In your GoalsProvider class
  Future<void> updateGoalRatingAndFeedback(String goalId, double rating, String feedback) async {
    try {
      await _databaseReference.child(goalId).update({
        'rating': rating,
        'feedback': feedback, // Assuming you have a 'feedback' field in the database
      });

      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        _goals[goalIndex].rating = rating;
        _goals[goalIndex].feedback = feedback;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating goal rating and feedback: $e');
    }
  }







}
