import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../theme/app_theme.dart';

class ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final bool hasPendingClaims;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
    this.hasPendingClaims = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLost = item.type == ItemType.lost;
    final statusColor = isLost ? AppTheme.lost : AppTheme.found;
    final statusBg = isLost ? AppTheme.lostLight : AppTheme.foundLight;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image thumbnail with status accent
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: SizedBox(
                      width: 76,
                      height: 76,
                      child: item.imageBytes != null
                          ? Image.memory(
                              item.imageBytes!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: AppTheme.divider,
                              child: const Icon(
                                Icons.image_outlined,
                                size: 32,
                                color: AppTheme.textMuted,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isLost ? 'Lost' : 'Found',
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 14, color: AppTheme.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            '${item.date.day}/${item.date.month}/${item.date.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          if (hasPendingClaims) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.warningLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Pending claims',
                                style: TextStyle(
                                  color: AppTheme.warning,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
