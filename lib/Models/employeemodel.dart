class Employee {
  final String uid;
  final String name;
  // Add more fields as needed

  Employee({required this.uid, required this.name});

  factory Employee.fromMap(Map<String, dynamic> data) {
    return Employee(
      uid: data['uid'],
      name: data['name'],
    );
  }
}
