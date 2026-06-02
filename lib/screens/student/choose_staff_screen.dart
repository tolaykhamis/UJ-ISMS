// screens/student/choose_staff_screen.dart
// Shows the student's active requests (Step 1) then a searchable staff list (Step 2).
// Tapping Select writes assignedStaffId + assignedStaffName to Firestore.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class ChooseStaffScreen extends StatefulWidget {
  const ChooseStaffScreen({super.key});

  @override
  State<ChooseStaffScreen> createState() => _ChooseStaffScreenState();
}

class _ChooseStaffScreenState extends State<ChooseStaffScreen> {
  final _searchController = TextEditingController();
  final _firestoreService = FirestoreService();
  String _query = '';
  RequestModel? _selectedRequest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
          'Choose Staff Member',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Step 1: Pick a request ──────────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              'Step 1 — Select your request',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textMid,
              ),
            ),
          ),

          StreamBuilder<List<RequestModel>>(
            stream: _firestoreService.getUserRequests(user.userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: LinearProgressIndicator(),
                );
              }

              final requests = (snapshot.data ?? [])
                  .where((r) =>
                      r.status == 'Pending' || r.status == 'On Progress')
                  .toList();

              if (requests.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No active requests found. Submit a request first.',
                    style: TextStyle(color: AppColors.textLight, fontSize: 13),
                  ),
                );
              }

              return SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final r = requests[i];
                    final selected =
                        _selectedRequest?.requestId == r.requestId;
                    return ChoiceChip(
                      label: Text(
                        r.requestType,
                        style: TextStyle(
                          color:
                              selected ? Colors.white : AppColors.textDark,
                          fontSize: 12,
                        ),
                      ),
                      selected: selected,
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: selected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedRequest = r),
                    );
                  },
                ),
              );
            },
          ),

          // Selected request label
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _selectedRequest != null
                ? Padding(
                    key: ValueKey(_selectedRequest!.requestId),
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                    child: Text(
                      'Assigning to: ${_selectedRequest!.requestType} · '
                      '${_selectedRequest!.departmentName}',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.primary),
                    ),
                  )
                : const SizedBox(key: ValueKey('empty')),
          ),

          const SizedBox(height: 16),

          // ── Step 2: Search & pick staff ─────────────────────────────────
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 6),
            child: Text(
              'Step 2 — Select a staff member',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textMid,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search by name...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.black38),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Staff list
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: _firestoreService.getStaffMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var staff = snapshot.data ?? [];
                if (_query.isNotEmpty) {
                  staff = staff
                      .where((s) => s.name
                          .toLowerCase()
                          .contains(_query.toLowerCase()))
                      .toList();
                }

                if (staff.isEmpty) {
                  return const EmptyState(
                      message: 'No staff members found.');
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: staff.length,
                  itemBuilder: (context, index) {
                    return _StaffCard(
                      staff: staff[index],
                      selectedRequest: _selectedRequest,
                      onAssigned: () =>
                          setState(() => _selectedRequest = null),
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
}

// ─────────────────────────────────────────────────────────────────────────────

class _StaffCard extends StatefulWidget {
  final UserModel staff;
  final RequestModel? selectedRequest;
  final VoidCallback onAssigned;

  const _StaffCard({
    required this.staff,
    required this.selectedRequest,
    required this.onAssigned,
  });

  @override
  State<_StaffCard> createState() => _StaffCardState();
}

class _StaffCardState extends State<_StaffCard> {
  bool _loading = false;

  Future<void> _assign() async {
    if (widget.selectedRequest == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a request first (Step 1).'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await FirestoreService().assignStaffToRequest(
        requestId: widget.selectedRequest!.requestId,
        staffId: widget.staff.userId,
        staffName: widget.staff.name,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.staff.name} assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onAssigned();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                _initials(widget.staff.name),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.staff.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Staff · ${widget.staff.email}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textLight),
                ),
                const SizedBox(height: 6),
                const AvailabilityBadge(status: 'Available'),
              ],
            ),
          ),

          // Select button or spinner
          _loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton(
                  onPressed: _assign,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                  ),
                  child: const Text(
                    'Select',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
        ],
      ),
    );
  }

  String _initials(String name) {
    return name
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }
}