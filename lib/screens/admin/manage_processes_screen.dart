// screens/admin/manage_processes_screen.dart
// Admin can add, edit, and delete processes (services within departments).
// Each process is linked to a department.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../constants/app_colors.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';

class ManageProcessesScreen extends StatefulWidget {
  const ManageProcessesScreen({super.key});

  @override
  State<ManageProcessesScreen> createState() => _ManageProcessesScreenState();
}

class _ManageProcessesScreenState extends State<ManageProcessesScreen> {
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  'Manage Processes',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Add, edit, or delete department processes',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                // Add process button
                GradientButton(
                  label: '+ Add New Process',
                  onPressed: () => _showAddEditDialog(context, user.userId),
                ),
              ],
            ),
          ),

          // ── Process list ─────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _db.getProcesses(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final processes = snap.data ?? [];

                if (processes.isEmpty) {
                  return const EmptyState(
                    message: 'No processes yet. Add one above.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: processes.length,
                  itemBuilder: (context, index) {
                    final process = processes[index];
                    return _ProcessCard(
                      process: process,
                      onEdit: () => _showAddEditDialog(
                        context,
                        user.userId,
                        process: process,
                      ),
                      onDelete: () => _confirmDelete(context, process, user.userId),
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

  // ── Add / Edit dialog ──────────────────────────────────────────────────────

  void _showAddEditDialog(
    BuildContext context,
    String adminId, {
    Map<String, dynamic>? process,
  }) {
    final isEdit = process != null;
    final nameCtrl = TextEditingController(text: isEdit ? process['processName'] : '');

    // We'll pick the department from available ones in Firestore
    String? selectedDeptId = isEdit ? process['departmentId'] : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEdit ? 'Edit Process' : 'Add Process',
            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Process name
                const Text(
                  'PROCESS NAME',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Wi-Fi Support',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.secondary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),

                const SizedBox(height: 16),

                // Department picker (from Firestore)
                const Text(
                  'DEPARTMENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _db.getDepartmentsAsMap(),
                  builder: (context, deptSnap) {
                    final depts = deptSnap.data ?? [];
                    return DropdownButtonFormField<String>(
                      value: selectedDeptId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: AppColors.secondary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      hint: const Text('Select department'),
                      items: depts.map((d) {
                        return DropdownMenuItem<String>(
                          value: d['departmentId'],
                          child: Text(d['departmentName'] ?? d['departmentId']),
                        );
                      }).toList(),
                      onChanged: (v) => setDialogState(() => selectedDeptId = v),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a process name.')),
                  );
                  return;
                }
                if (selectedDeptId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a department.')),
                  );
                  return;
                }

                Navigator.pop(ctx);

                if (isEdit) {
                  await _db.updateProcess(
                    processId: process['processId'],
                    processName: name,
                    departmentId: selectedDeptId!,
                    adminId: adminId,
                  );
                  _showSnack('Process updated successfully.');
                } else {
                  await _db.addProcess(
                    processName: name,
                    departmentId: selectedDeptId!,
                    adminId: adminId,
                  );
                  _showSnack('Process added successfully.');
                }
              },
              child: Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete confirmation ────────────────────────────────────────────────────

  void _confirmDelete(
    BuildContext context,
    Map<String, dynamic> process,
    String adminId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete Process?',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Are you sure you want to delete "${process['processName']}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await _db.deleteProcess(
                processId: process['processId'],
                adminId: adminId,
              );
              _showSnack('Process deleted.');
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

// ── Process card widget ───────────────────────────────────────────────────────

class _ProcessCard extends StatelessWidget {
  final Map<String, dynamic> process;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProcessCard({
    required this.process,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_tree_outlined,
              color: AppColors.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // Name and department
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  process['processName'] ?? 'Unnamed',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Dept: ${process['departmentId'] ?? 'N/A'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // Edit button
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: AppColors.secondary),
            tooltip: 'Edit',
          ),

          // Delete button
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
