class Employee {
  String id;
  String name;
  double productivity;
  double attendance;

  Employee({required this.id, required this.name, required this.productivity, required this.attendance});

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      name: json['name'] as String,
      productivity: json['productivity'] as double,
      attendance: json['attendance'] as double,
    );
  }
}
