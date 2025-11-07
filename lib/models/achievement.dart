/// Model representing a user achievement
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int xpReward;
  final String category;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int progress;
  final int maxProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.xpReward,
    required this.category,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.progress,
    required this.maxProgress,
  });

  double get progressPercentage => progress / maxProgress;

  static List<Achievement> getMockAchievements() {
    return [
      Achievement(
        id: '1',
        name: 'First Steps',
        description: 'Complete your first discovery',
        icon: '👣',
        xpReward: 50,
        category: 'Beginner',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 7)),
        progress: 1,
        maxProgress: 1,
      ),
      Achievement(
        id: '2',
        name: 'Explorer',
        description: 'Discover 10 different locations',
        icon: '🧭',
        xpReward: 200,
        category: 'Progress',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 3)),
        progress: 10,
        maxProgress: 10,
      ),
      Achievement(
        id: '3',
        name: 'Nature Lover',
        description: 'Find 5 natural landmarks',
        icon: '🌿',
        xpReward: 150,
        category: 'Category',
        isUnlocked: false,
        progress: 3,
        maxProgress: 5,
      ),
      Achievement(
        id: '4',
        name: 'City Slicker',
        description: 'Explore 15 urban locations',
        icon: '🏙️',
        xpReward: 250,
        category: 'Category',
        isUnlocked: false,
        progress: 8,
        maxProgress: 15,
      ),
      Achievement(
        id: '5',
        name: 'History Buff',
        description: 'Visit 10 historical sites',
        icon: '📚',
        xpReward: 300,
        category: 'Category',
        isUnlocked: false,
        progress: 4,
        maxProgress: 10,
      ),
      Achievement(
        id: '6',
        name: 'Weekly Warrior',
        description: 'Maintain a 7-day streak',
        icon: '🔥',
        xpReward: 500,
        category: 'Streak',
        isUnlocked: true,
        unlockedAt: DateTime.now().subtract(const Duration(days: 1)),
        progress: 7,
        maxProgress: 7,
      ),
      Achievement(
        id: '7',
        name: 'Social Butterfly',
        description: 'Share 20 discoveries with friends',
        icon: '🦋',
        xpReward: 180,
        category: 'Social',
        isUnlocked: false,
        progress: 12,
        maxProgress: 20,
      ),
      Achievement(
        id: '8',
        name: 'Master Explorer',
        description: 'Reach level 25',
        icon: '👑',
        xpReward: 1000,
        category: 'Milestone',
        isUnlocked: false,
        progress: 12,
        maxProgress: 25,
      ),
      Achievement(
        id: '9',
        name: 'AR Pioneer',
        description: 'Use AR scanner 50 times',
        icon: '📱',
        xpReward: 400,
        category: 'Tech',
        isUnlocked: false,
        progress: 28,
        maxProgress: 50,
      ),
      Achievement(
        id: '10',
        name: 'Globe Trotter',
        description: 'Visit locations in 5 different cities',
        icon: '🌍',
        xpReward: 600,
        category: 'Travel',
        isUnlocked: false,
        progress: 2,
        maxProgress: 5,
      ),
    ];
  }
}
