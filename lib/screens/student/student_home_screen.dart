// screens/student/student_home_screen.dart
// Student dashboard — logout removed from app bar, bell icon added instead.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../models/models.dart';                        // ← for NotificationModel
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../student/notifications_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  /// Called with the tab index to switch the bottom nav from outside.
  /// Passed in by UjIsmsShell (same pattern as EmployeeHomeScreen).
  final void Function(int)? onTabSwitch;

  const StudentHomeScreen({super.key, this.onTabSwitch});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    final firestoreService = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<RequestModel>>(
          stream: firestoreService.getUserRequests(user.userId),
          builder: (context, snapshot) {
            final requests = snapshot.data ?? [];
            final pending    = requests.where((r) => r.status == 'Pending').length;
            final inProgress = requests.where((r) => r.status == 'On Progress').length;
            final urgent     = requests.where((r) => r.priority == 'Urgent').length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header with bell icon ──────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UJ ISMS',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'Student Dashboard',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      // ── Bell icon with red dot for unseen notifications ────
                      StreamBuilder<List<NotificationModel>>(
                        stream: firestoreService
                            .getUserNotifications(user.userId),
                        builder: (context, notifSnap) {
                          final unseen = (notifSnap.data ?? [])
                              .where((n) => !n.seen)
                              .length;
                          return Stack(
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: AppColors.primary,
                                  size: 26,
                                ),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationsScreen(
                                      showBackButton: true,
                                    ),
                                  ),
                                ),
                              ),
                              if (unseen > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
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
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  HeroCard(
                    name: user.name,
                    subtitle: 'Manage your university service requests',
                    badge: user.role,
                  ),
                  const SizedBox(height: 16),

                  SummaryStatsRow(
                    pending: pending,
                    inProgress: inProgress,
                    urgent: urgent,
                  ),
                  const SizedBox(height: 20),

                  // ── Quick Actions ──────────────────────────────────────────
                  // Student tab indices (defined in uj_isms.dart):
                  // 0=Home  1=Departments  2=Requests  3=Staff  4=Profile
                  const SectionLabel('Quick Actions'),
                  DashboardCard(
                    title: 'Submit a Request',
                    subtitle: 'Choose a department and submit a service request',
                    icon: Icons.add_circle_outline,
                    highlight: true,
                    onTap: () => onTabSwitch?.call(1), // → Departments
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'My Requests',
                    subtitle: 'Track and manage your submitted requests',
                    icon: Icons.list_alt_outlined,
                    onTap: () => onTabSwitch?.call(2), // → Requests
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'Choose Staff Member',
                    subtitle: 'View availability and select staff for your request',
                    icon: Icons.badge_outlined,
                    onTap: () => onTabSwitch?.call(3), // → Staff
                  ),
                  const SizedBox(height: 20),

                  // ── Recent Requests preview ────────────────────────────────
                  if (requests.isNotEmpty) ...[
                    const SectionLabel('Recent Requests'),
                    ...requests.take(3).map((r) => RequestCard(
                          requestId: r.requestId,
                          requestType: r.requestType,
                          department: r.departmentName,
                          status: r.status,
                          priority: r.priority,
                          date: _formatDate(r.date),
                          assignedStaff: r.assignedStaffName,
                          onTap: () => _openRequestDetails(context, r),
                        )),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openRequestDetails(BuildContext context, RequestModel r) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _RequestDetailPage(request: r)),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}

// ── Request detail page ───────────────────────────────────────────────────────
class _RequestDetailPage extends StatelessWidget {
  final RequestModel request;
  const _RequestDetailPage({required this.request});

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
                      Text(request.requestId,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textDark)),
                      StatusBadge(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(request.requestType,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(request.departmentName,
                      style: const TextStyle(color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  Row(children: [
                    _infoBox('Priority', request.priority),
                    const SizedBox(width: 10),
                    _infoBox('Assigned', request.assignedStaffName),
                  ]),
                  const SizedBox(height: 16),
                  const Text('Description',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMid,
                          fontSize: 12)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(request.description,
                        style: const TextStyle(
                            fontSize: 14, height: 1.5, color: Colors.black87)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(child: PriorityBadge(priority: request.priority)),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMid,
                    letterSpacing: 0.5)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}