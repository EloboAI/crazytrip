/// Categories of things that can be discovered and collected in CrazyDex
enum CrazyDexCategory {
  mountains, // Peaks, mountains, volcanoes
  buildings, // Historic buildings, monuments, architecture
  waterBodies, // Lakes, rivers, waterfalls, beaches
  flora, // Plants, trees, flowers
  fauna, // Animals, birds, insects
  landmarks, // Points of interest, statues
  food, // Typical dishes, ingredients, street food
  art, // Murals, sculptures, street art
  culture, // Crafts, traditional clothing, customs
  transportation, // Historic vehicles, cable cars
}

extension CrazyDexCategoryExtension on CrazyDexCategory {
  String get displayName {
    switch (this) {
      case CrazyDexCategory.mountains:
        return 'Montañas';
      case CrazyDexCategory.buildings:
        return 'Edificios';
      case CrazyDexCategory.waterBodies:
        return 'Cuerpos de Agua';
      case CrazyDexCategory.flora:
        return 'Flora';
      case CrazyDexCategory.fauna:
        return 'Fauna';
      case CrazyDexCategory.landmarks:
        return 'Monumentos';
      case CrazyDexCategory.food:
        return 'Gastronomía';
      case CrazyDexCategory.art:
        return 'Arte';
      case CrazyDexCategory.culture:
        return 'Cultura';
      case CrazyDexCategory.transportation:
        return 'Transporte';
    }
  }

  String get icon {
    switch (this) {
      case CrazyDexCategory.mountains:
        return '🏔️';
      case CrazyDexCategory.buildings:
        return '🏛️';
      case CrazyDexCategory.waterBodies:
        return '💧';
      case CrazyDexCategory.flora:
        return '🌿';
      case CrazyDexCategory.fauna:
        return '🦜';
      case CrazyDexCategory.landmarks:
        return '🗿';
      case CrazyDexCategory.food:
        return '🍽️';
      case CrazyDexCategory.art:
        return '🎨';
      case CrazyDexCategory.culture:
        return '🎭';
      case CrazyDexCategory.transportation:
        return '🚡';
    }
  }
}

/// Individual item in the CrazyDex
class CrazyDexItem {
  final String id;
  final String name;
  final CrazyDexCategory category;
  final String description;
  final String? scientificName; // For flora/fauna
  final String funFact;
  final String imageUrl; // Emoji for now, later real images
  final int rarity; // 1-5 stars
  final int xpReward;
  final List<String>
  aiLabels; // Labels for AI identification (e.g., ["bird", "toucan", "tropical"])
  final DateTime? discoveredAt;
  final String? discoveryId; // ID of the Discovery where this was found
  final bool isDiscovered;
  final int timesSpotted;
  final List<String> userPhotos; // User's photos of this item
  final List<String> tags; // Additional search tags

  // Geographic coordinates
  final double latitude;
  final double longitude;

  CrazyDexItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    this.scientificName,
    required this.funFact,
    required this.imageUrl,
    required this.rarity,
    required this.xpReward,
    required this.aiLabels,
    this.discoveredAt,
    this.discoveryId,
    this.isDiscovered = false,
    this.timesSpotted = 0,
    this.userPhotos = const [],
    this.tags = const [],
    double? latitude,
    double? longitude,
  }) : latitude = latitude ?? 10.2099277,
       longitude = longitude ?? -84.0147707;

  /// Get rarity display name
  String get rarityName {
    switch (rarity) {
      case 1:
        return 'Común';
      case 2:
        return 'Poco Común';
      case 3:
        return 'Raro';
      case 4:
        return 'Épico';
      case 5:
        return 'Legendario';
      default:
        return 'Común';
    }
  }

  /// Get rarity stars
  String get rarityStars {
    return '⭐' * rarity;
  }

  /// Copy with method for updating
  CrazyDexItem copyWith({
    bool? isDiscovered,
    DateTime? discoveredAt,
    String? discoveryId,
    int? timesSpotted,
    List<String>? userPhotos,
  }) {
    return CrazyDexItem(
      id: id,
      name: name,
      category: category,
      description: description,
      scientificName: scientificName,
      funFact: funFact,
      imageUrl: imageUrl,
      rarity: rarity,
      xpReward: xpReward,
      aiLabels: aiLabels,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      discoveryId: discoveryId ?? this.discoveryId,
      isDiscovered: isDiscovered ?? this.isDiscovered,
      timesSpotted: timesSpotted ?? this.timesSpotted,
      userPhotos: userPhotos ?? this.userPhotos,
      tags: tags,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// User's CrazyDex progress
class CrazyDexProgress {
  final int totalItems;
  final int discoveredItems;
  final Map<CrazyDexCategory, int> categoryProgress;
  final Map<CrazyDexCategory, int> categoryTotals;
  final String rank;

  CrazyDexProgress({
    required this.totalItems,
    required this.discoveredItems,
    required this.categoryProgress,
    required this.categoryTotals,
    required this.rank,
  });

  /// Calculate completion percentage
  int get completionPercentage {
    if (totalItems == 0) return 0;
    return ((discoveredItems / totalItems) * 100).round();
  }

  /// Get category completion percentage
  int getCategoryPercentage(CrazyDexCategory category) {
    final discovered = categoryProgress[category] ?? 0;
    final total = categoryTotals[category] ?? 1;
    return ((discovered / total) * 100).round();
  }

  /// Get rank based on discoveries
  static String getRankForDiscoveries(int discoveries) {
    if (discoveries < 10) return 'Novato';
    if (discoveries < 50) return 'Explorador';
    if (discoveries < 150) return 'Aventurero';
    if (discoveries < 300) return 'Maestro';
    if (discoveries < 500) return 'Leyenda';
    return 'Gran Maestro';
  }
}

/// Get CrazyDex items available at a specific Discovery location
/// These are items that other users have found at this location
List<CrazyDexItem> getCrazyDexItemsForDiscovery(String discoveryId) {
  final allItems = getMockCrazyDexItems();
  // Filter items that belong to this discovery
  return allItems
      .where((item) => item.tags.contains('discovery_$discoveryId'))
      .toList();
}

/// Mock data generator for CrazyDex items
/// In production, these would be loaded from backend based on discovery location
List<CrazyDexItem> getMockCrazyDexItems() {
  return [
    // FAUNA - Birds
    CrazyDexItem(
      id: 'fauna_001',
      name: 'Quetzal',
      category: CrazyDexCategory.fauna,
      description:
          'Ave sagrada de los mayas, conocida por sus hermosas plumas verdes iridiscentes.',
      scientificName: 'Pharomachrus mocinno',
      funFact:
          'Las plumas del quetzal eran más valiosas que el oro para los mayas.',
      imageUrl: '🦜',
      rarity: 5,
      xpReward: 1000,
      aiLabels: ['bird', 'quetzal', 'green bird', 'tropical bird'],
      tags: [
        'ave',
        'bird',
        'green',
        'maya',
        'sacred',
        'discovery_d1',
        'discovery_d3',
      ],
      isDiscovered: true,
      discoveredAt: DateTime.now().subtract(const Duration(days: 5)),
      discoveryId: 'd1',
      timesSpotted: 2,
    ),
    CrazyDexItem(
      id: 'fauna_002',
      name: 'Tucán',
      category: CrazyDexCategory.fauna,
      description: 'Ave tropical con un pico grande y colorido.',
      scientificName: 'Ramphastos sulfuratus',
      funFact: 'Su pico está hueco y es muy ligero, hecho de queratina.',
      imageUrl: '🦜',
      rarity: 3,
      xpReward: 200,
      aiLabels: ['bird', 'toucan', 'colorful bird', 'big beak'],
      tags: [
        'ave',
        'bird',
        'tropical',
        'colorful',
        'discovery_d1',
        'discovery_d2',
      ],
      isDiscovered: true,
      discoveredAt: DateTime.now().subtract(const Duration(days: 3)),
      discoveryId: 'd1',
      timesSpotted: 1,
    ),
    CrazyDexItem(
      id: 'fauna_003',
      name: 'Colibrí',
      category: CrazyDexCategory.fauna,
      description: 'Ave pequeña capaz de volar hacia atrás.',
      scientificName: 'Trochilidae',
      funFact: 'Puede batir sus alas hasta 80 veces por segundo.',
      imageUrl: '🐦',
      rarity: 2,
      xpReward: 100,
      aiLabels: ['bird', 'hummingbird', 'small bird', 'flying bird'],
      tags: [
        'ave',
        'bird',
        'small',
        'fast',
        'discovery_d1',
        'discovery_d2',
        'discovery_d3',
      ],
      isDiscovered: false,
      latitude: 10.2085,
      longitude: -84.0155,
    ),
    CrazyDexItem(
      id: 'fauna_004',
      name: 'Águila Arpía',
      category: CrazyDexCategory.fauna,
      description: 'Una de las aves rapaces más grandes del mundo.',
      scientificName: 'Harpia harpyja',
      funFact: 'Sus garras son tan grandes como las de un oso grizzly.',
      imageUrl: '🦅',
      rarity: 5,
      xpReward: 1000,
      aiLabels: ['bird', 'eagle', 'harpy eagle', 'raptor', 'large bird'],
      tags: ['ave', 'bird', 'raptor', 'predator', 'discovery_d3'],
      isDiscovered: false,
      latitude: 10.2125,
      longitude: -84.0110,
    ),

    // FAUNA - Animals
    CrazyDexItem(
      id: 'fauna_005',
      name: 'Perezoso',
      category: CrazyDexCategory.fauna,
      description: 'Mamífero arbóreo conocido por su lentitud.',
      scientificName: 'Bradypus',
      funFact: 'Duermen hasta 20 horas al día y se mueven muy lentamente.',
      imageUrl: '🦥',
      rarity: 3,
      xpReward: 150,
      aiLabels: ['sloth', 'animal', 'tree animal', 'slow animal'],
      tags: ['mammal', 'slow', 'tree', 'lazy', 'discovery_d2'],
      isDiscovered: true,
      discoveredAt: DateTime.now().subtract(const Duration(days: 1)),
      discoveryId: 'd2',
      timesSpotted: 1,
    ),
    CrazyDexItem(
      id: 'fauna_006',
      name: 'Mono Aullador',
      category: CrazyDexCategory.fauna,
      description: 'Primate conocido por sus fuertes vocalizaciones.',
      scientificName: 'Alouatta',
      funFact: 'Su aullido puede escucharse hasta 5 km de distancia.',
      imageUrl: '🐒',
      rarity: 2,
      xpReward: 100,
      aiLabels: ['monkey', 'primate', 'howler monkey', 'animal'],
      tags: ['monkey', 'primate', 'loud', 'howler', 'discovery_d2'],
      isDiscovered: false,
      latitude: 10.2075,
      longitude: -84.0180,
    ),
    CrazyDexItem(
      id: 'fauna_007',
      name: 'Rana Venenosa',
      category: CrazyDexCategory.fauna,
      description: 'Anfibio de colores brillantes y piel tóxica.',
      scientificName: 'Dendrobatidae',
      funFact: 'Los indígenas usaban su veneno para las puntas de sus flechas.',
      imageUrl: '🐸',
      rarity: 4,
      xpReward: 400,
      aiLabels: ['frog', 'poison dart frog', 'colorful frog', 'amphibian'],
      tags: [
        'frog',
        'poison',
        'colorful',
        'toxic',
        'discovery_d2',
        'discovery_d3',
      ],
      isDiscovered: false,
      latitude: 10.2115,
      longitude: -84.0125,
    ),

    // FLORA
    CrazyDexItem(
      id: 'flora_001',
      name: 'Orquídea Morada',
      category: CrazyDexCategory.flora,
      description: 'Flor nacional de Costa Rica, delicada y hermosa.',
      scientificName: 'Guarianthe skinneri',
      funFact: 'Existen más de 1,400 especies de orquídeas en Costa Rica.',
      imageUrl: '🌺',
      rarity: 3,
      xpReward: 150,
      aiLabels: ['flower', 'orchid', 'purple flower', 'plant'],
      tags: [
        'flower',
        'orchid',
        'purple',
        'national',
        'discovery_d3',
        'discovery_d4',
      ],
      isDiscovered: true,
      discoveredAt: DateTime.now().subtract(const Duration(days: 2)),
      discoveryId: 'd3',
      timesSpotted: 1,
    ),
    CrazyDexItem(
      id: 'flora_002',
      name: 'Ceiba',
      category: CrazyDexCategory.flora,
      description: 'Árbol sagrado maya, puede alcanzar 70 metros de altura.',
      scientificName: 'Ceiba pentandra',
      funFact: 'Los mayas creían que conectaba el inframundo con el cielo.',
      imageUrl: '🌳',
      rarity: 4,
      xpReward: 500,
      aiLabels: ['tree', 'ceiba', 'large tree', 'plant'],
      tags: ['tree', 'sacred', 'maya', 'tall', 'discovery_d3'],
      isDiscovered: false,
      latitude: 10.2065,
      longitude: -84.0165,
    ),
    CrazyDexItem(
      id: 'flora_003',
      name: 'Heliconia',
      category: CrazyDexCategory.flora,
      description: 'Planta tropical de flores rojas y amarillas vibrantes.',
      scientificName: 'Heliconia',
      funFact: 'Sus flores son polinizadas principalmente por colibríes.',
      imageUrl: '🌺',
      rarity: 2,
      xpReward: 80,
      aiLabels: ['flower', 'heliconia', 'tropical flower', 'plant'],
      tags: [
        'flower',
        'tropical',
        'red',
        'yellow',
        'discovery_d1',
        'discovery_d4',
      ],
      isDiscovered: false,
      latitude: 10.2140,
      longitude: -84.0100,
    ),

    // MOUNTAINS
    CrazyDexItem(
      id: 'mountain_001',
      name: 'Volcán Arenal',
      category: CrazyDexCategory.mountains,
      description: 'Volcán activo icónico de Costa Rica.',
      funFact: 'Estuvo dormido por 400 años hasta su erupción en 1968.',
      imageUrl: '🌋',
      rarity: 4,
      xpReward: 500,
      aiLabels: ['volcano', 'mountain', 'arenal', 'cone shaped mountain'],
      tags: ['volcano', 'active', 'iconic', 'arenal', 'discovery_d7'],
      isDiscovered: false,
    ),
    CrazyDexItem(
      id: 'mountain_002',
      name: 'Cerro Chirripó',
      category: CrazyDexCategory.mountains,
      description: 'Pico más alto de Costa Rica con 3,820 metros.',
      funFact: 'En días claros, se pueden ver ambos océanos desde la cima.',
      imageUrl: '🏔️',
      rarity: 5,
      xpReward: 1000,
      aiLabels: ['mountain', 'peak', 'chirripo', 'high mountain'],
      tags: ['peak', 'highest', 'mountain', 'chirripo', 'discovery_d8'],
      isDiscovered: false,
    ),

    // WATER BODIES
    CrazyDexItem(
      id: 'water_001',
      name: 'Catarata La Fortuna',
      category: CrazyDexCategory.waterBodies,
      description: 'Cascada de 70 metros cerca del Volcán Arenal.',
      funFact: 'Se requieren 530 escalones para llegar a la base.',
      imageUrl: '💦',
      rarity: 3,
      xpReward: 200,
      aiLabels: ['waterfall', 'cascade', 'water', 'nature'],
      tags: ['waterfall', 'cascade', 'fortuna', 'arenal', 'discovery_d7'],
      isDiscovered: false,
    ),
    CrazyDexItem(
      id: 'water_002',
      name: 'Río Celeste',
      category: CrazyDexCategory.waterBodies,
      description: 'Río de color azul turquesa único en el mundo.',
      funFact:
          'Su color se debe a una reacción química entre minerales volcánicos.',
      imageUrl: '💧',
      rarity: 5,
      xpReward: 800,
      aiLabels: ['river', 'blue water', 'turquoise water', 'water'],
      tags: ['river', 'blue', 'turquoise', 'unique', 'discovery_d9'],
      isDiscovered: false,
    ),

    // BUILDINGS
    CrazyDexItem(
      id: 'building_001',
      name: 'Teatro Nacional',
      category: CrazyDexCategory.buildings,
      description: 'Edificio histórico neoclásico de San José.',
      funFact: 'Fue construido con un impuesto al café en 1897.',
      imageUrl: '🏛️',
      rarity: 4,
      xpReward: 300,
      aiLabels: [
        'building',
        'theater',
        'neoclassical building',
        'architecture',
      ],
      tags: ['theater', 'historic', 'neoclassical', 'sanjose', 'discovery_d10'],
      isDiscovered: false,
    ),

    // FOOD
    CrazyDexItem(
      id: 'food_001',
      name: 'Gallo Pinto',
      category: CrazyDexCategory.food,
      description: 'Platillo tradicional de arroz y frijoles.',
      funFact: 'Es el desayuno más típico de Costa Rica y Nicaragua.',
      imageUrl: '🍚',
      rarity: 1,
      xpReward: 50,
      aiLabels: ['food', 'rice', 'beans', 'plate', 'gallo pinto'],
      tags: [
        'rice',
        'beans',
        'breakfast',
        'traditional',
        'discovery_d5',
        'discovery_d6',
      ],
      isDiscovered: true,
      discoveredAt: DateTime.now(),
      discoveryId: 'd5',
      timesSpotted: 3,
    ),
    CrazyDexItem(
      id: 'food_002',
      name: 'Casado',
      category: CrazyDexCategory.food,
      description: 'Plato completo con arroz, frijoles, carne y ensalada.',
      funFact: 'Su nombre viene de "comida de casado" (married man\'s meal).',
      imageUrl: '🍽️',
      rarity: 1,
      xpReward: 50,
      aiLabels: ['food', 'plate', 'rice', 'meat', 'salad', 'casado'],
      tags: [
        'plate',
        'complete',
        'lunch',
        'traditional',
        'discovery_d5',
        'discovery_d6',
      ],
      isDiscovered: true,
      discoveredAt: DateTime.now().subtract(const Duration(hours: 3)),
      discoveryId: 'd5',
      timesSpotted: 2,
    ),

    // ART
    CrazyDexItem(
      id: 'art_001',
      name: 'Carreta Típica',
      category: CrazyDexCategory.art,
      description: 'Carreta de madera pintada con diseños coloridos.',
      funFact: 'Patrimonio de la Humanidad por la UNESCO desde 2005.',
      imageUrl: '🎨',
      rarity: 3,
      xpReward: 200,
      aiLabels: ['cart', 'oxcart', 'painted cart', 'traditional art'],
      tags: ['cart', 'traditional', 'colorful', 'unesco', 'discovery_d6'],
      isDiscovered: false,
    ),

    // CULTURE
    CrazyDexItem(
      id: 'culture_001',
      name: 'Máscara de Boruca',
      category: CrazyDexCategory.culture,
      description: 'Máscara artesanal tallada en madera de balsa.',
      funFact: 'Se usa en el baile tradicional de los Diablitos.',
      imageUrl: '🎭',
      rarity: 4,
      xpReward: 350,
      aiLabels: ['mask', 'wooden mask', 'carved mask', 'indigenous art'],
      tags: ['mask', 'indigenous', 'boruca', 'traditional', 'discovery_d6'],
      isDiscovered: false,
    ),
  ];
}

/// Calculate user's CrazyDex progress
CrazyDexProgress calculateProgress(List<CrazyDexItem> items) {
  final total = items.length;
  final discovered = items.where((item) => item.isDiscovered).length;

  final categoryProgress = <CrazyDexCategory, int>{};
  final categoryTotals = <CrazyDexCategory, int>{};

  for (var category in CrazyDexCategory.values) {
    final categoryItems = items.where((item) => item.category == category);
    categoryTotals[category] = categoryItems.length;
    categoryProgress[category] =
        categoryItems.where((item) => item.isDiscovered).length;
  }

  return CrazyDexProgress(
    totalItems: total,
    discoveredItems: discovered,
    categoryProgress: categoryProgress,
    categoryTotals: categoryTotals,
    rank: CrazyDexProgress.getRankForDiscoveries(discovered),
  );
}
