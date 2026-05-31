// lib/models/request_model.dart
// Matches the "requests" Firestore collection

class RequestModel {
  final String requestId;
  final String description;
  String status;       // Pending | On Progress | Completed | Cancelled
  String priority;     // Normal | High | Urgent
  final String date;
  final String departmentId;
  final String departmentName;
  final String requestType;
  final String userId;
  final String userName;
  String assignedStaffId;
  String assignedStaffName;
  final String? attachmentUrl;
  bool urgent;
  bool seen;

  RequestModel({
    required this.requestId,
    required this.description,
    required this.status,
    required this.priority,
    required this.date,
    required this.departmentId,
    required this.departmentName,
    required this.requestType,
    required this.userId,
    required this.userName,
    this.assignedStaffId = '',
    this.assignedStaffName = 'Unassigned',
    this.attachmentUrl,
    this.urgent = false,
    this.seen = false,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map, String id) {
    return RequestModel(
      requestId: id,
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      priority: map['priority'] ?? 'Normal',
      date: map['date'] ?? '',
      departmentId: map['departmentId'] ?? '',
      departmentName: map['departmentName'] ?? '',
      requestType: map['requestType'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      assignedStaffId: map['assignedStaffId'] ?? '',
      assignedStaffName: map['assignedStaffName'] ?? 'Unassigned',
      attachmentUrl: map['attachmentUrl'],
      urgent: map['urgent'] ?? false,
      seen: map['seen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'description': description,
      'status': status,
      'priority': priority,
      'date': date,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'requestType': requestType,
      'userId': userId,
      'userName': userName,
      'assignedStaffId': assignedStaffId,
      'assignedStaffName': assignedStaffName,
      'attachmentUrl': attachmentUrl,
      'urgent': urgent,
      'seen': seen,
    };
  }
}
