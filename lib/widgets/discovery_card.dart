import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/discovery.dart';

/// Reusable discovery card for horizontal lists
class DiscoveryCard extends StatelessWidget {
  final Discovery discovery;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onCrazyDexTap;

  const DiscoveryCard({
    super.key,
    required this.discovery,
    this.onTap,
    this.onShare,
    this.onCrazyDexTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.m),
      child: Card(
        elevation: AppSpacing.elevationLow,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Icon Section
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.discoveryGradient,
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
                        discovery.imageUrl,
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                    // CrazyDex Badge
                    if (discovery.crazyDexItemsAvailable > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: onCrazyDexTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.catching_pokemon,
                                  size: 16,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${discovery.crazyDexItemsCollected}/${discovery.crazyDexItemsAvailable}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Content Section - FIXED: Wrapped in Expanded
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            discovery.name,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
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
                                  discovery.location,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (onShare != null)
                            IconButton(
                              onPressed: onShare,
                              icon: const Icon(Icons.video_camera_back),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.errorColor
                                    .withOpacity(0.1),
                                foregroundColor: AppColors.errorColor,
                              ),
                              tooltip: 'Crear Reel',
                            ),
                          if (onShare != null) const SizedBox(width: 8),
                          Flexible(
                            child: Chip(
                              label: Text(
                                discovery.category,
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.tertiaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              backgroundColor: AppColors.tertiaryColor
                                  .withOpacity(0.15),
                              side: BorderSide(
                                color: AppColors.tertiaryColor,
                                width: 1.5,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.star,
                            size: AppSpacing.iconXSmall,
                            color: AppColors.xpColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+${discovery.xpReward}',
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
      ),
    );
  }
}

/// Compact discovery card for grid layouts
class CompactDiscoveryCard extends StatelessWidget {
  final Discovery discovery;
  final VoidCallback? onTap;
  final VoidCallback? onCrazyDexTap;
  final bool showLock;

  const CompactDiscoveryCard({
    super.key,
    required this.discovery,
    this.onTap,
    this.onCrazyDexTap,
    this.showLock = false,
  });

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
            // Image/Icon Section
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.achievementGradient,
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
                        discovery.imageUrl,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    if (showLock)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(AppSpacing.radiusMedium),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    // CrazyDex Badge
                    if (discovery.crazyDexItemsAvailable > 0)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: onCrazyDexTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.catching_pokemon,
                                  size: 12,
                                  color: AppColors.primaryColor,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${discovery.crazyDexItemsCollected}/${discovery.crazyDexItemsAvailable}',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        discovery.name,
                        style: AppTextStyles.titleSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: AppSpacing.iconXSmall,
                          color: AppColors.xpColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${discovery.xpReward}',
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
}
