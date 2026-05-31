// screens/student/request_history_screen.dart
// Shows all requests submitted by the logged-in user.
// Has filter chips to filter by status.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  final _firestoreService = FirestoreService();
  String _filter = 'All';
  final List<String> _filters = [
    'All', 'Pending', 'On Progress', 'Completed', 'Cancelled'
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Requests',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilterChips(
              options: _filters,
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
          ),

          // Request list
          Expanded(
            child: StreamBuilder<List<RequestModel>>(
              stream: _firestoreService.getUserRequests(user.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var requests = snapshot.data ?? [];

                // Apply filter
                if (_filter != 'All') {
                  requests =
                      requests.where((r) => r.status == _filter).toList();
                }

                if (requests.isEmpty) {
                  return EmptyState(
                    message: _filter == 'All'
                        ? 'You have not submitted any requests yet.'
                        : 'No $_filter requests found.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    return RequestCard(
                      requestId: r.requestId,
                      requestType: r.requestType,
                      department: r.departmentName,
                      status: r.status,
                      priority: r.priority,
                      date: _formatDate(r.date),
                      assignedStaff: r.assignedStaffName,
                      onTap: () => _openDetails(context, r),
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

  void _openDetails(BuildContext context, RequestModel r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _RequestActionsPage(request: r),
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

// ─── Request Actions Page ─────────────────────────────────────────────────
// Shows full details + buttons to Edit, Cancel, or Mark Urgent
class _RequestActionsPage extends StatefulWidget {
  final RequestModel request;
  const _RequestActionsPage({required this.request});

  @override
  State<_RequestActionsPage> createState() => _RequestActionsPageState();
}

class _RequestActionsPageState extends State<_RequestActionsPage> {
  late TextEditingController _descController;
  late String _priority;
  bool _isEditing = false;
  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.request.description);
    _priority = widget.request.priority;
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    final canEdit = r.status == 'Pending'; // Only pending requests can be edited

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          r.requestId,
          style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          // Edit toggle (only for pending requests)
          if (canEdit)
            TextButton(
              onPressed: () => setState(() => _isEditing = !_isEditing),
              child: Text(
                _isEditing ? 'Cancel Edit' : 'Edit',
                style: const TextStyle(color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + priority row
            Row(
              children: [
                StatusBadge(status: r.status),
                const SizedBox(width: 8),
                PriorityBadge(priority: r.priority),
              ],
            ),
            const SizedBox(height: 16),

            // Type + department
            Text(r.requestType,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark)),
            Text(r.departmentName,
                style: const TextStyle(color: AppColors.textLight)),
            const SizedBox(height: 16),

            // Description (editable if in edit mode)
            const SectionLabel('Description'),
            _isEditing
                ? TextField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.all(16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(r.description,
                        style: const TextStyle(fontSize: 14, height: 1.5)),
                  ),
            const SizedBox(height: 16),

            // Priority selector (editable mode)
            if (_isEditing) ...[
              const SectionLabel('Change Priority'),
              Row(
                children: ['Normal', 'High', 'Urgent'].map((p) {
                  final sel = _priority == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: sel ? AppColors.primary : AppColors.border),
                        ),
                        child: Center(
                          child: Text(
                            p,
                            style: TextStyle(
                              color: sel ? Colors.white : AppColors.textMid,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              GradientButton(
                label: 'Save Changes',
                onPressed: _saveEdit,
              ),
              const SizedBox(height: 12),
            ],

            // Assigned staff info
            const SectionLabel('Assigned Staff'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(r.assignedStaffName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // Action buttons
            if (canEdit && !_isEditing) ...[
              // Mark urgent
              if (r.priority != 'Urgent')
                OutlinedButton.icon(
                  onPressed: _markUrgent,
                  icon: const Icon(Icons.warning_amber_outlined,
                      color: AppColors.urgentText),
                  label: const Text('Mark as Urgent',
                      style: TextStyle(color: AppColors.urgentText)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.urgentText),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),

              const SizedBox(height: 10),

              // Cancel request
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cancelRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBE123C),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cancel Request',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveEdit() async {
    final user = context.read<UserProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to save changes.')),
      );
      return;
    }

    await _firestoreService.editRequest(
      widget.request.requestId,
      _descController.text,
      _priority,
    );
    if (mounted) {
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully.')),
      );
    }
  }

  Future<void> _markUrgent() async {
    await _firestoreService.markUrgent(widget.request.requestId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request marked as Urgent.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _cancelRequest() async {
    // Confirm dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBE123C)),
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final user = context.read<UserProvider>().user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in again to cancel requests.')),
        );
        return;
      }
      await _firestoreService.cancelRequest(widget.request.requestId, user.userId);
      Navigator.pop(context);
    }
  }
}
