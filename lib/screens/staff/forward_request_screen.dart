// screens/staff/forward_request_screen.dart
// Staff can forward a request to another staff member or department.
// The forwarding is recorded in Firestore and the original user is notified.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/user_provider.dart';
import '../../constants/app_colors.dart';
import '../../models/request_model.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/app_widgets.dart';

class ForwardRequestScreen extends StatefulWidget {
  const ForwardRequestScreen({super.key});

  @override
  State<ForwardRequestScreen> createState() => _ForwardRequestScreenState();
}

class _ForwardRequestScreenState extends State<ForwardRequestScreen> {
  final FirestoreService _db = FirestoreService();

  // Selected values
  String? _selectedRequestId;
  String? _selectedStaffId;
  String? _selectedStaffName;
  String _reason = '';
  bool _loading = false;

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
                  'Forward Request',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Redirect to another staff member',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step 1: pick a request assigned to this staff
                  _buildSectionLabel('1. Select Your Assigned Request'),
                  const SizedBox(height: 8),
                  StreamBuilder<List<RequestModel>>(
                    stream: _db.getStaffRequests(user.userId),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final requests = snap.data!
                          .where((r) => r.status != 'Completed' && r.status != 'Cancelled')
                          .toList();

                      if (requests.isEmpty) {
                        return const EmptyState(
                          message: 'No active requests to forward.',
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Choose a request...'),
                            value: _selectedRequestId,
                            items: requests.map((r) {
                              return DropdownMenuItem(
                                value: r.requestId,
                                child: Text(
                                  '${r.requestId} · ${r.description.substring(0, r.description.length.clamp(0, 30))}...',
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() => _selectedRequestId = v),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Step 2: pick target staff member
                  _buildSectionLabel('2. Forward To (Staff Member)'),
                  const SizedBox(height: 8),
                  StreamBuilder<List<UserModel>>(
                    stream: _db.getStaffMembers(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      // Don't show current user in the list
                      final staff = snap.data!
                          .where((s) => s.userId != user.userId)
                          .toList();

                      if (staff.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: const Text(
                            'No other staff members found.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        );
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text('Choose a staff member...'),
                            value: _selectedStaffId,
                            items: staff.map((s) {
                              return DropdownMenuItem(
                                value: s.userId,
                                child: Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 18, color: AppColors.secondary),
                                    const SizedBox(width: 8),
                                    Text(s.name, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (v) => setState(() {
                              _selectedStaffId = v;
                              // find the selected staff name from the list
                              final found = staff.firstWhere((s) => s.userId == v, orElse: () => UserModel(userId: v ?? '', name: '', email: '', role: ''));
                              _selectedStaffName = found.name;
                            }),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Step 3: reason
                  _buildSectionLabel('3. Reason for Forwarding'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      maxLines: 4,
                      onChanged: (v) => _reason = v,
                      decoration: const InputDecoration(
                        hintText: 'Explain why you are forwarding this request...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Submit button
                  GradientButton(
                    label: _loading ? 'Forwarding...' : 'Forward Request',
                    onPressed: () => _submit(user),
                  ),

                  const SizedBox(height: 12),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18, color: AppColors.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'The request will be reassigned and the student/employee will be notified automatically.',
                            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section label helper
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.black87,
        letterSpacing: 0.2,
      ),
    );
  }

  // Submit the forward action
  Future<void> _submit(UserModel user) async {
    if (_selectedRequestId == null) {
      _showSnack('Please select a request first.');
      return;
    }
    if (_selectedStaffId == null) {
      _showSnack('Please select a staff member to forward to.');
      return;
    }
    if (_reason.trim().isEmpty) {
      _showSnack('Please write a reason for forwarding.');
      return;
    }

    setState(() => _loading = true);

    try {
      await _db.forwardRequest(
        requestId: _selectedRequestId!,
        newStaffId: _selectedStaffId!,
        newStaffName: _selectedStaffName ?? '',
        reason: _reason.trim(),
      );
      if (mounted) {
        _showSnack('Request forwarded successfully!');
        setState(() {
          _selectedRequestId = null;
          _selectedStaffId = null;
          _reason = '';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error: ${e.toString()}');
        setState(() => _loading = false);
      }
    }
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
