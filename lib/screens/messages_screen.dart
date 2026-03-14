import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class ConversationItem {
  final Item item;
  final ChatMessage lastMessage;

  ConversationItem({required this.item, required this.lastMessage});
}

class MessagesScreen extends StatefulWidget {
  final String currentUser;

  const MessagesScreen({super.key, required this.currentUser});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<ConversationItem> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    try {
      final jsonList = await ApiService.getConversations(widget.currentUser);
      if (mounted) {
        setState(() {
          _conversations = jsonList.map((json) {
            final item = Item.fromJson(json['item']);
            final lastMessage = ChatMessage.fromJson(json['lastMessage']);
            return ConversationItem(item: item, lastMessage: lastMessage);
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading conversations: $e')),
        );
      }
    }
  }

  void _openChat(ConversationItem conversation) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          itemId: conversation.item.id,
          itemTitle: conversation.item.title,
          currentUser: widget.currentUser,
        ),
      ),
    );
    _loadConversations();
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _conversations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chat_outlined,
                          size: 40, color: AppTheme.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Start chatting on a found item!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadConversations,
                child: ListView.separated(
                  itemCount: _conversations.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 78,
                  ),
                  itemBuilder: (context, index) {
                    final conv = _conversations[index];
                    final isMyMessage =
                        conv.lastMessage.senderUsername == widget.currentUser;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: conv.item.imageBytes != null
                                ? Image.memory(conv.item.imageBytes!,
                                    fit: BoxFit.cover)
                                : Container(
                                    color: AppTheme.divider,
                                    child: const Icon(Icons.image_outlined,
                                        size: 22, color: AppTheme.textMuted),
                                  ),
                          ),
                        ),
                      ),
                      title: Text(
                        conv.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          '${isMyMessage ? 'You' : conv.lastMessage.senderUsername}: ${conv.lastMessage.text}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      trailing: Text(
                        _formatTime(conv.lastMessage.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      onTap: () => _openChat(conv),
                    );
                  },
                ),
              );
  }
}
