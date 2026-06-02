// screens/student/notifications_screen.dart
// Shows all notifications for the logged-in user.
// Tapping a notification marks it seen AND navigates to the right screen.
//
// Navigation rules:
//   Student  — any notification with a non-empty requestId  → RequestDetailPage
//   Employee — "New message from …" (requestId empty)       → ContactStaffScreen (pre-select sender)
//   Staff    — "New message from …" (requestId empty)       → StaffMessagesScreen
//            — forwarded-request notification (requestId)   → AssignedRequestsScreen
//
// showBackButton: true  → used when pushed as a page (from bell icon)
// showBackButton: false → legacy tab usage (now unused)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/models.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

// Role-specific screens we navigate to
import '../employee/contact_staff_screen.dart';
import '../staff/staff_messages_screen.dart';
import '../staff/assigned_requests_screen.dart';

class NotificationsScreen extends StatelessWidget {
  final bool showBackButton;

  const NotificationsScreen({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.primary, size: 20),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: firestoreService.getUserNotifications(user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const EmptyState(message: 'No notifications yet.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              return _NotificationCard(
                notification: n,
                service: firestoreService,
                userRole: user.role,
                userId: user.userId,
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final FirestoreService service;
  final String userRole;
  final String userId;

  const _NotificationCard({
    required this.notification,
    required this.service,
    required this.userRole,
    required this.userId,
  });

  /// Decide where to navigate based on role + notification content, then go.
  Future<void> _handleTap(BuildContext context) async {
    // 1. Mark as seen first
    if (!notification.seen) {
      await service.markNotificationSeen(notification.notificationId);
    }

    if (!context.mounted) return;

    final msg = notification.message;
    final requestId = notification.requestId;

    switch (userRole) {
      // ── Student ──────────────────────────────────────────────────────────
      case 'Student':
        // Any student notification links to their request
        if (requestId.isNotEmpty) {
          final req = await service.getRequestById(requestId);
          if (req != null && context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RequestDetailPage(request: req),
              ),
            );
          }
        }
        break;

      // ── Employee ─────────────────────────────────────────────────────────
      case 'Employee':
        // "New message from <name>: …"  → open Contact Staff
        if (msg.startsWith('New message from')) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ContactStaffScreen()),
          );
        }
        break;

      // ── Staff ─────────────────────────────────────────────────────────────
      case 'Staff':
        if (msg.startsWith('New message from')) {
          // Message notification → open Messages screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffMessagesScreen()),
          );
        } else if (requestId.isNotEmpty) {
          // Forwarded-request notification → open Assigned Requests
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AssignedRequestsScreen()),
          );
        }
        break;

      // Admin has no notifications (nothing to navigate to)
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = !notification.seen;

    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // Unseen = teal highlight; Seen = plain white/grey
          color: isNew ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isNew ? AppColors.accent : AppColors.border,
            width: isNew ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon bubble
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isNew
                    ? const Color(0xFFCCFBF1)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: isNew ? AppColors.primary : Colors.black38,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontWeight:
                          isNew ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                      color: isNew
                          ? AppColors.textDark
                          : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.date,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.black38),
                  ),
                ],
              ),
            ),
            // Unseen dot
            if (isNew)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Simple request detail page shown when student taps a notification.
// Reuses the same card styling from the existing codebase.
// ─────────────────────────────────────────────────────────────────────────────

class RequestDetailPage extends StatelessWidget {
  final RequestModel request;
  const RequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Request Details',
          style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(request.requestId,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.textLight)),
                      ),
                      StatusBadge(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(request.requestType,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(request.departmentName,
                      style:
                          const TextStyle(color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  _infoRow('Priority', request.priority),
                  const SizedBox(height: 8),
                  _infoRow('Date', request.date),
                  if (request.assignedStaffName.isNotEmpty &&
                      request.assignedStaffName != 'Unassigned') ...[
                    const SizedBox(height: 8),
                    _infoRow('Assigned to', request.assignedStaffName),
                  ],
                  const SizedBox(height: 16),
                  const Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(request.description,
                      style: const TextStyle(
                          color: AppColors.textLight, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: AppColors.textLight, fontSize: 13)),
      ],
    );
  }
}