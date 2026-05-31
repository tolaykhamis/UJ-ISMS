// screens/student_employee/staff_directory.dart
import 'package:flutter/material.dart';
import '../../models/data_models.dart';

class StaffDirectoryScreen extends StatefulWidget {
  final List<StaffMember> staffList;
  const StaffDirectoryScreen({super.key, required this.staffList});

  @override
  State<StaffDirectoryScreen> createState() => _StaffDirectoryScreenState();
}

class _StaffDirectoryScreenState extends State<StaffDirectoryScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.staffList.where((s) => (s?.name ?? '').toLowerCase().contains(query.toLowerCase())).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            onChanged: (v) => setState(() => query = v),
            decoration: InputDecoration(
              hintText: 'Search University Staff Directory...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, idx) {
                final s = filtered[idx];
                Color col = Colors.green;
                if (s.status == 'Busy') col = Colors.amber;
                if (s.status == 'Be Right Back') col = Colors.orange;
                if (s.status == 'Offline') col = Colors.grey;

                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: const Color.fromARGB(255, 6, 80, 73), child: Text((s.name ?? '').isNotEmpty ? s.name!.substring(0,1) : '?', style: const TextStyle(color: Colors.white))),
                    title: Text(s.name ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(s.department ?? '', style: const TextStyle(fontSize: 12)),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: col.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(s.status, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}