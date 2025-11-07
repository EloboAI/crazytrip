import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable stat card for displaying statistics
class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool compact;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.s : AppSpacing.m),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: compact ? AppSpacing.iconMedium : AppSpacing.iconLarge,
            ),
            SizedBox(height: compact ? 4 : AppSpacing.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: (compact
                        ? AppTextStyles.titleLarge
                        : AppTextStyles.headlineSmall)
                    .copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick stat card for compact displays
class QuickStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? iconColor;

  const QuickStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return StatCard(
      icon: icon,
      value: value,
      label: label,
      color: iconColor ?? AppColors.primaryColor,
      compact: true,
    );
  }
}
