
class Goal {
  String id; // This will hold the Firebase-generated ID
  String mdId;
  String managerId;
  String managerName;
  String managerNumber;
  String departmentName;
  String description;
  DateTime dateTime;
  String? assignedEmployeeId; // New property to track the assigned employee ID
  bool isCompleted; // This field indicates if the goal is completed
  String? completionDateTime; // Nullable to accommodate not completed goals
  String? status; // Status of the goal (e.g., "Rejected")
  double rating; // Add the rating field
  String feedback; // Add this property
  String? rejectionReason; // Add this line



  Goal({
    required this.id,
    required this.mdId,
    required this.managerId,
    required this.managerName,
    required this.managerNumber,
    required this.departmentName,
    required this.description,
    required this.dateTime,
    this.assignedEmployeeId, // Optional parameter
    this.isCompleted = false, // Default value
    this.completionDateTime,
    this.status, // Initialize status
    this.rating = 0.0, // Initialize rating to 0.0 by default
    this.feedback = '', // Initialize with an empty string
    this.rejectionReason, // Include in the constructor



  });

  Map<String, dynamic> toJson() {
    return {
      'goalId': id,
      'mdId': mdId,
      'managerId': managerId,
      'managerName': managerName,
      'managerNumber': managerNumber,
      'departmentName': departmentName,
      'description': description,
      'dateTime': dateTime.toIso8601String(), // Format to string for Firebase
      'assignedEmployeeId': assignedEmployeeId, // Include in JSON
      'isCompleted': isCompleted, // Include this field in toJson
      'completionDateTime': completionDateTime, // Include this field in toJson
      'status': status, // Include status in toJson
      'rating': rating, // Include rating in the JSON
      'feedback': feedback, // Include feedback in the JSON object
      'rejectionReason': rejectionReason, // Include feedback in the JSON object


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
      assignedEmployeeId: json['assignedEmployeeId'], // Handle assigned employee ID
      isCompleted: json['isCompleted'] ?? false, // Initialize from JSON
      completionDateTime: json['completionDateTime'] ?? '',
      status: json['status'], // Include status in the fromJson method
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0, // Parse rating from JSON
      feedback: json['feedback'] ?? '', // Ensure feedback is retrieved
      rejectionReason: json['rejectionReason'] ?? '', // Ensure feedback is retrieved

    );
  }
}

