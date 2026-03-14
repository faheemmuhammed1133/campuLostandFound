import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'item_detail_screen.dart';

class ChatScreen extends StatefulWidget {
  final String itemId;
  final String itemTitle;
  final String currentUser;

  const ChatScreen({
    super.key,
    required this.itemId,
    required this.itemTitle,
    required this.currentUser,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatMessage> _messages = [];
  final _messageController = TextEditingController();
  bool _isLoading = true;
  bool _isSending = false;
  Item? _item;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadItem();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      final json = await ApiService.getItem(widget.itemId);
      if (mounted) {
        setState(() => _item = Item.fromJson(json));
      }
    } catch (_) {}
  }

  Future<void> _loadMessages() async {
    try {
      final jsonList = await ApiService.getMessages(widget.itemId);
      if (mounted) {
        setState(() {
          _messages =
              jsonList.map((json) => ChatMessage.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading messages: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      await ApiService.sendMessage(
        itemId: widget.itemId,
        senderUsername: widget.currentUser,
        text: text,
      );
      _messageController.clear();
      _loadMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _openItemDetail() {
    if (_item == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ItemDetailScreen(
          item: _item!,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  Widget _buildItemBanner() {
    if (_item == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _openItemDetail,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: AppTheme.border),
          ),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: _item!.imageBytes != null
                      ? Image.memory(_item!.imageBytes!, fit: BoxFit.cover)
                      : Container(
                          color: AppTheme.divider,
                          child: const Icon(Icons.image_outlined,
                              size: 18, color: AppTheme.textMuted),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _item!.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_item!.location} \u2022 ${_item!.type == ItemType.lost ? 'Lost' : 'Found'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            tooltip: 'Back to Home',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadMessages,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildItemBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded,
                                size: 48, color: AppTheme.textMuted),
                            const SizedBox(height: 12),
                            const Text(
                              'No messages yet',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Start the conversation!',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe =
                              msg.senderUsername == widget.currentUser;
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? AppTheme.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                border: isMe
                                    ? null
                                    : Border.all(color: AppTheme.border),
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 3),
                                      child: Text(
                                        msg.senderUsername,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ),
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isMe
                                          ? Colors.white
                                          : AppTheme.textPrimary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${msg.date.hour}:${msg.date.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isMe
                                          ? Colors.white.withValues(alpha: 0.7)
                                          : AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          // Input area
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppTheme.border),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: AppTheme.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: _isSending ? null : _sendMessage,
                      icon: _isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20),
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
}
