import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/reel.dart';
import '../models/promotion.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Seguidos', 'Tendencias'];
  final PageController _pageController = PageController();
  int _currentReelIndex = 0;

  // Mock data
  late List<Reel> _reels;
  late List<Promotion> _promotions;

  @override
  void initState() {
    super.initState();
    _reels = getMockReels();
    _promotions = getMockPromotions().where((p) => p.isActive).take(3).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content - Vertical scrolling reels
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _reels.length,
            onPageChanged: (index) {
              setState(() {
                _currentReelIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildReelItem(_reels[index]);
            },
          ),

          // Top bar with filters
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

          // Promotions banner (appears between some reels)
          if (_currentReelIndex % 5 == 0 && _currentReelIndex > 0)
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: _buildPromotionBanner(),
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + AppSpacing.s,
        left: AppSpacing.m,
        right: AppSpacing.m,
        bottom: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.7), Colors.black.withOpacity(0)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            _filters.map((filter) {
              final isSelected = filter == _selectedFilter;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        height: 2,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildReelItem(Reel reel) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Video placeholder (replace with video player)
        Container(
          color: Colors.grey[900],
          child: Image.network(
            reel.thumbnailUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[800],
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 80,
                    color: Colors.white54,
                  ),
                ),
              );
            },
          ),
        ),

        // Gradient overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
              ),
            ),
          ),
        ),

        // Right side actions
        Positioned(
          right: AppSpacing.m,
          bottom: 120,
          child: _buildActionButtons(reel),
        ),

        // Bottom info
        Positioned(
          left: AppSpacing.m,
          right: 80,
          bottom: 100,
          child: _buildReelInfo(reel),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Reel reel) {
    return Column(
      children: [
        // Profile avatar
        _buildActionItem(
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(reel.userAvatar),
            backgroundColor: AppColors.primaryColor,
          ),
          label: null,
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.l),

        // Like
        _buildActionItem(
          icon: reel.isLikedByMe ? Icons.favorite : Icons.favorite_border,
          label: _formatCount(reel.likes),
          color: reel.isLikedByMe ? Colors.red : Colors.white,
          onTap: () {
            setState(() {
              _reels[_currentReelIndex] = reel.copyWith(
                isLikedByMe: !reel.isLikedByMe,
                likes: reel.isLikedByMe ? reel.likes - 1 : reel.likes + 1,
              );
            });
          },
        ),
        const SizedBox(height: AppSpacing.l),

        // Comment
        _buildActionItem(
          icon: Icons.comment,
          label: _formatCount(reel.comments),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.l),

        // Share
        _buildActionItem(
          icon: Icons.share,
          label: _formatCount(reel.shares),
          onTap: () {},
        ),
        const SizedBox(height: AppSpacing.l),

        // CrazyDex items
        if (reel.crazyDexItemIds.isNotEmpty)
          _buildActionItem(
            icon: Icons.catching_pokemon,
            label: '${reel.crazyDexItemIds.length}',
            color: AppColors.achievementColor,
            onTap: () {},
          ),
      ],
    );
  }

  Widget _buildActionItem({
    IconData? icon,
    Widget? child,
    required String? label,
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          if (child != null)
            child
          else if (icon != null)
            Icon(icon, color: color, size: 32),
          if (label != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReelInfo(Reel reel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Username
        Text(
          '@${reel.username}',
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),

        // Caption
        Text(
          reel.caption,
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.s),

        // Location
        if (reel.locationName != null)
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  reel.locationName!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white70,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPromotionBanner() {
    if (_promotions.isEmpty) return const SizedBox.shrink();

    final promo = _promotions.first;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
            ),
            child: const Icon(Icons.local_offer, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.m),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.title,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  promo.businessName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Arrow
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
