import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/discovery.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final discoveries = Discovery.getMockDiscoveries();
    final unlockedDiscoveries = discoveries.where((d) => d.isUnlocked).toList();
    final nearbyDiscoveries = discoveries.where((d) => !d.isUnlocked).toList();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              floating: true,
              snap: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover amazing places',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              toolbarHeight: 80,
            ),

            // Recent Discoveries Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: AppSpacing.iconSmall,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Recent Discoveries',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Recent Discoveries Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: unlockedDiscoveries.length,
                  itemBuilder: (context, index) {
                    final discovery = unlockedDiscoveries[index];
                    return _DiscoveryCard(discovery: discovery);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),

            // Nearby Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Row(
                  children: [
                    Icon(
                      Icons.explore,
                      size: AppSpacing.iconSmall,
                      color: AppColors.tertiaryColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Nearby & Unexplored',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Nearby Discoveries Grid
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.m),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: AppSpacing.m,
                  mainAxisSpacing: AppSpacing.m,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final discovery = nearbyDiscoveries[index];
                    return _NearbyDiscoveryCard(discovery: discovery);
                  },
                  childCount: nearbyDiscoveries.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final Discovery discovery;

  const _DiscoveryCard({required this.discovery});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: AppSpacing.m),
      child: Card(
        elevation: AppSpacing.elevationLow,
        child: InkWell(
          onTap: () {
            // Navigation to detail screen would go here
          },
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
                child: Center(
                  child: Text(
                    discovery.imageUrl,
                    style: const TextStyle(fontSize: 48),
                  ),
                ),
              ),
              // Content Section
              Padding(
                padding: const EdgeInsets.all(AppSpacing.s),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Chip(
                          label: Text(discovery.category),
                          labelStyle: AppTextStyles.labelSmall,
                          backgroundColor: AppColors.tertiaryColor.withOpacity(0.2),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
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
            ],
          ),
        ),
      ),
    );
  }
}

class _NearbyDiscoveryCard extends StatelessWidget {
  final Discovery discovery;

  const _NearbyDiscoveryCard({required this.discovery});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.elevationLow,
      child: InkWell(
        onTap: () {
          // Navigation to detail screen would go here
        },
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
                    // Lock overlay for unexplored
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
                    Text(
                      discovery.name,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
