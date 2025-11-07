/// Model representing a user profile
class UserProfile {
  final String id;
  final String username;
  final String avatarEmoji;
  final int level;
  final int currentXP;
  final int xpToNextLevel;
  final int totalDiscoveries;
  final int streak;
  final DateTime joinedAt;
  final String bio;
  final List<String> favoriteCategories;

  UserProfile({
    required this.id,
    required this.username,
    required this.avatarEmoji,
    required this.level,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.totalDiscoveries,
    required this.streak,
    required this.joinedAt,
    required this.bio,
    required this.favoriteCategories,
  });

  double get levelProgress => currentXP / xpToNextLevel;

  static UserProfile getMockProfile() {
    return UserProfile(
      id: 'user_001',
      username: 'AdventureSeeker',
      avatarEmoji: '🎒',
      level: 12,
      currentXP: 3450,
      xpToNextLevel: 5000,
      totalDiscoveries: 47,
      streak: 9,
      joinedAt: DateTime.now().subtract(const Duration(days: 90)),
      bio: 'Exploring the world one discovery at a time! 🌍✨',
      favoriteCategories: ['Nature', 'Historical', 'Art'],
    );
  }
}

/// Model for leaderboard entries
class LeaderboardEntry {
  final String userId;
  final String username;
  final String avatarEmoji;
  final int rank;
  final int totalXP;
  final int discoveries;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.avatarEmoji,
    required this.rank,
    required this.totalXP,
    required this.discoveries,
    this.isCurrentUser = false,
  });

  static List<LeaderboardEntry> getMockLeaderboard() {
    return [
      LeaderboardEntry(
        userId: 'user_top1',
        username: 'ExplorerPro',
        avatarEmoji: '🏆',
        rank: 1,
        totalXP: 15420,
        discoveries: 132,
      ),
      LeaderboardEntry(
        userId: 'user_top2',
        username: 'WanderlustQueen',
        avatarEmoji: '👸',
        rank: 2,
        totalXP: 14230,
        discoveries: 118,
      ),
      LeaderboardEntry(
        userId: 'user_top3',
        username: 'CityScout',
        avatarEmoji: '🗺️',
        rank: 3,
        totalXP: 13890,
        discoveries: 105,
      ),
      LeaderboardEntry(
        userId: 'user_4',
        username: 'NatureNomad',
        avatarEmoji: '🌲',
        rank: 4,
        totalXP: 12670,
        discoveries: 98,
      ),
      LeaderboardEntry(
        userId: 'user_5',
        username: 'UrbanAdventurer',
        avatarEmoji: '🏙️',
        rank: 5,
        totalXP: 11340,
        discoveries: 87,
      ),
      LeaderboardEntry(
        userId: 'user_001',
        username: 'AdventureSeeker',
        avatarEmoji: '🎒',
        rank: 12,
        totalXP: 8450,
        discoveries: 47,
        isCurrentUser: true,
      ),
    ];
  }
}
