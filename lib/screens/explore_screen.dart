import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/discovery.dart';
import '../widgets/discovery_card.dart';
import '../widgets/section_header.dart';

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
                      color: Theme.of(
                        context,
                      ).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              toolbarHeight: 80,
            ),

            // Recent Discoveries Section
            const SliverToBoxAdapter(
              child: SectionHeader(
                icon: Icons.history,
                title: 'Recent Discoveries',
              ),
            ),

            // Recent Discoveries Horizontal List
            SliverToBoxAdapter(
              child: SizedBox(
                height: 224,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: unlockedDiscoveries.length,
                  itemBuilder: (context, index) {
                    final discovery = unlockedDiscoveries[index];
                    return DiscoveryCard(discovery: discovery);
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.l)),

            // Nearby Section
            const SliverToBoxAdapter(
              child: SectionHeader(
                icon: Icons.explore,
                title: 'Nearby & Unexplored',
                iconColor: AppColors.tertiaryColor,
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
                delegate: SliverChildBuilderDelegate((context, index) {
                  final discovery = nearbyDiscoveries[index];
                  return CompactDiscoveryCard(
                    discovery: discovery,
                    showLock: true,
                  );
                }, childCount: nearbyDiscoveries.length),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
