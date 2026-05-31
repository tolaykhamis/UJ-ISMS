// screens/employee/employee_home_screen.dart
// Same layout as StudentHomeScreen, with an extra "Contact Staff" card.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';
import '../auth/sign_in_screen.dart';

class EmployeeHomeScreen extends StatelessWidget {
  const EmployeeHomeScreen({super.key});

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
            final pending = requests.where((r) => r.status == 'Pending').length;
            final inProgress = requests.where((r) => r.status == 'On Progress').length;
            final urgent = requests.where((r) => r.priority == 'Urgent').length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
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
                      IconButton(
                        icon: const Icon(Icons.logout, color: AppColors.primary),
                        onPressed: () => LogoutDialog.show(context, () async {
                          await AuthService().signOut();
                          context.read<UserProvider>().clearUser();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const SignInScreen()),
                            (route) => false,
                          );
                        }),
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

                  const SectionLabel('Quick Actions'),
                  DashboardCard(
                    title: 'Submit a Request',
                    subtitle: 'Choose a department and submit',
                    icon: Icons.add_circle_outline,
                    highlight: true,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'My Requests',
                    subtitle: 'Track and manage your submitted requests',
                    icon: Icons.list_alt_outlined,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  // Employee-only: Contact Staff
                  DashboardCard(
                    title: 'Contact Staff Member',
                    subtitle: 'Message or call staff for urgent cases',
                    icon: Icons.chat_bubble_outline,
                    onTap: () {},
                  ),
                  const SizedBox(height: 10),
                  DashboardCard(
                    title: 'Notifications',
                    subtitle: 'View updates on your requests',
                    icon: Icons.notifications_outlined,
                    onTap: () {},
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
