// screens/staff/update_status_screen.dart
// Staff selects a request and updates its status.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class UpdateStatusScreen extends StatefulWidget {
  const UpdateStatusScreen({super.key});

  @override
  State<UpdateStatusScreen> createState() => _UpdateStatusScreenState();
}

class _UpdateStatusScreenState extends State<UpdateStatusScreen> {
  final _firestoreService = FirestoreService();
  RequestModel? _selectedRequest;
  String _newStatus = 'Pending';
  final _noteController = TextEditingController();
  bool _isSaving = false;

  final _statuses = ['Pending', 'On Progress', 'Completed'];

  @override
  void dispose() {
    _noteController.dispose();
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
          'Update Status',
          style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Select Request'),

            // Request dropdown — loads assigned requests
            StreamBuilder<List<RequestModel>>(
              stream: _firestoreService.getStaffRequests(user.userId),
              builder: (context, snapshot) {
                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return const Text('No assigned requests.',
                      style: TextStyle(color: Colors.black45));
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RequestModel>(
                      isExpanded: true,
                      hint: const Text('Pick a request'),
                      value: _selectedRequest,
                      items: requests
                          .map((r) => DropdownMenuItem(
                                value: r,
                                child: Text('${r.requestId} · ${r.requestType}',
                                    overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: (r) => setState(() {
                        _selectedRequest = r;
                        _newStatus = r?.status ?? 'Pending';
                      }),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Status selector
            if (_selectedRequest != null) ...[
              // Selected request card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_selectedRequest!.requestId,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary)),
                    Text(_selectedRequest!.requestType,
                        style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 6),
                    StatusBadge(status: _selectedRequest!.status),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              const SectionLabel('New Status'),
              Row(
                children: _statuses.map((s) {
                  final sel = _newStatus == s;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _newStatus = s),
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
                            s,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: sel ? Colors.white : AppColors.textMid,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const SectionLabel('Internal Note (Optional)'),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write an internal note...',
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
              ),
              const SizedBox(height: 20),

              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : GradientButton(
                      label: 'Save Status Update',
                      onPressed: _saveUpdate,
                    ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'The requester will be automatically notified.',
                  style: TextStyle(fontSize: 12, color: Colors.black38),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveUpdate() async {
    if (_selectedRequest == null) return;
    setState(() => _isSaving = true);

    await _firestoreService.updateRequestStatus(
      _selectedRequest!.requestId,
      _newStatus,
      _selectedRequest!.userId,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully!')),
      );
    }
  }
}
