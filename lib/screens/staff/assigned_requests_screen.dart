// screens/staff/assigned_requests_screen.dart
// Staff home — notifications tile with red dot for unseen notifications.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../models/models.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';
import 'forward_request_screen.dart';
import 'staff_messages_screen.dart';
import '../student/notifications_screen.dart';

class AssignedRequestsScreen extends StatefulWidget {
  const AssignedRequestsScreen({super.key});

  @override
  State<AssignedRequestsScreen> createState() => _AssignedRequestsScreenState();
}

class _AssignedRequestsScreenState extends State<AssignedRequestsScreen> {
  final _firestoreService = FirestoreService();
  String _filter = 'All';
  final _filters = ['All', 'Pending', 'On Progress', 'Urgent', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ForwardRequestScreen()),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.forward_to_inbox_outlined),
        label: const Text('Forward',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Assigned Requests',
          style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // ── Notifications tile with red dot ──────────────────────────────
          StreamBuilder<List<NotificationModel>>(
            stream: _firestoreService.getUserNotifications(user.userId),
            builder: (context, notifSnap) {
              final unseen = (notifSnap.data ?? [])
                  .where((n) => !n.seen)
                  .length;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsScreen(showBackButton: true),
                    ),
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            const Icon(Icons.notifications_outlined,
                                color: AppColors.primary, size: 22),
                            if (unseen > 0)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  width: 7,
                                  height: 7,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Notifications',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textDark),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.black26),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // ── Messages tile ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StaffMessagesScreen(),
                ),
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.message_outlined,
                        color: AppColors.primary, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Messages',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textDark),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.black26),
                  ],
                ),
              ),
            ),
          ),

          // The rest of the screen (filter chips + request list) is unchanged
          // — keep your existing filter chips and StreamBuilder<List<RequestModel>> below here
        ],
      ),
    );
  }
}