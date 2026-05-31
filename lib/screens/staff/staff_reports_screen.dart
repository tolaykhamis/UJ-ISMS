// screens/staff/staff_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class StaffReportsScreen extends StatelessWidget {
  const StaffReportsScreen({super.key});

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
        title: const Text('My Reports',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: service.getStaffRequests(user.userId),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];
          final completed =
              requests.where((r) => r.status == 'Completed').length;
          final pending = requests.where((r) => r.status == 'Pending').length;
          final urgent =
              requests.where((r) => r.priority == 'Urgent').length;

          final stats = [
            ['Total Assigned', '${requests.length}'],
            ['Completed', '$completed'],
            ['Pending', '$pending'],
            ['Urgent', '$urgent'],
          ];

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your workload summary based on assigned requests.',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: stats.map((s) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s[0],
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black45)),
                          const SizedBox(height: 6),
                          Text(s[1],
                              style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                GradientButton(
                  label: 'Generate Report',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report generated (placeholder).')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
