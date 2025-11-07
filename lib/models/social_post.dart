import 'discovery.dart';

/// Social media platforms supported
enum SocialPlatform { instagram, tiktok, facebook, twitter }

extension SocialPlatformExtension on SocialPlatform {
  String get displayName {
    switch (this) {
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.twitter:
        return 'Twitter';
    }
  }

  String get icon {
    switch (this) {
      case SocialPlatform.instagram:
        return '📷';
      case SocialPlatform.tiktok:
        return '🎵';
      case SocialPlatform.facebook:
        return '👥';
      case SocialPlatform.twitter:
        return '🐦';
    }
  }

  String get color {
    switch (this) {
      case SocialPlatform.instagram:
        return '#E4405F';
      case SocialPlatform.tiktok:
        return '#000000';
      case SocialPlatform.facebook:
        return '#1877F2';
      case SocialPlatform.twitter:
        return '#1DA1F2';
    }
  }
}

/// Type of social content
enum SocialContentType { photo, video, reel, story }

/// Model for social media posts created in-app
class SocialPost {
  final String id;
  final String userId;
  final Discovery? linkedDiscovery; // Optional link to discovered location
  final SocialContentType contentType;
  final String? videoPath; // Local path or URL
  final String? imagePath;
  final String caption;
  final List<String> hashtags;
  final List<SocialPlatform> targetPlatforms;
  final DateTime createdAt;
  final bool isPublished;
  final Map<SocialPlatform, String>? publishedUrls; // URLs after publishing
  final int views;
  final int likes;
  final int shares;
  final bool isGeotagged;
  final double? latitude;
  final double? longitude;

  SocialPost({
    required this.id,
    required this.userId,
    this.linkedDiscovery,
    required this.contentType,
    this.videoPath,
    this.imagePath,
    required this.caption,
    required this.hashtags,
    required this.targetPlatforms,
    required this.createdAt,
    this.isPublished = false,
    this.publishedUrls,
    this.views = 0,
    this.likes = 0,
    this.shares = 0,
    this.isGeotagged = true,
    this.latitude,
    this.longitude,
  });

  /// Generate automatic caption with discovery info
  static String generateCaption({
    required Discovery discovery,
    String? userComment,
  }) {
    final comment = userComment ?? '¡Descubrí este increíble lugar!';
    return '''
$comment

📍 ${discovery.name}
📌 ${discovery.location}
${discovery.category == 'Food'
        ? '🍽️'
        : discovery.category == 'Nature'
        ? '🌿'
        : '✨'} ${discovery.category}

#CrazyTrip #${discovery.category}Lover #Explore${discovery.location.split(',').first.replaceAll(' ', '')}
''';
  }

  /// Generate automatic hashtags based on discovery
  static List<String> generateHashtags(Discovery discovery) {
    final baseHashtags = ['CrazyTrip', 'Explore', 'Travel', 'Adventure'];

    // Category-specific hashtags
    final categoryHashtags = {
      'Food': ['Foodie', 'FoodPorn', 'Delicious', 'FoodLovers'],
      'Nature': ['NatureLover', 'Outdoors', 'NaturePhotography', 'Hiking'],
      'Historical': ['History', 'Culture', 'Heritage', 'Architecture'],
      'Art': ['ArtLovers', 'StreetArt', 'Gallery', 'ArtisticVibes'],
      'Park': ['Parks', 'GreenSpaces', 'OutdoorLife', 'Nature'],
    };

    final hashtags = [...baseHashtags];

    if (categoryHashtags.containsKey(discovery.category)) {
      hashtags.addAll(categoryHashtags[discovery.category]!);
    }

    // Add location-based hashtag
    final locationTag = discovery.location
        .split(',')
        .first
        .replaceAll(' ', '')
        .replaceAll(RegExp(r'[^\w]'), '');
    hashtags.add('Visit$locationTag');

    return hashtags;
  }

  /// Check if content is ready to publish
  bool get canPublish {
    if (contentType == SocialContentType.video ||
        contentType == SocialContentType.reel) {
      return videoPath != null && targetPlatforms.isNotEmpty;
    }
    return imagePath != null && targetPlatforms.isNotEmpty;
  }

  /// Get engagement rate
  double get engagementRate {
    if (views == 0) return 0;
    return ((likes + shares) / views * 100);
  }
}

/// Model for connected social accounts
class ConnectedSocialAccount {
  final SocialPlatform platform;
  final String accountId;
  final String username;
  final String? profilePictureUrl;
  final bool isConnected;
  final DateTime? connectedAt;
  final int followersCount;
  final bool canPostReels;
  final bool canPostStories;

  ConnectedSocialAccount({
    required this.platform,
    required this.accountId,
    required this.username,
    this.profilePictureUrl,
    required this.isConnected,
    this.connectedAt,
    this.followersCount = 0,
    this.canPostReels = false,
    this.canPostStories = false,
  });
}

/// Social sharing stats for users
class SocialStats {
  final int totalPostsCreated;
  final int totalPostsPublished;
  final int totalViews;
  final int totalLikes;
  final int totalShares;
  final int totalFollowersGained;
  final String mostPopularPlatform;
  final Discovery? mostSharedDiscovery;

  SocialStats({
    required this.totalPostsCreated,
    required this.totalPostsPublished,
    required this.totalViews,
    required this.totalLikes,
    required this.totalShares,
    required this.totalFollowersGained,
    required this.mostPopularPlatform,
    this.mostSharedDiscovery,
  });

  double get averageEngagement {
    if (totalViews == 0) return 0;
    return ((totalLikes + totalShares) / totalViews * 100);
  }
}

/// Mock data for social accounts
List<ConnectedSocialAccount> getMockSocialAccounts() {
  return [
    ConnectedSocialAccount(
      platform: SocialPlatform.instagram,
      accountId: 'ig_123',
      username: '@explorador_123',
      isConnected: true,
      connectedAt: DateTime.now().subtract(const Duration(days: 30)),
      followersCount: 2450,
      canPostReels: true,
      canPostStories: true,
    ),
    ConnectedSocialAccount(
      platform: SocialPlatform.tiktok,
      accountId: 'tt_456',
      username: '@viajero_cool',
      isConnected: true,
      connectedAt: DateTime.now().subtract(const Duration(days: 15)),
      followersCount: 8920,
      canPostReels: true,
      canPostStories: false,
    ),
    ConnectedSocialAccount(
      platform: SocialPlatform.facebook,
      accountId: 'fb_789',
      username: 'Juan Pérez',
      isConnected: false,
      followersCount: 0,
      canPostReels: false,
      canPostStories: false,
    ),
    ConnectedSocialAccount(
      platform: SocialPlatform.twitter,
      accountId: 'tw_101',
      username: '@explorer_mx',
      isConnected: false,
      followersCount: 0,
      canPostReels: false,
      canPostStories: false,
    ),
  ];
}
