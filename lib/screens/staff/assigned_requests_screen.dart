// screens/staff/assigned_requests_screen.dart
// Staff home — notifications added as a list tile at the top.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../models/models.dart';                        // ← for NotificationModel
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
          // ── Notifications tile with red dot ───────────────────────────────
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        // Bell icon with red dot
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_outlined,
                                color: AppColors.primary, size: 22),
                            if (unseen > 0)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
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

          // ── Messages tile ─────────────────────────────────────────────────
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

          // ── Filter chips ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilterChips(
              options: _filters,
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
          ),

          // ── Request list ──────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<RequestModel>>(
              stream: _firestoreService.getStaffRequests(user.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var requests = snapshot.data ?? [];
                if (_filter == 'Urgent') {
                  requests =
                      requests.where((r) => r.priority == 'Urgent').toList();
                } else if (_filter != 'All') {
                  requests =
                      requests.where((r) => r.status == _filter).toList();
                }

                if (requests.isEmpty) {
                  return const EmptyState(
                      message: 'No assigned requests found.');
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, i) {
                    final r = requests[i];
                    return RequestCard(
                      requestId: r.requestId,
                      requestType: r.requestType,
                      department: r.departmentName,
                      status: r.status,
                      priority: r.priority,
                      date: r.date.substring(0, 10),
                      assignedStaff: r.assignedStaffName,
                      onTap: () {},
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}