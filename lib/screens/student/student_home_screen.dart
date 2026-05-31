// screens/student/student_home_screen.dart
// The main dashboard for students (and employees share a similar layout).
// Shows: welcome hero, request summary stats, and action cards.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/user_provider.dart'; // UserProvider
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../auth/sign_in_screen.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

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

            // Count request stats
            final pending =
                requests.where((r) => r.status == 'Pending').length;
            final inProgress =
                requests.where((r) => r.status == 'On Progress').length;
            final urgent =
                requests.where((r) => r.priority == 'Urgent').length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'UJ ISMS',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Text(
                            'Student Dashboard',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      // Logout button
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.primary),
                        onPressed: () => LogoutDialog.show(context, () async {
                          await AuthService().signOut();
                          context.read<UserProvider>().clearUser();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SignInScreen()),
                            (route) => false,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Welcome hero card
                  HeroCard(
                    name: user.name,
                    subtitle: 'Manage your university service requests',
                    badge: user.role,
                  ),
                  const SizedBox(height: 16),

                  // Summary stats
                  SummaryStatsRow(
                    pending: pending,
                    inProgress: inProgress,
                    urgent: urgent,
                  ),
                  const SizedBox(height: 20),

                  // Action cards
                  const SectionLabel('Quick Actions'),
                  DashboardCard(
                    title: 'Submit a Request',
                    subtitle: 'Choose a department and submit a service request',
                    icon: Icons.add_circle_outline,
                    highlight: true,
                    onTap: () => _goToTab(context, 1), // Departments tab
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'My Requests',
                    subtitle: 'Track and manage your submitted requests',
                    icon: Icons.list_alt_outlined,
                    onTap: () => _goToTab(context, 2), // Requests tab
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'Choose Staff Member',
                    subtitle: 'View availability and select staff for your request',
                    icon: Icons.badge_outlined,
                    onTap: () => _goToTab(context, 3), // Staff tab
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'Notifications',
                    subtitle: 'View updates on your requests',
                    icon: Icons.notifications_outlined,
                    onTap: () => _goToTab(context, 4), // Notifications tab
                  ),
                  const SizedBox(height: 20),

                  // Recent requests preview
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

  // Switch to a specific bottom nav tab
  void _goToTab(BuildContext context, int index) {
    // Find the closest UjIsmsShell and update its index
    // We use a simple approach: navigate to the tab via the parent scaffold
    // In a real app, you could use a GlobalKey or NavigationProvider
    final scaffold = context.findAncestorStateOfType<State>();
    // Simple workaround: emit a tab change event via Navigator
    // For now we just show a snackbar — full tab switching needs GlobalKey on shell
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap the tab in the bottom bar to navigate'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _openRequestDetails(BuildContext context, RequestModel r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RequestDetailPage(request: r),
      ),
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

// Simple request detail page (used inline)
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
            // Header card
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
                      Text(
                        request.requestId,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      StatusBadge(status: request.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    request.requestType,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(request.departmentName,
                      style: const TextStyle(color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  // Info grid
                  Row(children: [
                    _infoBox('Priority', request.priority),
                    const SizedBox(width: 10),
                    _infoBox('Assigned', request.assignedStaffName),
                  ]),
                  const SizedBox(height: 16),
                  // Description
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
            // Priority badge
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
