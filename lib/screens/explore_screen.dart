import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/discovery.dart';
import '../models/promotion.dart';
import '../widgets/discovery_card.dart';
import '../widgets/section_header.dart';
import 'promotions_screen.dart';
import 'create_content_screen.dart';
import 'discovery_crazydex_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  Widget _buildPromotionsBanner(BuildContext context) {
    final activePromotions = PromotionFilters.getActive(getMockPromotions());
    final promotionCount = activePromotions.length;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.streakColor, AppColors.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PromotionsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                // Fire animation icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('🔥', style: TextStyle(fontSize: 32)),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Promociones',
                            style: AppTextStyles.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'NUEVO',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.streakColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$promotionCount concursos activos ahora',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premios y descuentos exclusivos',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Discover amazing places',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              toolbarHeight: 80,
            ),

            // Promotions Banner
            SliverToBoxAdapter(child: _buildPromotionsBanner(context)),

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
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                  itemCount: unlockedDiscoveries.length,
                  itemBuilder: (context, index) {
                    final discovery = unlockedDiscoveries[index];
                    return DiscoveryCard(
                      discovery: discovery,
                      onShare: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    CreateContentScreen(discovery: discovery),
                          ),
                        );
                      },
                      onCrazyDexTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    DiscoveryCrazyDexScreen(discovery: discovery),
                          ),
                        );
                      },
                    );
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
                    onCrazyDexTap: discovery.crazyDexItemsAvailable > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        DiscoveryCrazyDexScreen(discovery: discovery),
                              ),
                            );
                          }
                        : null,
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
