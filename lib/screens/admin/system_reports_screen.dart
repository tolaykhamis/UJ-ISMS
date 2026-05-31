// lib/screens/admin/system_reports_screen.dart
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class SystemReportsScreen extends StatelessWidget {
  const SystemReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('System Reports',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<RequestModel>>(
        stream: service.getAllRequests(),
        builder: (context, snapshot) {
          final requests = snapshot.data ?? [];
          final total = requests.length;
          final pending = requests.where((r) => r.status == 'Pending').length;
          final inProgress = requests.where((r) => r.status == 'On Progress').length;
          final completed = requests.where((r) => r.status == 'Completed').length;
          final cancelled = requests.where((r) => r.status == 'Cancelled').length;
          final urgent = requests.where((r) => r.priority == 'Urgent').length;
          final high = requests.where((r) => r.priority == 'High').length;

          // Calculate efficiency (completed / total * 100)
          final efficiency =
              total > 0 ? ((completed / total) * 100).toStringAsFixed(0) : '0';

          final stats = [
            ['Total Requests', '$total'],
            ['Efficiency', '$efficiency%'],
            ['Completed', '$completed'],
            ['Pending', '$pending'],
            ['In Progress', '$inProgress'],
            ['Cancelled', '$cancelled'],
            ['Urgent Priority', '$urgent'],
            ['High Priority', '$high'],
          ];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Real-time system statistics from Firestore.',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: stats.map((s) {
                    return Container(
                      padding: const EdgeInsets.all(14),
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
                                  fontSize: 11, color: Colors.black45)),
                          const SizedBox(height: 6),
                          Text(s[1],
                              style: const TextStyle(
                                  fontSize: 24,
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
                      const SnackBar(
                        content: Text(
                            'Report generated! (Firebase Storage integration placeholder)'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Download/Print placeholder.')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('Download / Print',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
