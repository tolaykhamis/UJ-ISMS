// screens/staff/manage_priorities_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class ManagePrioritiesScreen extends StatelessWidget {
  const ManagePrioritiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Manage Priorities',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: service.getStaffRequests(user.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Sort: Urgent first, then High, then Normal
          final order = {'Urgent': 0, 'High': 1, 'Normal': 2};
          final requests = (snapshot.data ?? [])
            ..sort((a, b) =>
                (order[a.priority] ?? 2).compareTo(order[b.priority] ?? 2));

          if (requests.isEmpty) {
            return const EmptyState(message: 'No assigned requests.');
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, i) {
              final r = requests[i];
              return _PriorityCard(request: r, service: service);
            },
          );
        },
      ),
    );
  }
}

class _PriorityCard extends StatelessWidget {
  final RequestModel request;
  final FirestoreService service;

  const _PriorityCard({required this.request, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
                      fontWeight: FontWeight.bold, color: AppColors.textDark)),
              PriorityBadge(priority: request.priority),
            ],
          ),
          const SizedBox(height: 4),
          Text(request.requestType,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 12),
          // Priority dropdown
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: request.priority,
                items: ['Normal', 'High', 'Urgent']
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (newP) async {
                  if (newP != null) {
                    await service.updateRequestPriority(request.requestId, newP);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Priority updated.')),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
