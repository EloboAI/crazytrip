import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/promotion.dart';

/// Reusable promotion card for lists
class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback? onTap;

  const PromotionCard({super.key, required this.promotion, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevationMedium,
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with image/gradient
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(promotion.type),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusMedium),
                ),
              ),
              child: Stack(
                children: [
                  // Emoji Icon
                  Center(
                    child: Text(
                      promotion.imageUrl,
                      style: const TextStyle(fontSize: 56),
                    ),
                  ),
                  // Type Badge
                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            promotion.type.emoji,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            promotion.type.displayName,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Status indicator (if expired)
                  if (promotion.isExpired)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusMedium),
                          ),
                        ),
                        child: const Center(
                          child: Chip(
                            label: Text(
                              'Finalizada',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    promotion.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: AppSpacing.iconXSmall,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          promotion.location,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  // Description
                  Text(
                    promotion.description,
                    style: AppTextStyles.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Prize & XP Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: AppColors.xpColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSmall,
                      ),
                      border: Border.all(
                        color: AppColors.xpColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: AppColors.goldColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            promotion.prize,
                            style: AppTextStyles.labelMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.goldColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (promotion.xpReward > 0) ...[
                          const SizedBox(width: AppSpacing.xs),
                          Icon(
                            Icons.star,
                            size: AppSpacing.iconXSmall,
                            color: AppColors.xpColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${promotion.xpReward}',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.xpColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Bottom Row: Time & Participants
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Time remaining
                      Row(
                        children: [
                          Icon(
                            promotion.isExpired
                                ? Icons.check_circle
                                : Icons.access_time,
                            size: AppSpacing.iconXSmall,
                            color:
                                promotion.isExpired
                                    ? Colors.grey
                                    : (promotion.daysRemaining <= 3
                                        ? AppColors.errorColor
                                        : AppColors.tertiaryColor),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            promotion.statusText,
                            style: AppTextStyles.labelSmall.copyWith(
                              color:
                                  promotion.isExpired
                                      ? Colors.grey
                                      : (promotion.daysRemaining <= 3
                                          ? AppColors.errorColor
                                          : AppColors.tertiaryColor),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Participants
                      if (!promotion.isUpcoming)
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: AppSpacing.iconXSmall,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${promotion.participantCount} participantes',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(PromotionType type) {
    switch (type) {
      case PromotionType.contest:
        return [AppColors.goldColor, AppColors.goldColor.withOpacity(0.7)];
      case PromotionType.discount:
        return AppColors.primaryGradient;
      case PromotionType.event:
        return AppColors.discoveryGradient;
      case PromotionType.challenge:
        return AppColors.achievementGradient;
    }
  }
}

/// Compact promotion card for grid/compact layouts
class CompactPromotionCard extends StatelessWidget {
  final Promotion promotion;
  final VoidCallback? onTap;

  const CompactPromotionCard({super.key, required this.promotion, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevationLow,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with gradient
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getGradientColors(promotion.type),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSpacing.radiusMedium),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        promotion.imageUrl,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    if (promotion.isExpired)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusMedium),
                          ),
                        ),
                      ),
                    // Type emoji in corner
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Text(
                        promotion.type.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      promotion.title,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    // Time indicator
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color:
                              promotion.daysRemaining <= 3
                                  ? AppColors.errorColor
                                  : AppColors.tertiaryColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            promotion.statusText,
                            style: AppTextStyles.labelSmall.copyWith(
                              color:
                                  promotion.daysRemaining <= 3
                                      ? AppColors.errorColor
                                      : AppColors.tertiaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // XP reward
                    if (promotion.xpReward > 0)
                      Row(
                        children: [
                          Icon(Icons.star, size: 14, color: AppColors.xpColor),
                          const SizedBox(width: 4),
                          Text(
                            '+${promotion.xpReward} XP',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.xpColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _getGradientColors(PromotionType type) {
    switch (type) {
      case PromotionType.contest:
        return [AppColors.goldColor, AppColors.goldColor.withOpacity(0.7)];
      case PromotionType.discount:
        return AppColors.primaryGradient;
      case PromotionType.event:
        return AppColors.discoveryGradient;
      case PromotionType.challenge:
        return AppColors.achievementGradient;
    }
  }
}
