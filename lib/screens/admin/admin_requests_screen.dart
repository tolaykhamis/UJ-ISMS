

import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/request_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  final FirestoreService _db = FirestoreService();
  String _filter = 'All';

  final List<String> _filters = [
    'All',
    'Unseen',
    'Seen',
    'Pending',
    'On Progress',
    'Urgent',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new,
                          size: 16, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Back',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'UJ ISMS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.8,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Seen / Unseen Requests',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Unseen requests are highlighted as New',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: FilterChips(
              options: _filters,
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<RequestModel>>(
              stream: _db.getAllRequests(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final all = snap.data ?? [];
                final shown = all.where((r) {
                  switch (_filter) {
                    case 'Seen':
                      return r.seen;
                    case 'Unseen':
                      return !r.seen;
                    case 'Urgent':
                      return r.priority == 'Urgent';
                    case 'All':
                      return true;
                    default:
                      return r.status == _filter;
                  }
                }).toList();

                if (shown.isEmpty) {
                  return const EmptyState(
                    message: 'No requests found. Try selecting a different filter.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shown.length,
                  itemBuilder: (context, index) {
                    return _AdminRequestCard(
                      request: shown[index],
                      db: _db,
                      onView: () => _showRequestDetails(shown[index]),
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
  void _showRequestDetails(RequestModel r) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RequestDetailsSheet(request: r, db: _db),
    );
  }
}


class _AdminRequestCard extends StatelessWidget {
  final RequestModel request;
  final FirestoreService db;
  final VoidCallback onView;

  const _AdminRequestCard({
    required this.request,
    required this.db,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNew = !request.seen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        // Highlight unseen in teal tint
        color: isNew ? const Color(0xFFE6F7F6) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNew ? AppColors.accent.withOpacity(0.4) : Colors.grey[200]!,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        request.requestId,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PriorityBadge(priority: request.priority),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              '${request.departmentId}  ·  ${request.date}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

            const SizedBox(height: 12),
            StatusBadge(status: request.status),

            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onView,
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Open Request'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                if (isNew) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => db.markSeen(request.requestId),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark Seen'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class _RequestDetailsSheet extends StatelessWidget {
  final RequestModel request;
  final FirestoreService db;

  const _RequestDetailsSheet({required this.request, required this.db});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Request ID + badges
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requestId,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Submitted ${request.date}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: request.status),
              ],
            ),

            const SizedBox(height: 20),

            // Info grid
            Row(
              children: [
                Expanded(child: _InfoBox(label: 'Department', value: request.departmentId)),
                const SizedBox(width: 10),
                Expanded(child: _InfoBox(label: 'Priority', value: request.priority)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _InfoBox(label: 'Assigned Staff', value: request.assignedStaffId.isEmpty ? 'Unassigned' : request.assignedStaffId)),
                const SizedBox(width: 10),
                Expanded(child: _InfoBox(label: 'Seen', value: request.seen ? 'Yes' : 'No')),
              ],
            ),

            const SizedBox(height: 16),

            // Description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                request.description,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),

            const SizedBox(height: 20),
            if (!request.seen)
              GradientButton(
                label: 'Mark as Seen',
                onPressed: () {
                  db.markSeen(request.requestId);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
