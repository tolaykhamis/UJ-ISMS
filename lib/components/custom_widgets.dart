// components/custom_widgets.dart
import 'package:flutter/material.dart';
import '../models/data_models.dart';

class DashboardHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String label;

  const DashboardHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 6, 80, 73),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        ],
      ),
    );
  }
}

class SummaryStatisticsCard extends StatelessWidget {
  final String label;
  final String value;
  final Color indicatorColor;

  const SummaryStatisticsCard({
    super.key,
    required this.label,
    required this.value,
    required this.indicatorColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: indicatorColor)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color.fromARGB(255, 6, 80, 73), size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color.fromARGB(255, 12, 43, 39))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black45, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class RequestCard extends StatelessWidget {
  final SystemRequest request;
  final VoidCallback onViewTrace;
  final VoidCallback? onCancel;

  const RequestCard({
    super.key,
    required this.request,
    required this.onViewTrace,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor = Colors.amber;
    if (request.status == 'On Progress') badgeColor = Colors.blue;
    if (request.status == 'Completed') badgeColor = Colors.green;
    if (request.status == 'Cancelled') badgeColor = Colors.red;

    Color priorityColor = Colors.grey;
    if (request.priority == 'High') priorityColor = Colors.orange;
    if (request.priority == 'Urgent') priorityColor = Colors.redAccent;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(request.id, style: const TextStyle(fontWeight: FontWeight.bold, color: Color.fromARGB(255, 6, 80, 73), fontSize: 15)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(request.priority, style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text(request.status, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Text('Department: ${request.department}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(request.description, style: const TextStyle(fontSize: 13, color: Colors.black87)),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${request.date}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                Row(
                  children: [
                    if (request.status == 'Pending' && onCancel != null) ...[
                      TextButton(
                        onPressed: onCancel,
                        child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ],
                    TextButton(
                      onPressed: onViewTrace,
                      child: const Text('View Trace', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}