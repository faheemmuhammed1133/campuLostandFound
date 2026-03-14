import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';
import 'item_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  final String currentUser;

  const NotificationsScreen({super.key, required this.currentUser});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final jsonList = await ApiService.getNotifications(widget.currentUser);
      if (mounted) {
        setState(() {
          _notifications =
              jsonList.map((json) => NotificationModel.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading notifications: $e')),
        );
      }
    }
  }

  Future<void> _markAllRead() async {
    try {
      await ApiService.markAllNotificationsRead(widget.currentUser);
      _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _onNotificationTap(NotificationModel notification) async {
    if (!notification.isRead) {
      try {
        await ApiService.markNotificationRead(notification.id);
        _loadNotifications();
      } catch (_) {}
    }

    if (!mounted || notification.itemId == null) return;

    try {
      final itemJson = await ApiService.getItem(notification.itemId!);
      final item = Item.fromJson(itemJson);

      if (!mounted) return;

      if (notification.type == 'new_message') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              itemId: item.id,
              itemTitle: item.title,
              currentUser: widget.currentUser,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ItemDetailScreen(
              item: item,
              currentUser: widget.currentUser,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load item: $e')),
        );
      }
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'item_found':
        return Icons.check_circle_outline;
      case 'claim_submitted':
        return Icons.assignment_outlined;
      case 'claim_approved':
        return Icons.thumb_up_outlined;
      case 'claim_rejected':
        return Icons.thumb_down_outlined;
      case 'new_message':
        return Icons.chat_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'item_found':
        return AppTheme.found;
      case 'claim_submitted':
        return AppTheme.primary;
      case 'claim_approved':
        return AppTheme.found;
      case 'claim_rejected':
        return AppTheme.lost;
      case 'new_message':
        return AppTheme.secondary;
      default:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            tooltip: 'Back to Home',
          ),
          TextButton(
            onPressed: _markAllRead,
            child: const Text('Mark All Read'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
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
                        child: const Icon(Icons.notifications_none_rounded,
                            size: 40, color: AppTheme.primary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No notifications',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'You\'re all caught up!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 68,
                    ),
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final typeColor = _colorForType(n.type);

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: n.isRead
                                ? AppTheme.divider
                                : typeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _iconForType(n.type),
                            color: n.isRead ? AppTheme.textMuted : typeColor,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          n.message,
                          style: TextStyle(
                            fontWeight:
                                n.isRead ? FontWeight.w400 : FontWeight.w600,
                            fontSize: 14,
                            color: n.isRead
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${n.date.day}/${n.date.month}/${n.date.year} ${n.date.hour}:${n.date.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                        tileColor: n.isRead
                            ? null
                            : AppTheme.primary.withValues(alpha: 0.03),
                        trailing: n.itemId != null
                            ? const Icon(Icons.chevron_right_rounded,
                                color: AppTheme.textMuted, size: 20)
                            : null,
                        onTap: () => _onNotificationTap(n),
                      );
                    },
                  ),
                ),
    );
  }
}
