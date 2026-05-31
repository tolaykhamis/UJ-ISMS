// screens/staff/staff_messages_screen.dart
// Staff views conversations from employees/students who messaged them.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/models.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class StaffMessagesScreen extends StatefulWidget {
  const StaffMessagesScreen({super.key});

  @override
  State<StaffMessagesScreen> createState() => _StaffMessagesScreenState();
}

class _StaffMessagesScreenState extends State<StaffMessagesScreen> {
  final _service = FirestoreService();
  UserModel? _selectedUser;
  final _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
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
        title: const Text('Messages',
            style: TextStyle(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // User selector (students/employees to chat with)
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<UserModel>>(
              stream: _service.getAllUsers(),
              builder: (context, snap) {
                final users = (snap.data ?? [])
                    .where((u) =>
                        u.role == 'Student' ||
                        u.role == 'Employee')
                    .toList();

                if (users.isEmpty) {
                  return const Text('No users found.',
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
                    child: DropdownButton<UserModel>(
                      isExpanded: true,
                      hint: const Text('Select user to reply'),
                      value: _selectedUser,
                      items: users
                          .map((u) => DropdownMenuItem(
                                value: u,
                                child: Text('${u.name} (${u.role})'),
                              ))
                          .toList(),
                      onChanged: (u) => setState(() => _selectedUser = u),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_selectedUser != null)
            Expanded(
              child: _ChatArea(
                staffId: user.userId,
                userId: _selectedUser!.userId,
                userName: _selectedUser!.name,
                service: _service,
              ),
            )
          else
            const Expanded(
              child: Center(
                child: EmptyState(message: 'Select a user to view their messages.'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatArea extends StatefulWidget {
  final String staffId, userId, userName;
  final FirestoreService service;

  const _ChatArea({
    required this.staffId,
    required this.userId,
    required this.userName,
    required this.service,
  });

  @override
  State<_ChatArea> createState() => _ChatAreaState();
}

class _ChatAreaState extends State<_ChatArea> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Chat header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    widget.userName.split(' ').map((w) => w[0]).take(2).join(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.userName,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Messages
        Expanded(
          child: StreamBuilder<List<MessageModel>>(
            stream:
                widget.service.getMessages(widget.userId, widget.staffId),
            builder: (context, snap) {
              final msgs = snap.data ?? [];
              if (msgs.isEmpty) {
                return const Center(
                  child: Text('No messages yet.',
                      style: TextStyle(color: Colors.black38)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: msgs.length,
                itemBuilder: (_, i) {
                  final m = msgs[i];
                  final isStaff = m.senderId == widget.staffId;
                  return Align(
                    alignment: isStaff
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isStaff ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: isStaff
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        m.message,
                        style: TextStyle(
                          color: isStaff ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Input
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Reply...',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final text = _controller.text.trim();
                  if (text.isEmpty) return;
                  _controller.clear();
                  await widget.service.sendMessage(
                    senderId: widget.staffId,
                    receiverId: widget.userId,
                    message: text,
                  );
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
