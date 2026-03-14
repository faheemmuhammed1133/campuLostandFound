import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../models/claim_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;
  final String currentUser;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.currentUser,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  List<Claim> _claims = [];
  final _claimDescriptionController = TextEditingController();
  bool _claimSubmitted = false;
  bool _isLoadingClaims = true;

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  @override
  void dispose() {
    _claimDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadClaims() async {
    try {
      final jsonList = await ApiService.getClaims(widget.item.id);
      if (mounted) {
        setState(() {
          _claims = jsonList.map((json) => Claim.fromJson(json)).toList();
          _claimSubmitted = _claims.any(
            (c) =>
                c.claimerUsername == widget.currentUser &&
                c.status == ClaimStatus.pending,
          );
          _isLoadingClaims = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingClaims = false);
    }
  }

  Future<void> _submitClaim() async {
    final desc = _claimDescriptionController.text.trim();
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }
    try {
      await ApiService.createClaim(
        itemId: widget.item.id,
        claimerUsername: widget.currentUser,
        description: desc,
      );
      setState(() => _claimSubmitted = true);
      _loadClaims();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Claim submitted! Waiting for approval.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleApprove(Claim claim) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Claim'),
        content: Text(
            'Approve claim by ${claim.claimerUsername}? The item will be marked as resolved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.approveClaim(claim.id);
                if (mounted) Navigator.pop(context, true);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReject(Claim claim) async {
    try {
      await ApiService.rejectClaim(claim.id);
      _loadClaims();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Claim by ${claim.claimerUsername} rejected.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _handleMarkAsFound() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Found'),
        content: const Text(
            'Mark this item as found? You will become the item keeper and manage claims.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.markAsFound(
                    widget.item.id, widget.currentUser);
                if (mounted) Navigator.pop(context, true);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete() async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text(
            'Are you sure you want to delete this item? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteItem(widget.item.id);
                if (mounted) Navigator.pop(context, true);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child:
                const Text('Delete', style: TextStyle(color: AppTheme.lost)),
          ),
        ],
      ),
    );
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          itemId: widget.item.id,
          itemTitle: widget.item.title,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  bool get _isPostedByCurrentUser =>
      widget.item.postedBy == widget.currentUser;

  bool get _isClaimManager =>
      widget.item.claimManager == widget.currentUser;

  Widget _buildInfoRow(IconData icon, String text, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (iconColor ?? AppTheme.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor ?? AppTheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLost = widget.item.type == ItemType.lost;
    final statusColor = widget.item.status == 'resolved'
        ? AppTheme.textMuted
        : (isLost ? AppTheme.lost : AppTheme.found);
    final statusBg = widget.item.status == 'resolved'
        ? AppTheme.divider
        : (isLost ? AppTheme.lostLight : AppTheme.foundLight);
    final statusLabel = widget.item.status == 'resolved'
        ? 'Resolved'
        : (isLost ? 'Lost' : 'Found');

    final pendingClaims =
        _claims.where((c) => c.status == ClaimStatus.pending).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.home_outlined),
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            tooltip: 'Back to Home',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            if (widget.item.imageBytes != null)
              Image.memory(
                widget.item.imageBytes!,
                width: double.infinity,
                height: 260,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: AppTheme.divider,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined, size: 48, color: AppTheme.textMuted),
                    SizedBox(height: 8),
                    Text('No image', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Info section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                            Icons.location_on_outlined, widget.item.location),
                        _buildInfoRow(Icons.calendar_today_outlined,
                            '${widget.item.date.day}/${widget.item.date.month}/${widget.item.date.year}'),
                        _buildInfoRow(Icons.person_outline,
                            'Posted by ${widget.item.postedBy}'),
                        if (widget.item.foundBy != null)
                          _buildInfoRow(Icons.check_circle_outline,
                              'Found by ${widget.item.foundBy}',
                              iconColor: AppTheme.found),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action buttons
                  if (widget.item.type == ItemType.lost &&
                      widget.item.status == 'active')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleMarkAsFound,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Mark as Found'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.found,
                        ),
                      ),
                    ),

                  if (_isPostedByCurrentUser) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _handleDelete,
                        icon: const Icon(Icons.delete_outline_rounded,
                            color: AppTheme.lost),
                        label: const Text('Delete Item',
                            style: TextStyle(color: AppTheme.lost)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.lost),
                        ),
                      ),
                    ),
                  ],

                  if (widget.item.type == ItemType.found) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openChat,
                        icon: const Icon(Icons.chat_outlined),
                        label: const Text('Chat About This Item'),
                      ),
                    ),
                  ],

                  // Claims section
                  if (widget.item.type == ItemType.found &&
                      widget.item.status == 'active') ...[
                    const SizedBox(height: 28),
                    const Divider(),
                    const SizedBox(height: 16),

                    if (_isLoadingClaims)
                      const Center(child: CircularProgressIndicator())
                    else if (_isClaimManager) ...[
                      Row(
                        children: [
                          const Text(
                            'Pending Claims',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${pendingClaims.length}',
                              style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (pendingClaims.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.divider,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined,
                                  color: AppTheme.textMuted, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'No claims yet',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        ...pendingClaims.map((claim) => Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          size: 16,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        claim.claimerUsername,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    claim.description,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            _handleReject(claim),
                                        icon: const Icon(Icons.close_rounded,
                                            size: 18, color: AppTheme.lost),
                                        label: const Text('Reject',
                                            style: TextStyle(
                                                color: AppTheme.lost)),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: AppTheme.lost),
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 12, vertical: 6),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () =>
                                            _handleApprove(claim),
                                        icon: const Icon(
                                            Icons.check_rounded,
                                            size: 18),
                                        label: const Text('Approve'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.found,
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 12, vertical: 6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )),
                    ] else if (_claimSubmitted) ...[
                      const Text(
                        'Claim This Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.foundLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.hourglass_top_rounded,
                                color: AppTheme.found, size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Your claim has been submitted and is pending approval.',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: AppTheme.found,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Claim This Item',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _claimDescriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Describe why this is yours',
                          hintText:
                              'e.g., "This is my blue umbrella, I lost it on Tuesday"',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitClaim,
                          child: const Text('Submit Claim'),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
