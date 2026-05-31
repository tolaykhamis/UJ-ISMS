// lib/services/firestore_service.dart
// All Firestore database operations are here.
// The screens call these methods — no Firestore code in the screens.

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/request_model.dart';
import '../models/models.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ═══════════════════════════════════════════════════════════════════════════
  // USERS
  // ═══════════════════════════════════════════════════════════════════════════

  // Get all users (Admin use)
  Stream<List<UserModel>> getAllUsers() {
    return _db.collection('users').snapshots().map((snap) =>
        snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  // Update a user's role (Admin use)
  Future<void> updateUserRole(String userId, String newRole) async {
    await _db.collection('users').doc(userId).update({'role': newRole});
    await _logActivity(userId, 'Role changed to $newRole');
  }

  // Delete a user document (Admin use — does NOT delete Firebase Auth account)
  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DEPARTMENTS
  // ═══════════════════════════════════════════════════════════════════════════

  // Get all departments as a real-time stream
  Stream<List<DepartmentModel>> getDepartments() {
    return _db.collection('departments').snapshots().map((snap) =>
        snap.docs.map((d) => DepartmentModel.fromMap(d.data(), d.id)).toList());
  }

  // Same as getDepartments but returns raw maps — used in dialogs that need the ID
  Stream<List<Map<String, dynamic>>> getDepartmentsAsMap() {
    return _db.collection('departments').snapshots().map((snap) => snap.docs
        .map((d) => {'departmentId': d.id, ...d.data()})
        .toList());
  }

  // Add a new department
  Future<void> addDepartment(String name) async {
    final ref = _db.collection('departments').doc();
    await ref.set({'departmentId': ref.id, 'departmentName': name});
    await _logActivity('admin', 'Department added: $name');
  }

  // Update department name
  Future<void> updateDepartment(String deptId, String newName) async {
    await _db.collection('departments').doc(deptId).update({'departmentName': newName});
    await _logActivity('admin', 'Department updated: $newName');
  }

  // Delete a department
  Future<void> deleteDepartment(String deptId) async {
    await _db.collection('departments').doc(deptId).delete();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REQUESTS
  // ═══════════════════════════════════════════════════════════════════════════

  // Get all requests for a specific user (student/employee view)
  Stream<List<RequestModel>> getUserRequests(String userId) {
    return _db
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RequestModel.fromMap(d.data(), d.id)).toList());
  }

  // Get all requests (admin/staff view)
  Stream<List<RequestModel>> getAllRequests() {
    return _db
        .collection('requests')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RequestModel.fromMap(d.data(), d.id)).toList());
  }

  // Get requests assigned to a specific staff member
  Stream<List<RequestModel>> getStaffRequests(String staffId) {
    return _db
        .collection('requests')
        .where('assignedStaffId', isEqualTo: staffId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => RequestModel.fromMap(d.data(), d.id)).toList());
  }

  // Submit a new request
  Future<String> submitRequest(RequestModel request) async {
    final ref = _db.collection('requests').doc();
    final model = RequestModel(
      requestId: ref.id,
      description: request.description,
      status: 'Pending',
      priority: request.priority,
      date: DateTime.now().toIso8601String(),
      departmentId: request.departmentId,
      departmentName: request.departmentName,
      requestType: request.requestType,
      userId: request.userId,
      userName: request.userName,
    );
    await ref.set(model.toMap());

    // Send notification to user
    await addNotification(
      userId: request.userId,
      message: 'Your request has been submitted successfully.',
      requestId: ref.id,
    );

    await _logActivity(request.userId, 'Request submitted: ${ref.id}');
    return ref.id;
  }

  // Update a request's status
  Future<void> updateRequestStatus(String requestId, String newStatus, String userId) async {
    await _db.collection('requests').doc(requestId).update({'status': newStatus});

    await addNotification(
      userId: userId,
      message: 'Your request status changed to: $newStatus',
      requestId: requestId,
    );

    await _logActivity(userId, 'Request $requestId status updated to $newStatus');
  }

  // Update a request's priority
  Future<void> updateRequestPriority(String requestId, String newPriority) async {
    await _db.collection('requests').doc(requestId).update({'priority': newPriority});
  }

  // Edit request description + priority (user can edit pending requests)
  Future<void> editRequest(String requestId, String description, String priority) async {
    await _db.collection('requests').doc(requestId).update({
      'description': description,
      'priority': priority,
    });
  }

  // Cancel a request
  Future<void> cancelRequest(String requestId, String userId) async {
    await _db.collection('requests').doc(requestId).update({'status': 'Cancelled'});
    await _logActivity(userId, 'Request $requestId cancelled');
  }

  // Mark request as urgent
  Future<void> markUrgent(String requestId) async {
    await _db.collection('requests').doc(requestId).update({
      'priority': 'Urgent',
      'urgent': true,
    });
  }

  // Mark request as seen (Admin)
  Future<void> markSeen(String requestId) async {
    await _db.collection('requests').doc(requestId).update({'seen': true});
  }

  // Forward request to another staff or department
  Future<void> forwardRequest({
    required String requestId,
    required String newStaffId,
    required String newStaffName,
    required String reason,
  }) async {
    await _db.collection('requests').doc(requestId).update({
      'assignedStaffId': newStaffId,
      'assignedStaffName': newStaffName,
    });
    await _logActivity(newStaffId, 'Request $requestId forwarded. Reason: $reason');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NOTIFICATIONS
  // ═══════════════════════════════════════════════════════════════════════════

  // Get notifications for a user as a stream
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => NotificationModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Create a new notification
  Future<void> addNotification({
    required String userId,
    required String message,
    required String requestId,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'message': message,
      'requestId': requestId,
      'date': DateTime.now().toIso8601String(),
      'seen': false,
    });
  }

  // Mark notification as seen
  Future<void> markNotificationSeen(String notifId) async {
    await _db.collection('notifications').doc(notifId).update({'seen': true});
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // MESSAGES (Chat)
  // ═══════════════════════════════════════════════════════════════════════════

  // Get messages between two users as a stream
  Stream<List<MessageModel>> getMessages(String userId, String staffId) {
    // We store messages and fetch both directions
    return _db
        .collection('messages')
        .where('participants', arrayContains: userId)
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromMap(d.data(), d.id))
            .where((m) =>
                (m.senderId == userId && m.receiverId == staffId) ||
                (m.senderId == staffId && m.receiverId == userId))
            .toList());
  }

  // Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    await _db.collection('messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'participants': [senderId, receiverId], // for easy querying
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACTIVITY LOGS
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<ActivityLogModel>> getActivityLogs() {
    return _db
        .collection('activity_logs')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ActivityLogModel.fromMap(d.data(), d.id))
            .toList());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STAFF (users with role = Staff)
  // ═══════════════════════════════════════════════════════════════════════════

  Stream<List<UserModel>> getStaffMembers() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'Staff')
        .snapshots()
        .map((snap) => snap.docs.map((d) => UserModel.fromMap(d.data(), d.id)).toList());
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCESSES
  // ═══════════════════════════════════════════════════════════════════════════

  /// Stream all processes, optionally filtered by department
  Stream<List<Map<String, dynamic>>> getProcesses({String? departmentId}) {
    Query query = _db.collection('processes');
    if (departmentId != null && departmentId.isNotEmpty) {
      query = query.where('departmentId', isEqualTo: departmentId);
    }
    return query.snapshots().map((snap) => snap.docs
        .map((d) => {'processId': d.id, ...d.data() as Map<String, dynamic>})
        .toList());
  }

  /// Add a new process
  Future<void> addProcess({
    required String processName,
    required String departmentId,
    required String adminId,
  }) async {
    final ref = await _db.collection('processes').add({
      'processName': processName,
      'departmentId': departmentId,
    });
    await _logActivity(adminId, 'Process "$processName" added (${ref.id})');
  }

  /// Update an existing process
  Future<void> updateProcess({
    required String processId,
    required String processName,
    required String departmentId,
    required String adminId,
  }) async {
    await _db.collection('processes').doc(processId).update({
      'processName': processName,
      'departmentId': departmentId,
    });
    await _logActivity(adminId, 'Process $processId updated to "$processName"');
  }

  /// Delete a process
  Future<void> deleteProcess({
    required String processId,
    required String adminId,
  }) async {
    await _db.collection('processes').doc(processId).delete();
    await _logActivity(adminId, 'Process $processId deleted');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPER
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _logActivity(String userId, String action) async {
    await _db.collection('activity_logs').add({
      'action': action,
      'userId': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
