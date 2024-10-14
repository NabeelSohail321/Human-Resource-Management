class Manager {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String departmentName;
  final String managerNumber;
  final String role;
  final String status;

  Manager({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.departmentName,
    required this.managerNumber,
    required this.role,
    required this.status,
  });
}

class Employee {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String departmentName;
  final String role;
  final String status;

  Employee({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.departmentName,
    required this.role,
    required this.status,
  });

  // Factory method to create an Employee object from a map
  factory Employee.fromMap(Map<dynamic, dynamic> data, String uid) {
    return Employee(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      departmentName: data['departmentName'] ?? '',
      role: data['role'] ?? '',
      status: data['user status'] ?? '',
    );
  }

  // Method to convert an Employee object to a map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'departmentName': departmentName,
      'role': role,
      'user status': status,
    };
  }
}

