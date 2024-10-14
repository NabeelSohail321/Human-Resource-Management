class Goal {
  final String id;
  final String title;
  final String status;

  Goal({required this.id, required this.title, this.status = 'not_started'});
}

class Employee {
  final String id;
  final String name;
  List<Goal> assignedGoals;

  Employee({required this.id, required this.name, this.assignedGoals = const []});
}
