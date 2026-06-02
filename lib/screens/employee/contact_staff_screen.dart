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

  // Store the selected staff's userId string, NOT the UserModel object.
  // This prevents the DropdownButton assertion crash when the stream rebuilds
  // and emits new UserModel instances that are not identical by reference.
  String? _selectedStaffId;

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
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _firestoreService.getStaffMembers(),
        builder: (context, snapshot) {
          final staff = snapshot.data ?? [];

          // If the previously selected staff is no longer in the list, clear it.
          if (_selectedStaffId != null &&
              !staff.any((s) => s.userId == _selectedStaffId)) {
            _selectedStaffId = null;
          }

          // Find the currently selected UserModel (or null).
          final selectedStaff = staff.isEmpty
              ? null
              : staff.where((s) => s.userId == _selectedStaffId).firstOrNull;

          return Column(
            children: [
              // ── Staff selector ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: staff.isEmpty
                    ? const Text(
                        'No staff members available.',
                        style: TextStyle(color: Colors.black45),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: const Text(
                                'Select a staff member to message'),
                            // Value is a userId string — always unique & stable.
                            value: _selectedStaffId,
                            items: staff
                                .map((s) => DropdownMenuItem<String>(
                                      value: s.userId,
                                      child: Text(s.name),
                                    ))
                                .toList(),
                            onChanged: (id) =>
                                setState(() => _selectedStaffId = id),
                          ),
                        ),
                      ),
              ),

              // ── Chat area ───────────────────────────────────────────────
              if (selectedStaff != null)
                Expanded(
                  child: _ChatView(
                    staffMember: selectedStaff,
                    service: _firestoreService,
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: EmptyState(
                      message:
                          'Select a staff member above to start chatting.',
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

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
        const SnackBar(
            content: Text('Please sign in again to send messages.')),
      );
      return;
    }

    _messageController.clear();

    await widget.service.sendMessage(
      senderId: user.userId,
      receiverId: widget.staffMember.userId,
      message: text,
      senderName: user.name,
      receiverName: widget.staffMember.name, // ← pass staff name so inbox shows it
    );

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        // ── Staff info header ──────────────────────────────────────────────
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.staffMember.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Staff member',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Messages list ──────────────────────────────────────────────────
        Expanded(
          child: StreamBuilder<List<MessageModel>>(
            stream: widget.service
                .getMessages(user.userId, widget.staffMember.userId),
            builder: (context, snapshot) {
              final messages = snapshot.data ?? [];

              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    'No messages yet. Say hello!',
                    style: TextStyle(color: Colors.black38),
                  ),
                );
              }

              // Auto-scroll when new messages come in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  );
                }
              });

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
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 4),
                          bottomRight: Radius.circular(isMe ? 4 : 16),
                        ),
                        border: isMe
                            ? null
                            : Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        msg.message,
                        style: TextStyle(
                          color:
                              isMe ? Colors.white : AppColors.textDark,
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

        // ── Message input ──────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
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