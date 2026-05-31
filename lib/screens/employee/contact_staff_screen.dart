// screens/employee/contact_staff_screen.dart
// Employee-only screen to send messages to staff members.
// Uses Firestore "messages" collection for real-time chat.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/user_model.dart';
import '../../models/models.dart';
import '../../constants/app_colors.dart';
import '../../widgets/app_widgets.dart';

class ContactStaffScreen extends StatefulWidget {
  const ContactStaffScreen({super.key});

  @override
  State<ContactStaffScreen> createState() => _ContactStaffScreenState();
}

class _ContactStaffScreenState extends State<ContactStaffScreen> {
  final _firestoreService = FirestoreService();
  UserModel? _selectedStaff;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Contact Staff',
          style: TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Staff selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: StreamBuilder<List<UserModel>>(
              stream: _firestoreService.getStaffMembers(),
              builder: (context, snapshot) {
                final staff = snapshot.data ?? [];
                if (staff.isEmpty) {
                  return const Text('No staff members available.',
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
                      hint: const Text('Select a staff member to message'),
                      value: _selectedStaff,
                      items: staff.map((s) => DropdownMenuItem(
                            value: s,
                            child: Text(s.name),
                          )).toList(),
                      onChanged: (s) => setState(() => _selectedStaff = s),
                    ),
                  ),
                );
              },
            ),
          ),

          // Chat area
          if (_selectedStaff != null)
            Expanded(
              child: _ChatView(
                staffMember: _selectedStaff!,
                service: _firestoreService,
              ),
            )
          else
            const Expanded(
              child: Center(
                child: EmptyState(
                  message: 'Select a staff member above to start chatting.',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// The actual chat UI with real-time messages
class _ChatView extends StatefulWidget {
  final UserModel staffMember;
  final FirestoreService service;

  const _ChatView({required this.staffMember, required this.service});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final user = context.read<UserProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in again to send messages.')),
      );
      return;
    }

    _messageController.clear();

    await widget.service.sendMessage(
      senderId: user.userId,
      receiverId: widget.staffMember.userId,
      message: text,
    );

    // Scroll to bottom after sending
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<UserProvider>().user;
    if (user == null) {
      return const Center(
        child: Text('Please sign in again to use this chat.'),
      );
    }

    return Column(
      children: [
        // Staff info header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _initials(widget.staffMember.name),
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.staffMember.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Staff member',
                      style: TextStyle(fontSize: 12, color: Colors.black45)),
                ],
              ),
            ],
          ),
        ),

        // Messages list
        Expanded(
          child: StreamBuilder<List<MessageModel>>(
            stream: widget.service.getMessages(
                user.userId, widget.staffMember.userId),
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Say hello!',
                      style: TextStyle(color: Colors.black38)),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isMe = msg.senderId == user.userId;

                  return Align(
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: isMe
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        msg.message,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.textDark,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Message input
        Container(
          padding: const EdgeInsets.all(12),
          color: Colors.white,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
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
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ),
      ],
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
