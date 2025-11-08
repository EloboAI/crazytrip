class Reel {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String videoUrl;
  final String thumbnailUrl;
  final String caption;
  final List<String> tags;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final List<String> crazyDexItemIds; // Items que aparecen en el reel
  final int likes;
  final int comments;
  final int shares;
  final int views;
  final DateTime createdAt;
  final bool isLikedByMe;

  Reel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.caption,
    this.tags = const [],
    this.locationName,
    this.latitude,
    this.longitude,
    this.crazyDexItemIds = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.views = 0,
    required this.createdAt,
    this.isLikedByMe = false,
  });

  Reel copyWith({
    String? id,
    String? userId,
    String? username,
    String? userAvatar,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    List<String>? tags,
    String? locationName,
    double? latitude,
    double? longitude,
    List<String>? crazyDexItemIds,
    int? likes,
    int? comments,
    int? shares,
    int? views,
    DateTime? createdAt,
    bool? isLikedByMe,
  }) {
    return Reel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      userAvatar: userAvatar ?? this.userAvatar,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      tags: tags ?? this.tags,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      crazyDexItemIds: crazyDexItemIds ?? this.crazyDexItemIds,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shares: shares ?? this.shares,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
    );
  }
}

// Mock data para desarrollo
List<Reel> getMockReels() {
  return [
    Reel(
      id: 'reel_1',
      userId: 'user_1',
      username: 'maria_travels',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      videoUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=1',
      caption: '¡Encontré un Quetzal en Monteverde! 🦜✨ #CostaRica #CrazyDex',
      tags: ['costarica', 'crazydex', 'monteverde', 'quetzal'],
      locationName: 'Monteverde Cloud Forest',
      latitude: 10.3009,
      longitude: -84.8207,
      crazyDexItemIds: ['cdi_1'], // Quetzal
      likes: 245,
      comments: 12,
      shares: 8,
      views: 1200,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isLikedByMe: false,
    ),
    Reel(
      id: 'reel_2',
      userId: 'user_2',
      username: 'aventurero_gt',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      videoUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=2',
      caption: 'Gallo Pinto casero 🍚🇨🇷 Receta tradicional de mi abuela',
      tags: ['food', 'gallopinto', 'costarica', 'tradicional'],
      locationName: 'San José, Costa Rica',
      latitude: 9.9281,
      longitude: -84.0907,
      crazyDexItemIds: ['cdi_9'], // Gallo Pinto
      likes: 567,
      comments: 34,
      shares: 15,
      views: 3400,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isLikedByMe: true,
    ),
    Reel(
      id: 'reel_3',
      userId: 'user_3',
      username: 'nature_lover_cr',
      userAvatar: 'https://i.pravatar.cc/150?img=3',
      videoUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=3',
      caption: 'Perezoso tomando una siesta 🦥💤 #PuraVida',
      tags: ['sloth', 'wildlife', 'manuelantonio', 'puravida'],
      locationName: 'Manuel Antonio National Park',
      latitude: 9.3905,
      longitude: -84.1431,
      crazyDexItemIds: ['cdi_5'], // Perezoso
      likes: 892,
      comments: 45,
      shares: 23,
      views: 5600,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      isLikedByMe: false,
    ),
    Reel(
      id: 'reel_4',
      userId: 'user_4',
      username: 'foodie_tico',
      userAvatar: 'https://i.pravatar.cc/150?img=4',
      videoUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=4',
      caption: 'Casado típico en soda local 🍽️ ¡Delicioso!',
      tags: ['casado', 'comidatica', 'food', 'costarica'],
      locationName: 'Soda La Tica, San José',
      latitude: 9.9350,
      longitude: -84.0850,
      crazyDexItemIds: ['cdi_10'], // Casado
      likes: 423,
      comments: 28,
      shares: 11,
      views: 2100,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      isLikedByMe: true,
    ),
    Reel(
      id: 'reel_5',
      userId: 'user_5',
      username: 'explorer_506',
      userAvatar: 'https://i.pravatar.cc/150?img=5',
      videoUrl:
          'https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      thumbnailUrl: 'https://picsum.photos/400/600?random=5',
      caption: 'Ranita verde escondida 🐸 ¿La ves? #HiddenGem',
      tags: ['frog', 'wildlife', 'nature', 'costarica'],
      locationName: 'La Fortuna',
      latitude: 10.4675,
      longitude: -84.6425,
      crazyDexItemIds: ['cdi_7'], // Rana Calzonuda
      likes: 678,
      comments: 19,
      shares: 14,
      views: 4200,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isLikedByMe: false,
    ),
  ];
}
