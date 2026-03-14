import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/item_card.dart';
import 'report_item_screen.dart';
import 'item_detail_screen.dart';
import 'notifications_screen.dart';
import 'messages_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentUser;
  final VoidCallback onLogout;

  const HomeScreen({
    super.key,
    required this.currentUser,
    required this.onLogout,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Item> _items = [];
  String _searchQuery = '';
  ItemType? _filterType;
  bool _isLoading = true;
  int _unreadCount = 0;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _loadItems();
    _loadUnreadCount();
  }

  Future<void> _loadItems() async {
    try {
      final jsonList = await ApiService.getItems();
      if (mounted) {
        setState(() {
          _items = jsonList.map((json) => Item.fromJson(json)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    try {
      final jsonList = await ApiService.getNotifications(widget.currentUser);
      if (mounted) {
        setState(() {
          _unreadCount = jsonList
              .map((json) => NotificationModel.fromJson(json))
              .where((n) => !n.isRead)
              .length;
        });
      }
    } catch (_) {}
  }

  List<Item> get _filteredItems {
    return _items.where((item) {
      final matchesType = _filterType == null || item.type == _filterType;
      final matchesSearch = _searchQuery.isEmpty ||
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesType && matchesSearch;
    }).toList();
  }

  Widget _buildItemsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildFilterChip('All', _filterType == null, () {
                setState(() => _filterType = null);
              }),
              const SizedBox(width: 8),
              _buildFilterChip('Lost', _filterType == ItemType.lost, () {
                setState(() => _filterType =
                    _filterType == ItemType.lost ? null : ItemType.lost);
              }, color: AppTheme.lost),
              const SizedBox(width: 8),
              _buildFilterChip('Found', _filterType == ItemType.found, () {
                setState(() => _filterType =
                    _filterType == ItemType.found ? null : ItemType.found);
              }, color: AppTheme.found),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_rounded, size: 56,
                              color: AppTheme.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No items found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        await _loadItems();
                        await _loadUnreadCount();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return ItemCard(
                            item: item,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDetailScreen(
                                    item: item,
                                    currentUser: widget.currentUser,
                                  ),
                                ),
                              );
                              _loadItems();
                              _loadUnreadCount();
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap,
      {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (color ?? AppTheme.primary).withValues(alpha: 0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? (color ?? AppTheme.primary)
                : AppTheme.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected
                ? (color ?? AppTheme.primary)
                : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTab == 0 ? 'Campus Lost & Found' : 'Messages'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: _unreadCount > 0,
              label: Text(
                '$_unreadCount',
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationsScreen(
                    currentUser: widget.currentUser,
                  ),
                ),
              );
              _loadUnreadCount();
              _loadItems();
            },
            tooltip: 'Notifications',
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded, size: 16, color: AppTheme.primary),
                const SizedBox(width: 4),
                Text(
                  widget.currentUser,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: widget.onLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _currentTab == 0
          ? _buildItemsTab()
          : MessagesScreen(currentUser: widget.currentUser),
      floatingActionButton: _currentTab == 0
          ? FloatingActionButton(
              onPressed: () async {
                final created = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReportItemScreen(currentUser: widget.currentUser),
                  ),
                );
                if (created == true) {
                  _loadItems();
                  _loadUnreadCount();
                }
              },
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentTab,
          onDestinationSelected: (index) {
            setState(() => _currentTab = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat_rounded),
              label: 'Messages',
            ),
          ],
        ),
      ),
    );
  }
}
