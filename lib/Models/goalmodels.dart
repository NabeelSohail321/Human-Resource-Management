class Goal {
  String id; // This will hold the Firebase-generated ID
  String mdId;
  String managerId;
  String managerName;
  String managerNumber;
  String departmentName;
  String description;
  DateTime dateTime;

  Goal({
    required this.id,
    required this.mdId,
    required this.managerId,
    required this.managerName,
    required this.managerNumber,
    required this.departmentName,
    required this.description,
    required this.dateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'goalId':id,
      'mdId': mdId,
      'managerId': managerId,
      'managerName': managerName,
      'managerNumber': managerNumber,
      'departmentName': departmentName,
      'description': description,
      'dateTime': dateTime.toIso8601String(), // Format to string for Firebase
    };
  }
  // Factory method to create a Goal object from a JSON map
  factory Goal.fromJson(Map<dynamic, dynamic> json, String id) {
    return Goal(
      id: id,
      mdId: json['mdId'] ?? '',
      managerId: json['managerId'] ?? '',
      managerName: json['managerName'] ?? '',
      managerNumber: json['managerNumber'] ?? '',
      departmentName: json['departmentName'] ?? '',
      description: json['description'] ?? '',
      dateTime: DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()), // Handle date parsing
    );
  }
}
