// models/data_models.dart
// Lightweight local models used by the sample UI (presentation-only).

class SystemRequest {
  String id;
  String requester;
  String department;
  String description;
  String priority;
  String status;
  String date;

  SystemRequest({
    required this.id,
    required this.requester,
    required this.department,
    required this.description,
    required this.priority,
    required this.status,
    required this.date,
  });
}

class DepartmentItem {
  final String id;
  final String name;

  DepartmentItem({required this.id, required this.name});
}

class StaffMember {
  final String name;
  final String department;
  final String status;

  StaffMember({
    required this.name,
    required this.department,
    required this.status,
  });
}
