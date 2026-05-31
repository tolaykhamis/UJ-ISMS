// lib/widgets/app_widgets.dart
// All reusable widgets for UJ ISMS in one file.
// Import this file in any screen that needs shared UI components.

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// GRADIENT BUTTON — the main teal button used across the app
// ═══════════════════════════════════════════════════════════════════════════
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 54,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0C6B5F), Color(0xFF043933)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS BADGE — coloured pill for request status
// ═══════════════════════════════════════════════════════════════════════════
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (status) {
      case 'Pending':
        bg = AppColors.pending; text = AppColors.pendingText; break;
      case 'On Progress':
        bg = AppColors.inProgress; text = AppColors.inProgressText; break;
      case 'Completed':
        bg = AppColors.completed; text = AppColors.completedText; break;
      default: // Cancelled
        bg = AppColors.cancelled; text = AppColors.cancelledText;
    }
    return _BadgePill(label: status, bg: bg, textColor: text);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PRIORITY BADGE — coloured pill for request priority
// ═══════════════════════════════════════════════════════════════════════════
class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (priority) {
      case 'Urgent':
        bg = AppColors.urgent; text = AppColors.urgentText; break;
      case 'High':
        bg = AppColors.high; text = AppColors.highText; break;
      default: // Normal
        bg = AppColors.normal; text = AppColors.normalText;
    }
    return _BadgePill(label: priority, bg: bg, textColor: text);
  }
}

// Shared internal pill widget
class _BadgePill extends StatelessWidget {
  final String label;
  final Color bg, textColor;

  const _BadgePill({required this.label, required this.bg, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HERO CARD — welcome card at top of dashboard screens
// ═══════════════════════════════════════════════════════════════════════════
class HeroCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String badge;

  const HeroCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mini UJ badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome, $name',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD CARD — action card with icon, title, subtitle
// ═══════════════════════════════════════════════════════════════════════════
class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool highlight;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            // Icon circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: highlight ? AppColors.primary : const Color(0xFFE6F4F3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: highlight ? Colors.white : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// REQUEST CARD — shows a single request summary in lists
// ═══════════════════════════════════════════════════════════════════════════
class RequestCard extends StatelessWidget {
  final String requestId;
  final String requestType;
  final String department;
  final String status;
  final String priority;
  final String date;
  final String assignedStaff;
  final VoidCallback onTap;

  const RequestCard({
    super.key,
    required this.requestId,
    required this.requestType,
    required this.department,
    required this.status,
    required this.priority,
    required this.date,
    required this.assignedStaff,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: ID + priority badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  requestId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                PriorityBadge(priority: priority),
              ],
            ),
            const SizedBox(height: 4),
            Text(department, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Text(
              requestType,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 10),
            // Status + date row
            Row(
              children: [
                StatusBadge(status: status),
                const SizedBox(width: 8),
                Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(height: 8),
            // Assigned staff
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Assigned: $assignedStaff',
                style: const TextStyle(fontSize: 12, color: AppColors.textMid),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY STATS ROW — shows 3 mini stat cards (Pending / In Progress / Urgent)
// ═══════════════════════════════════════════════════════════════════════════
class SummaryStatsRow extends StatelessWidget {
  final int pending;
  final int inProgress;
  final int urgent;

  const SummaryStatsRow({
    super.key,
    required this.pending,
    required this.inProgress,
    required this.urgent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniStat(label: 'Pending', value: '$pending'),
        const SizedBox(width: 8),
        _MiniStat(label: 'In Progress', value: '$inProgress'),
        const SizedBox(width: 8),
        _MiniStat(label: 'Urgent', value: '$urgent'),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label, value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATUS FILTER CHIPS — horizontal row of filter buttons
// ═══════════════════════════════════════════════════════════════════════════
class FilterChips extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((opt) {
          final isActive = opt == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  opt,
                  style: TextStyle(
                    color: isActive ? Colors.white : AppColors.textMid,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION LABEL — small uppercase label above groups of content
// ═══════════════════════════════════════════════════════════════════════════
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: AppColors.textMid,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EMPTY STATE — shown when no items are found
// ═══════════════════════════════════════════════════════════════════════════
class EmptyState extends StatelessWidget {
  final String message;
  const EmptyState({super.key, this.message = 'No items found'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black45, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LOGOUT DIALOG — confirmation before logging out
// ═══════════════════════════════════════════════════════════════════════════
class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;
  const LogoutDialog({super.key, required this.onConfirm});

  static Future<void> show(BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (_) => LogoutDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Log Out', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// AVAILABILITY BADGE — for staff availability status
// ═══════════════════════════════════════════════════════════════════════════
class AvailabilityBadge extends StatelessWidget {
  final String status;
  const AvailabilityBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (status) {
      case 'Available':
        bg = AppColors.completed; text = AppColors.completedText; break;
      case 'Busy':
        bg = AppColors.high; text = AppColors.highText; break;
      case 'Be Right Back':
        bg = AppColors.inProgress; text = AppColors.inProgressText; break;
      default:
        bg = const Color(0xFFF1F5F9); text = const Color(0xFF64748B);
    }
    return _BadgePill(label: status, bg: bg, textColor: text);
  }
}
