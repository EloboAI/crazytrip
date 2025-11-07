import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/achievement.dart';
import '../models/user_profile.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = UserProfile.getMockProfile();
    final achievements = Achievement.getMockAchievements();
    final unlockedAchievements = achievements.where((a) => a.isUnlocked).toList();
    final inProgressAchievements = achievements.where((a) => !a.isUnlocked).toList();
    final leaderboard = LeaderboardEntry.getMockLeaderboard();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with Level Progress
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.primaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Level ${profile.level}',
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${profile.currentXP} / ${profile.xpToNextLevel} XP',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      // Streak Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.m,
                          vertical: AppSpacing.s,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: AppColors.streakColor,
                              size: AppSpacing.iconMedium,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${profile.streak} days',
                              style: AppTextStyles.titleMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                    child: LinearProgressIndicator(
                      value: profile.levelProgress,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Theme.of(context).colorScheme.outline,
                indicatorColor: AppColors.primaryColor,
                labelStyle: AppTextStyles.labelLarge,
                tabs: const [
                  Tab(text: 'Achievements'),
                  Tab(text: 'Leaderboard'),
                  Tab(text: 'Stats'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Achievements Tab
                  ListView(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    children: [
                      Text(
                        'Unlocked (${unlockedAchievements.length})',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      ...unlockedAchievements.map((achievement) =>
                          _AchievementCard(achievement: achievement)),
                      const SizedBox(height: AppSpacing.l),
                      Text(
                        'In Progress (${inProgressAchievements.length})',
                        style: AppTextStyles.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.s),
                      ...inProgressAchievements.map((achievement) =>
                          _AchievementCard(achievement: achievement)),
                    ],
                  ),

                  // Leaderboard Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    itemCount: leaderboard.length,
                    itemBuilder: (context, index) {
                      return _LeaderboardCard(entry: leaderboard[index]);
                    },
                  ),

                  // Stats Tab
                  _StatsTab(profile: profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: achievement.isUnlocked
                    ? LinearGradient(
                        colors: AppColors.achievementGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: achievement.isUnlocked
                    ? null
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              ),
              child: Center(
                child: Text(
                  achievement.icon,
                  style: TextStyle(
                    fontSize: 28,
                    color: achievement.isUnlocked
                        ? Colors.white
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: AppTextStyles.titleMedium.copyWith(
                      color: achievement.isUnlocked
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  if (!achievement.isUnlocked) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                            child: LinearProgressIndicator(
                              value: achievement.progressPercentage,
                              minHeight: 6,
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${achievement.progress}/${achievement.maxProgress}',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // XP Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: AppColors.xpColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.stars,
                    size: AppSpacing.iconXSmall,
                    color: AppColors.xpColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+${achievement.xpReward}',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.xpColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardCard({required this.entry});

  Color _getRankColor() {
    switch (entry.rank) {
      case 1:
        return AppColors.goldColor;
      case 2:
        return AppColors.silverColor;
      case 3:
        return AppColors.bronzeColor;
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      color: entry.isCurrentUser
          ? AppColors.primaryColor.withOpacity(0.1)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor().withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '#${entry.rank}',
                  style: AppTextStyles.titleSmall.copyWith(
                    color: _getRankColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.discoveryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  entry.avatarEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.username,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: entry.isCurrentUser
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    '${entry.discoveries} discoveries',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // XP
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalXP}',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.xpColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'XP',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  final UserProfile profile;

  const _StatsTab({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.m),
      children: [
        // Overview Stats
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.explore,
                value: profile.totalDiscoveries.toString(),
                label: 'Discoveries',
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _StatCard(
                icon: Icons.local_fire_department,
                value: '${profile.streak}',
                label: 'Day Streak',
                color: AppColors.streakColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.stars,
                value: '${profile.currentXP}',
                label: 'Total XP',
                color: AppColors.xpColor,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: _StatCard(
                icon: Icons.military_tech,
                value: 'Level ${profile.level}',
                label: 'Explorer Rank',
                color: AppColors.achievementColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.l),

        // Favorite Categories
        Text(
          'Favorite Categories',
          style: AppTextStyles.titleMedium,
        ),
        const SizedBox(height: AppSpacing.s),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: profile.favoriteCategories.map((category) {
            return Chip(
              label: Text(category),
              backgroundColor: AppColors.tertiaryColor.withOpacity(0.2),
              side: BorderSide.none,
            );
          }).toList(),
        ),

        const SizedBox(height: AppSpacing.l),

        // Member Since
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryColor,
                ),
                const SizedBox(width: AppSpacing.m),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Member Since',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    Text(
                      '${profile.joinedAt.day}/${profile.joinedAt.month}/${profile.joinedAt.year}',
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: AppSpacing.iconLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
