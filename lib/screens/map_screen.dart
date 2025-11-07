import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Simulated Map Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.tertiary.withOpacity(0.3),
                  Theme.of(context).colorScheme.surface,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 120,
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                  const SizedBox(height: AppSpacing.m),
                  Text(
                    'Interactive Map View',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Map integration would display here',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusPill,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: AppSpacing.s),
                        Expanded(
                          child: Text(
                            'Search locations...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.tune,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.m),

                  // Filter Chips
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _FilterChip(label: 'All', isSelected: true),
                        _FilterChip(label: 'Nature 🌿', isSelected: false),
                        _FilterChip(label: 'Historical 🏛️', isSelected: false),
                        _FilterChip(label: 'Food ☕', isSelected: false),
                        _FilterChip(label: 'Art 🎨', isSelected: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet with nearby discoveries
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLarge),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nearby Discoveries',
                          style: AppTextStyles.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.s),
                        Text(
                          '5 locations within 2 km',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.m),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 5,
                            itemBuilder: (context, index) {
                              return _NearbyLocationCard(index: index);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Location Button
          Positioned(
            right: AppSpacing.m,
            bottom: 200,
            child: FloatingActionButton(
              onPressed: () {},
              heroTag: 'map_location_fab', // Fix: Add unique hero tag
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: Icon(
                Icons.my_location,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool value) {},
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedColor: AppColors.primaryColor.withOpacity(0.2),
        checkmarkColor: AppColors.primaryColor,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color:
              isSelected
                  ? AppColors.primaryColor
                  : Theme.of(context).colorScheme.onSurface,
        ),
        side: BorderSide(
          color:
              isSelected
                  ? AppColors.primaryColor
                  : Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _NearbyLocationCard extends StatelessWidget {
  final int index;

  const _NearbyLocationCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final icons = ['🌳', '🏛️', '☕', '🎨', '🏖️'];
    final names = ['Park', 'Museum', 'Cafe', 'Gallery', 'Beach'];
    final distances = ['0.5 km', '0.8 km', '1.2 km', '1.5 km', '1.9 km'];

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppSpacing.s),
      child: Card(
        elevation: AppSpacing.elevationLow,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                  ),
                  child: Center(
                    child: Text(
                      icons[index],
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        names[index],
                        style: AppTextStyles.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        distances[index],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
