import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_spacing.dart';

/// Theme Settings Bottom Sheet
/// Allows users to configure theme mode preferences
class ThemeSettingsBottomSheet extends StatelessWidget {
  const ThemeSettingsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.m,
        right: AppSpacing.m,
        top: AppSpacing.m,
        bottom: MediaQuery.of(context).padding.bottom + AppSpacing.m,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLarge),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text('Appearance', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Customize how Crazy Trip looks on your device',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: AppSpacing.l),

          // Theme mode options
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return Column(
                children: [
                  _ThemeModeOption(
                    title: 'Light',
                    subtitle: 'Always use light theme',
                    icon: Icons.light_mode_rounded,
                    isSelected:
                        themeProvider.themeMode == ThemeMode.light &&
                        !themeProvider.autoModeEnabled,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  _ThemeModeOption(
                    title: 'Dark',
                    subtitle: 'Always use dark theme',
                    icon: Icons.dark_mode_rounded,
                    isSelected:
                        themeProvider.themeMode == ThemeMode.dark &&
                        !themeProvider.autoModeEnabled,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  _ThemeModeOption(
                    title: 'System',
                    subtitle: 'Follow system settings',
                    icon: Icons.brightness_auto_rounded,
                    isSelected:
                        themeProvider.themeMode == ThemeMode.system &&
                        !themeProvider.autoModeEnabled,
                    onTap: () => themeProvider.useSystemTheme(),
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  _ThemeModeOption(
                    title: 'Auto Schedule',
                    subtitle:
                        'Dark mode ${themeProvider.scheduleStartHour}:00 - '
                        '${themeProvider.scheduleEndHour}:00',
                    icon: Icons.schedule_rounded,
                    isSelected: themeProvider.autoModeEnabled,
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      onPressed: () {
                        Navigator.pop(context);
                        _showScheduleDialog(context, themeProvider);
                      },
                    ),
                    onTap:
                        () => themeProvider.setAutoMode(
                          !themeProvider.autoModeEnabled,
                        ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ThemeSettingsBottomSheet(),
    );
  }

  static void _showScheduleDialog(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    int startHour = themeProvider.scheduleStartHour;
    int endHour = themeProvider.scheduleEndHour;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Set Dark Mode Schedule'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Dark mode will activate between these hours:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Start time
                    Row(
                      children: [
                        const Icon(Icons.nightlight_round),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Start'),
                              Slider(
                                value: startHour.toDouble(),
                                min: 0,
                                max: 23,
                                divisions: 23,
                                label: '$startHour:00',
                                onChanged: (value) {
                                  setState(() => startHour = value.toInt());
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$startHour:00',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.s),

                    // End time
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('End'),
                              Slider(
                                value: endHour.toDouble(),
                                min: 0,
                                max: 23,
                                divisions: 23,
                                label: '$endHour:00',
                                onChanged: (value) {
                                  setState(() => endHour = value.toInt());
                                },
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '$endHour:00',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () {
                      themeProvider.setSchedule(startHour, endHour);
                      themeProvider.setAutoMode(true);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ThemeModeOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color:
          isSelected
              ? colorScheme.primaryContainer.withOpacity(0.5)
              : Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isSelected
                      ? colorScheme.primary
                      : colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isSelected ? colorScheme.primary : null,
                        fontWeight: isSelected ? FontWeight.w600 : null,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing!
              else if (isSelected)
                Icon(Icons.check_circle_rounded, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
