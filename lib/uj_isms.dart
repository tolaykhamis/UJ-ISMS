// uj_isms.dart
// The main shell of the app AFTER login.
// Shows a bottom navigation bar with tabs that differ based on user role.
// This replaces the old uj_isms.dart placeholder.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/user_provider.dart';
import 'constants/app_colors.dart';

// Student screens
import 'screens/student/student_home_screen.dart';
import 'screens/student/choose_department_screen.dart';
import 'screens/student/request_history_screen.dart';
import 'screens/student/choose_staff_screen.dart';
import 'screens/student/notifications_screen.dart';

// Employee screens
import 'screens/employee/employee_home_screen.dart';
import 'screens/employee/contact_staff_screen.dart';

// Staff screens
import 'screens/staff/assigned_requests_screen.dart';
import 'screens/staff/update_status_screen.dart';
import 'screens/staff/manage_priorities_screen.dart';
import 'screens/staff/staff_reports_screen.dart';
import 'screens/staff/staff_messages_screen.dart';

// Admin screens
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/manage_departments_screen.dart';
import 'screens/admin/activity_log_screen.dart';
import 'screens/admin/system_reports_screen.dart';

class UjIsmsShell extends StatefulWidget {
  const UjIsmsShell({super.key});

  @override
  State<UjIsmsShell> createState() => _UjIsmsShellState();
}

class _UjIsmsShellState extends State<UjIsmsShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Get the logged-in user
    final user = context.watch<UserProvider>().user;
    final role = user?.role ?? 'Student';

    // Build the correct tabs and screens for this role
    final tabs = _buildTabs(role);

    return Scaffold(
      // Show the screen matching the selected tab
      body: tabs[_currentIndex].screen,

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black38,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 12,
        items: tabs.map((tab) => BottomNavigationBarItem(
          icon: Icon(tab.icon),
          label: tab.label,
        )).toList(),
      ),
    );
  }

  // Returns the correct set of tabs based on role
  List<_TabItem> _buildTabs(String role) {
    switch (role) {
      case 'Employee':
        return [
          _TabItem('Home', Icons.home_outlined, const EmployeeHomeScreen()),
          _TabItem('Departments', Icons.apartment_outlined, const ChooseDepartmentScreen()),
          _TabItem('Requests', Icons.list_alt_outlined, const RequestHistoryScreen()),
          _TabItem('Contact', Icons.chat_bubble_outline, const ContactStaffScreen()),
          _TabItem('Notify', Icons.notifications_outlined, const NotificationsScreen()),
        ];

      case 'Staff':
        return [
          _TabItem('Assigned', Icons.assignment_outlined, const AssignedRequestsScreen()),
          _TabItem('Status', Icons.update_outlined, const UpdateStatusScreen()),
          _TabItem('Priorities', Icons.flag_outlined, const ManagePrioritiesScreen()),
          _TabItem('Reports', Icons.bar_chart_outlined, const StaffReportsScreen()),
          _TabItem('Messages', Icons.message_outlined, const StaffMessagesScreen()),
        ];

      case 'Admin':
        return [
          _TabItem('Dashboard', Icons.dashboard_outlined, const AdminDashboardScreen()),
          _TabItem('Users', Icons.people_outlined, const ManageUsersScreen()),
          _TabItem('Departments', Icons.apartment_outlined, const ManageDepartmentsScreen()),
          _TabItem('Activity', Icons.history_outlined, const ActivityLogScreen()),
          _TabItem('Reports', Icons.bar_chart_outlined, const SystemReportsScreen()),
        ];

      default: // Student
        return [
          _TabItem('Home', Icons.home_outlined, const StudentHomeScreen()),
          _TabItem('Departments', Icons.apartment_outlined, const ChooseDepartmentScreen()),
          _TabItem('Requests', Icons.list_alt_outlined, const RequestHistoryScreen()),
          _TabItem('Staff', Icons.badge_outlined, const ChooseStaffScreen()),
          _TabItem('Notify', Icons.notifications_outlined, const NotificationsScreen()),
        ];
    }
  }
}

// Simple data class to hold a tab's info
class _TabItem {
  final String label;
  final IconData icon;
  final Widget screen;

  const _TabItem(this.label, this.icon, this.screen);
}
