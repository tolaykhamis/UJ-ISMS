import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'providers/user_provider.dart';
import 'constants/app_colors.dart';

import 'screens/student/student_home_screen.dart';
import 'screens/student/choose_department_screen.dart';
import 'screens/student/request_history_screen.dart';
import 'screens/student/choose_staff_screen.dart';

import 'screens/employee/employee_home_screen.dart';
import 'screens/employee/contact_staff_screen.dart';

import 'screens/staff/assigned_requests_screen.dart';
import 'screens/staff/update_status_screen.dart';
import 'screens/staff/manage_priorities_screen.dart';
import 'screens/staff/staff_reports_screen.dart';
import 'screens/staff/staff_messages_screen.dart';

import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/manage_users_screen.dart';
import 'screens/admin/manage_departments_screen.dart';
import 'screens/admin/activity_log_screen.dart';

import 'screens/shared/profile_screen.dart';

class UjIsmsShell extends StatefulWidget {
  const UjIsmsShell({super.key});

  @override
  State<UjIsmsShell> createState() => _UjIsmsShellState();
}

class _UjIsmsShellState extends State<UjIsmsShell> {
  int _currentIndex = 0;

  void switchTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final role = user?.role ?? 'Student';
    final tabs = _buildTabs(role);
    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      body: tabs[safeIndex].screen,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.black38,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        elevation: 12,
        items: tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }

  List<_TabItem> _buildTabs(String role) {
    switch (role) {
      case 'Employee':
        return [
          _TabItem('Home',        Icons.home_outlined,       EmployeeHomeScreen(onTabSwitch: switchTab)),
          _TabItem('Departments', Icons.apartment_outlined,  const ChooseDepartmentScreen()),
          _TabItem('Requests',    Icons.list_alt_outlined,   const RequestHistoryScreen()),
          _TabItem('Contact',     Icons.chat_bubble_outline, const ContactStaffScreen()),
          _TabItem('Profile',     Icons.person_outline,      const ProfileScreen()),
        ];

      case 'Staff':
        return [
          _TabItem('Assigned',   Icons.assignment_outlined, const AssignedRequestsScreen()),
          _TabItem('Status',     Icons.update_outlined,     const UpdateStatusScreen()),
          _TabItem('Messages',   Icons.message_outlined,    const StaffMessagesScreen()),
          _TabItem('Priorities', Icons.flag_outlined,       const ManagePrioritiesScreen()),
          _TabItem('Reports',    Icons.bar_chart_outlined,  const StaffReportsScreen()),
          _TabItem('Profile',    Icons.person_outline,      const ProfileScreen()),
        ];

      case 'Admin':
        return [
          _TabItem('Dashboard',   Icons.dashboard_outlined, AdminDashboardScreen(onSwitchTab: switchTab)),
          _TabItem('Users',       Icons.people_outlined,    const ManageUsersScreen()),
          _TabItem('Departments', Icons.apartment_outlined, const ManageDepartmentsScreen()),
          _TabItem('Activity',    Icons.history_outlined,   const ActivityLogScreen()),
          _TabItem('Profile',     Icons.person_outline,     const ProfileScreen()),
        ];

      default:
        return [
          _TabItem('Home',        Icons.home_outlined,       StudentHomeScreen(onTabSwitch: switchTab)),
          _TabItem('Departments', Icons.apartment_outlined, const ChooseDepartmentScreen()),
          _TabItem('Requests',    Icons.list_alt_outlined,  const RequestHistoryScreen()),
          _TabItem('Staff',       Icons.badge_outlined,     const ChooseStaffScreen()),
          _TabItem('Profile',     Icons.person_outline,     const ProfileScreen()),
        ];
    }
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final Widget screen;
  const _TabItem(this.label, this.icon, this.screen);
}
