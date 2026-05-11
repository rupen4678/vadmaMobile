import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/chat_provider.dart';
import 'chat_detail_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/models/chat.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Messages', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: conversationsAsync.when(
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No messages yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: conversations.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUser = conversation.participants.firstWhere(
                (p) => p.username != (currentUser ?? 'me'),
                orElse: () => conversation.participants.first,
              );

              return _buildConversationTile(context, conversation, otherUser);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildConversationTile(BuildContext context, Conversation conversation, dynamic otherUser) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFBC252A).withOpacity(0.1),
          child: Text(
            otherUser.username[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBC252A)),
          ),
        ),
        title: Text(
          otherUser.username,
          style: TextStyle(
            fontWeight: (conversation.lastMessage != null && !conversation.lastMessage!.isRead) 
              ? FontWeight.w900 
              : FontWeight.bold, 
            fontSize: 16
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            conversation.lastMessage?.text ?? 'Started a conversation',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: (conversation.lastMessage != null && !conversation.lastMessage!.isRead) 
                ? Colors.black87 
                : Colors.grey.shade600, 
              fontSize: 14,
              fontWeight: (conversation.lastMessage != null && !conversation.lastMessage!.isRead) 
                ? FontWeight.w600 
                : FontWeight.normal,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat.jm().format(conversation.updatedAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            if (conversation.lastMessage != null && !conversation.lastMessage!.isRead)
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(color: Color(0xFFBC252A), shape: BoxShape.circle),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                conversationId: conversation.id,
                otherUsername: otherUser.username,
              ),
            ),
          );
        },
      ),
    );
  }
}
