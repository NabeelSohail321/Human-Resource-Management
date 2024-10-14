// class Goal {
//   final String id; // Unique ID of the goal
//   final String mdId; // ID of the user assigning the goal
//   final String managerId; // ID of the selected manager
//   final String managerName; // Name of the selected manager
//   final String managerNumber; // Number of the selected manager
//   final String departmentName; // Department name of the selected manager
//   final String description; // Description of the goal
//   final DateTime dateTime; // Date and time of assignment
//
//   Goal({
//     required this.id,
//     required this.mdId,
//     required this.managerId,
//     required this.managerName,
//     required this.managerNumber,
//     required this.departmentName,
//     required this.description,
//     required this.dateTime,
//   });
//
//   Map<String, dynamic> toJson() {
//     return {
//       'goalId':id,
//       'mdId': mdId,
//       'managerId': managerId,
//       'managerName': managerName,
//       'managerNumber': managerNumber,
//       'departmentName': departmentName,
//       'description': description,
//       'dateTime': dateTime.toIso8601String(), // Convert DateTime to string
//     };
//   }
// }


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
}
