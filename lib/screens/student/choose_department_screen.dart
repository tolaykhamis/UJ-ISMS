// screens/student/choose_department_screen.dart
// Step 1: Student chooses a department, fills in request details, and submits.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/request_model.dart';
import '../../models/models.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class ChooseDepartmentScreen extends StatefulWidget {
  const ChooseDepartmentScreen({super.key});

  @override
  State<ChooseDepartmentScreen> createState() => _ChooseDepartmentScreenState();
}

class _ChooseDepartmentScreenState extends State<ChooseDepartmentScreen> {
  final _descController = TextEditingController();
  final _firestoreService = FirestoreService();

  DepartmentModel? _selectedDepartment;
  PlatformFile? _attachedFile;
  String _selectedType = 'IT Support';
  String _selectedPriority = 'Normal';
  bool _isSubmitting = false;
  bool _submitted = false;
  String _generatedId = '';

  final List<String> _requestTypes = [
    'IT Support',
    'Administrative Service',
    'Maintenance Request',
    'Equipment Request',
  ];
  final List<String> _priorities = ['Normal', 'High', 'Urgent'];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_selectedDepartment == null) {
      _showSnack('Please select a department first.');
      return;
    }
    if (_descController.text.trim().isEmpty) {
      _showSnack('Please write a request description.');
      return;
    }

    setState(() => _isSubmitting = true);

    final user = context.read<UserProvider>().user;
    if (user == null) {
      _showSnack('Please sign in again to submit a request.');
      if (mounted) setState(() => _isSubmitting = false);
      return;
    }

    try {
      final id = await _firestoreService.submitRequest(
        RequestModel(
          requestId: '',
          description: _descController.text.trim(),
          status: 'Pending',
          priority: _selectedPriority,
          date: DateTime.now().toIso8601String(),
          departmentId: _selectedDepartment!.departmentId,
          departmentName: _selectedDepartment!.departmentName,
          requestType: _selectedType,
          userId: user.userId,
          userName: user.name,
        ),
        attachment: _attachedFile,
      );

      setState(() {
        _submitted = true;
        _generatedId = id;
        _attachedFile = null;
      });
    } catch (e) {
      _showSnack('Failed to submit request. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickAttachment() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: false,
      type: FileType.any,
      withData: true,
    );
    if (result == null) return;

    setState(() {
      _attachedFile = result.files.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Submit a Request',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _submitted
          ? _buildSuccessView()
          : _buildFormView(),
    );
  }

  // Success screen after submission
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.completed,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.check, color: AppColors.completedText, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'Request Submitted!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your request has been received.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.normal,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _generatedId,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Submit Another Request',
              onPressed: () => setState(() {
                _submitted = false;
                _descController.clear();
                _selectedDepartment = null;
                _selectedType = 'IT Support';
                _selectedPriority = 'Normal';
                _attachedFile = null;
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Request form
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fill in the details below to submit a service request.',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 20),

          // Department selector (loaded from Firestore)
          const SectionLabel('Department'),
          StreamBuilder<List<DepartmentModel>>(
            stream: _firestoreService.getDepartments(),
            builder: (context, snap) {
              final departments = snap.data ?? [];

              // Add default options if Firestore is empty
              if (departments.isEmpty) {
                return _buildDropdownBox('No departments found. Admin must add departments.');
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DepartmentModel>(
                    isExpanded: true,
                    hint: const Text('Select Department'),
                    value: _selectedDepartment,
                    items: departments.map((d) => DropdownMenuItem(
                      value: d,
                      child: Text(d.departmentName),
                    )).toList(),
                    onChanged: (d) => setState(() => _selectedDepartment = d),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Request type
          const SectionLabel('Request Type'),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedType,
                items: _requestTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (t) => setState(() => _selectedType = t!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Description
          const SectionLabel('Description'),
          TextField(
            controller: _descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Write a clear description of the request...',
              hintStyle: const TextStyle(color: Colors.black26, fontSize: 14),
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
          const SizedBox(height: 16),

          // Priority
          const SectionLabel('Priority Level'),
          Row(
            children: _priorities.map((p) {
              final selected = _selectedPriority == p;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPriority = p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        p,
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.textMid,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: _pickAttachment,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border,
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.attach_file, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _attachedFile?.name ?? 'Attach a file or photo (Optional)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _attachedFile == null
                              ? 'Tap to choose from device storage.'
                              : 'Tap to replace the selected attachment.',
                          style: const TextStyle(fontSize: 12, color: Colors.black38),
                        ),
                      ],
                    ),
                  ),
                  if (_attachedFile != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textMid),
                      onPressed: () => setState(() => _attachedFile = null),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Submit button
          _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : GradientButton(
                  label: 'Submit Request',
                  onPressed: _submitRequest,
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDropdownBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black45)),
    );
  }
}
