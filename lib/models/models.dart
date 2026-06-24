class DepartmentModel {
  final String departmentId;
  final String departmentName;

  DepartmentModel({required this.departmentId, required this.departmentName});

  factory DepartmentModel.fromMap(Map<String, dynamic> map, String id) {
    return DepartmentModel(
      departmentId: id,
      departmentName: map['departmentName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'departmentId': departmentId,
        'departmentName': departmentName,
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepartmentModel && other.departmentId == departmentId;
  }

  @override
  int get hashCode => departmentId.hashCode;
}

class NotificationModel {
  final String notificationId;
  final String message;
  final String date;
  final String userId;
  final String requestId;
  bool seen;

  NotificationModel({
    required this.notificationId,
    required this.message,
    required this.date,
    required this.userId,
    required this.requestId,
    this.seen = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      notificationId: id,
      message: map['message'] ?? '',
      date: map['date'] ?? '',
      userId: map['userId'] ?? '',
      requestId: map['requestId'] ?? '',
      seen: map['seen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'message': message,
        'date': date,
        'userId': userId,
        'requestId': requestId,
        'seen': seen,
      };
}

class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String message;
  final String timestamp;
  final String senderName;
  final String receiverName;
  final bool isRead;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.senderName = '',
    this.receiverName = '',
    this.isRead = false,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      messageId: id,
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] ?? '',
      senderName: map['senderName'] ?? '',
      receiverName: map['receiverName'] ?? '',
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'senderId': senderId,
        'receiverId': receiverId,
        'message': message,
        'timestamp': timestamp,
        'senderName': senderName,
        'receiverName': receiverName,
        'isRead': isRead,
      };
}

class ActivityLogModel {
  final String logId;
  final String action;
  final String userId;
  final String timestamp;

  ActivityLogModel({
    required this.logId,
    required this.action,
    required this.userId,
    required this.timestamp,
  });

  factory ActivityLogModel.fromMap(Map<String, dynamic> map, String id) {
    return ActivityLogModel(
      logId: id,
      action: map['action'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: map['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'action': action,
        'userId': userId,
        'timestamp': timestamp,
      };
}
