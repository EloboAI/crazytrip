/// Model representing a discovery/point of interest
class Discovery {
  final String id;
  final String name;
  final String category;
  final String description;
  final String location;
  final double latitude;
  final double longitude;
  final int xpReward;
  final String imageUrl;
  final DateTime discoveredAt;
  final bool isUnlocked;

  Discovery({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.xpReward,
    required this.imageUrl,
    required this.discoveredAt,
    this.isUnlocked = false,
  });

  // Mock data generator
  static List<Discovery> getMockDiscoveries() {
    return [
      Discovery(
        id: '1',
        name: 'Golden Gate Park',
        category: 'Park',
        description: 'A beautiful urban park with stunning views and diverse wildlife.',
        location: 'San Francisco, CA',
        latitude: 37.7694,
        longitude: -122.4862,
        xpReward: 150,
        imageUrl: '🌳',
        discoveredAt: DateTime.now().subtract(const Duration(days: 2)),
        isUnlocked: true,
      ),
      Discovery(
        id: '2',
        name: 'Historic Clock Tower',
        category: 'Historical',
        description: 'A 19th-century clock tower that has become a city landmark.',
        location: 'Downtown',
        latitude: 37.7749,
        longitude: -122.4194,
        xpReward: 200,
        imageUrl: '🏛️',
        discoveredAt: DateTime.now().subtract(const Duration(days: 5)),
        isUnlocked: true,
      ),
      Discovery(
        id: '3',
        name: 'Sunset Beach',
        category: 'Nature',
        description: 'Watch the most amazing sunsets from this pristine beach.',
        location: 'Coastal Highway',
        latitude: 37.7594,
        longitude: -122.5107,
        xpReward: 180,
        imageUrl: '🏖️',
        discoveredAt: DateTime.now().subtract(const Duration(hours: 12)),
        isUnlocked: true,
      ),
      Discovery(
        id: '4',
        name: 'Art District Mural',
        category: 'Art',
        description: 'A massive street art mural by renowned local artists.',
        location: 'Art District',
        latitude: 37.7699,
        longitude: -122.4340,
        xpReward: 120,
        imageUrl: '🎨',
        discoveredAt: DateTime.now().subtract(const Duration(days: 1)),
        isUnlocked: true,
      ),
      Discovery(
        id: '5',
        name: 'Ancient Redwood Tree',
        category: 'Nature',
        description: 'A 500-year-old redwood tree standing tall in the forest.',
        location: 'Muir Woods',
        latitude: 37.8969,
        longitude: -122.5808,
        xpReward: 250,
        imageUrl: '🌲',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
      ),
      Discovery(
        id: '6',
        name: 'Coffee Culture Cafe',
        category: 'Food & Drink',
        description: 'Award-winning artisanal coffee roasted in-house.',
        location: 'Mission District',
        latitude: 37.7599,
        longitude: -122.4148,
        xpReward: 100,
        imageUrl: '☕',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
      ),
      Discovery(
        id: '7',
        name: 'Victorian Mansion',
        category: 'Historical',
        description: 'An impeccably preserved Victorian-era mansion from 1890.',
        location: 'Pacific Heights',
        latitude: 37.7956,
        longitude: -122.4350,
        xpReward: 220,
        imageUrl: '🏰',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
      ),
      Discovery(
        id: '8',
        name: 'Tech Innovation Hub',
        category: 'Modern',
        description: 'A futuristic building housing cutting-edge startups.',
        location: 'SOMA',
        latitude: 37.7833,
        longitude: -122.4167,
        xpReward: 150,
        imageUrl: '🏢',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
      ),
    ];
  }
}
