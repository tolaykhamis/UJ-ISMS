// screens/employee/employee_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../models/models.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../auth/sign_in_screen.dart';
import '../student/notifications_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  /// Called with the tab index to switch the bottom nav from outside.
  final void Function(int)? onTabSwitch;

  const EmployeeHomeScreen({super.key, this.onTabSwitch});

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
                  // ── Header ────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('UJ ISMS',
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0)),
                          Text('Employee Dashboard',
                              style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),

                      // Bell icon only — pushes NotificationsScreen with back button
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
                                    color: AppColors.primary),
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

                  // ── Quick Actions ─────────────────────────────────────
                  const SectionLabel('Quick Actions'),

                  // Employee tab indices:
                  // 0=Home  1=Departments  2=Requests  3=Contact  4=Profile
                  DashboardCard(
                    title: 'Submit a Request',
                    subtitle: 'Choose a department and submit',
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
                    title: 'Contact Staff Member',
                    subtitle: 'Message or call staff for urgent cases',
                    icon: Icons.chat_bubble_outline,
                    onTap: () => onTabSwitch?.call(3), // → Contact
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'Notifications',
                    subtitle: 'View updates on your requests',
                    icon: Icons.notifications_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(
                          showBackButton: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}