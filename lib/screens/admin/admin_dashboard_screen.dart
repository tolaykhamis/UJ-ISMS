// screens/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';
import 'admin_requests_screen.dart';
import 'manage_processes_screen.dart';
import 'system_reports_screen.dart';
import '../student/notifications_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  /// Called when the user taps a card that maps to a bottom-nav tab.
  /// index: 1=Users, 2=Departments, 3=Activity, 4=Profile
  final void Function(int index)? onSwitchTab;

  const AdminDashboardScreen({super.key, this.onSwitchTab});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: StreamBuilder<List<RequestModel>>(
          stream: service.getAllRequests(),
          builder: (context, snapshot) {
            final requests  = snapshot.data ?? [];
            final total     = requests.length;
            final pending   = requests.where((r) => r.status == 'Pending').length;
            final completed = requests.where((r) => r.status == 'Completed').length;
            final urgent    = requests.where((r) => r.priority == 'Urgent').length;
            final unseen    = requests.where((r) => !r.seen).length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────────
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('UJ ISMS',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0)),
                      Text('Admin Dashboard',
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  HeroCard(
                    name: user.name,
                    subtitle:
                        'System control center — manage all university services',
                    badge: 'Admin',
                  ),
                  const SizedBox(height: 16),

                  // ── Stats grid ───────────────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _StatCard(label: 'Total Requests', value: '$total'),
                      _StatCard(label: 'Pending',        value: '$pending'),
                      _StatCard(label: 'Completed',      value: '$completed'),
                      _StatCard(label: 'Urgent',         value: '$urgent',
                          highlight: urgent > 0),
                    ],
                  ),

                  // ── Unseen banner ────────────────────────────────────────
                  if (unseen > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFED7AA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.mark_email_unread_outlined,
                              color: Color(0xFFC2410C)),
                          const SizedBox(width: 10),
                          Text(
                            '$unseen new unseen request${unseen > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Color(0xFFC2410C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  const SectionLabel('Management'),

                  // ── Manage Users → switches to Users tab (index 1) ───────
                  DashboardCard(
                    title: 'Manage Users',
                    subtitle: 'Create, update, and assign roles',
                    icon: Icons.people_outlined,
                    highlight: true,
                    onTap: () => onSwitchTab?.call(1),
                  ),
                  const SizedBox(height: 10),

                  // ── Manage Departments → switches to Departments tab (index 2)
                  DashboardCard(
                    title: 'Manage Departments',
                    subtitle: 'Add, edit, and delete departments',
                    icon: Icons.apartment_outlined,
                    onTap: () => onSwitchTab?.call(2),
                  ),
                  const SizedBox(height: 10),

                  // ── Manage Processes → pushes a new page ─────────────────
                  DashboardCard(
                    title: 'Manage Processes',
                    subtitle: 'Add processes linked to departments',
                    icon: Icons.account_tree_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManageProcessesScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Seen / Unseen Requests → pushes a new page ───────────
                  DashboardCard(
                    title: 'Seen / Unseen Requests',
                    subtitle: 'Review new and unseen requests',
                    icon: Icons.mark_email_read_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AdminRequestsScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Monitor Activity → switches to Activity tab (index 3) ─
                  DashboardCard(
                    title: 'Monitor Activity',
                    subtitle: 'View login times and system changes',
                    icon: Icons.history_outlined,
                    onTap: () => onSwitchTab?.call(3),
                  ),
                  const SizedBox(height: 10),

                  // ── System Reports → pushes a new page ───────────────────
                  DashboardCard(
                    title: 'System Reports',
                    subtitle: 'Generate and download reports',
                    icon: Icons.bar_chart_outlined,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SystemReportsScreen()),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ── Notifications tile ────────────────────────────────────
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const NotificationsScreen(showBackButton: true),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 3)),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.notifications_outlined,
                              color: AppColors.primary, size: 22),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notifications',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppColors.textDark)),
                                SizedBox(height: 2),
                                Text('View all system notifications',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textLight)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.black26),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final bool highlight;

  const _StatCard(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFFF1F2) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: highlight
                ? const Color(0xFFFFCDD2)
                : AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: highlight
                      ? const Color(0xFFBE123C)
                      : Colors.black45)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: highlight
                      ? const Color(0xFFBE123C)
                      : AppColors.primary)),
        ],
      ),
    );
  }
}