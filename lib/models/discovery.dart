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
  final int crazyDexItemsAvailable; // Total de items CrazyDex en este lugar
  final int crazyDexItemsCollected; // Items que el usuario ya coleccionó aquí

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
    this.crazyDexItemsAvailable = 0,
    this.crazyDexItemsCollected = 0,
  });

  // Mock data generator
  static List<Discovery> getMockDiscoveries() {
    return [
      Discovery(
        id: 'd1',
        name: 'Monteverde Cloud Forest',
        category: 'Nature',
        description:
            'Bosque nuboso con increíble biodiversidad. Hogar de quetzales, tucanes y colibríes.',
        location: 'Monteverde, Costa Rica',
        latitude: 10.3000,
        longitude: -84.8000,
        xpReward: 500,
        imageUrl: '🌳',
        discoveredAt: DateTime.now().subtract(const Duration(days: 5)),
        isUnlocked: true,
        crazyDexItemsAvailable: 4, // Quetzal, Tucán, Colibrí, Heliconia
        crazyDexItemsCollected: 2, // Quetzal y Tucán ya descubiertos
      ),
      Discovery(
        id: 'd2',
        name: 'Manuel Antonio National Park',
        category: 'Nature',
        description:
            'Parque nacional con playas, selva tropical y vida silvestre abundante.',
        location: 'Manuel Antonio, Costa Rica',
        latitude: 9.3902,
        longitude: -84.1347,
        xpReward: 400,
        imageUrl: '🏖️',
        discoveredAt: DateTime.now().subtract(const Duration(days: 3)),
        isUnlocked: true,
        crazyDexItemsAvailable: 4, // Perezoso, Colibrí, Mono, Rana
        crazyDexItemsCollected: 1, // Solo Perezoso
      ),
      Discovery(
        id: 'd3',
        name: 'Lankester Botanical Garden',
        category: 'Nature',
        description: 'Jardín botánico especializado en orquídeas y bromelias.',
        location: 'Cartago, Costa Rica',
        latitude: 9.8354,
        longitude: -83.8904,
        xpReward: 300,
        imageUrl: '🌺',
        discoveredAt: DateTime.now().subtract(const Duration(days: 2)),
        isUnlocked: true,
        crazyDexItemsAvailable: 5, // Orquídea, Colibrí, Águila, Ceiba, Rana
        crazyDexItemsCollected: 1, // Orquídea
      ),
      Discovery(
        id: 'd4',
        name: 'Wilson Botanical Garden',
        category: 'Nature',
        description: 'Jardín con más de 2,000 especies de plantas tropicales.',
        location: 'San Vito, Costa Rica',
        latitude: 8.7944,
        longitude: -82.9686,
        xpReward: 300,
        imageUrl: '🌿',
        discoveredAt: DateTime.now().subtract(const Duration(days: 1)),
        isUnlocked: true,
        crazyDexItemsAvailable: 2, // Orquídea, Heliconia
        crazyDexItemsCollected: 0,
      ),
      Discovery(
        id: 'd5',
        name: 'Soda La Casona',
        category: 'Food & Drink',
        description:
            'Restaurante típico costarricense con los mejores platos tradicionales.',
        location: 'San José, Costa Rica',
        latitude: 9.9281,
        longitude: -84.0907,
        xpReward: 150,
        imageUrl: '🍽️',
        discoveredAt: DateTime.now(),
        isUnlocked: true,
        crazyDexItemsAvailable: 2, // Gallo Pinto, Casado
        crazyDexItemsCollected: 2, // Ambos descubiertos
      ),
      Discovery(
        id: 'd6',
        name: 'Mercado de Artesanías',
        category: 'Art & Culture',
        description:
            'Mercado tradicional con artesanías costarricenses auténticas.',
        location: 'Sarchí, Costa Rica',
        latitude: 10.0833,
        longitude: -84.3333,
        xpReward: 200,
        imageUrl: '🎨',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
        crazyDexItemsAvailable: 3, // Carreta, Máscara, Gallo Pinto
        crazyDexItemsCollected: 0,
      ),
      Discovery(
        id: 'd7',
        name: 'Arenal Volcano Area',
        category: 'Nature',
        description:
            'Zona del majestuoso Volcán Arenal con catarata La Fortuna.',
        location: 'La Fortuna, Costa Rica',
        latitude: 10.4628,
        longitude: -84.7032,
        xpReward: 600,
        imageUrl: '🌋',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
        crazyDexItemsAvailable: 2, // Volcán Arenal, Catarata La Fortuna
        crazyDexItemsCollected: 0,
      ),
      Discovery(
        id: 'd8',
        name: 'Chirripó National Park',
        category: 'Nature',
        description:
            'Hogar del pico más alto de Costa Rica, el Cerro Chirripó.',
        location: 'San Gerardo de Rivas, Costa Rica',
        latitude: 9.4833,
        longitude: -83.4833,
        xpReward: 800,
        imageUrl: '🏔️',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
        crazyDexItemsAvailable: 1, // Cerro Chirripó
        crazyDexItemsCollected: 0,
      ),
      Discovery(
        id: 'd9',
        name: 'Río Celeste in Tenorio National Park',
        category: 'Nature',
        description: 'Río de color turquesa mágico rodeado de selva tropical.',
        location: 'Tenorio, Costa Rica',
        latitude: 10.6667,
        longitude: -85.0000,
        xpReward: 700,
        imageUrl: '💧',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
        crazyDexItemsAvailable: 1, // Río Celeste
        crazyDexItemsCollected: 0,
      ),
      Discovery(
        id: 'd10',
        name: 'Teatro Nacional de Costa Rica',
        category: 'Historical & Culture',
        description:
            'Majestuoso teatro neoclásico, joya arquitectónica de San José.',
        location: 'San José, Costa Rica',
        latitude: 9.9326,
        longitude: -84.0767,
        xpReward: 250,
        imageUrl: '🏛️',
        discoveredAt: DateTime.now(),
        isUnlocked: false,
        crazyDexItemsAvailable: 1, // Teatro Nacional
        crazyDexItemsCollected: 0,
      ),
    ];
  }
}
