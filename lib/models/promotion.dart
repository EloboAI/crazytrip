/// Model representing a tourist location promotion or contest
class Promotion {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final DateTime startDate;
  final DateTime endDate;
  final String prize;
  final int participantCount;
  final List<String> requirements;
  final String imageUrl; // Emoji for now
  final PromotionType type;
  final int xpReward;
  final String? linkedAchievementId; // Links to achievement system

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.prize,
    required this.participantCount,
    required this.requirements,
    required this.imageUrl,
    required this.type,
    required this.xpReward,
    this.linkedAchievementId,
  });

  /// Check if promotion is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if promotion is upcoming
  bool get isUpcoming {
    return DateTime.now().isBefore(startDate);
  }

  /// Check if promotion has expired
  bool get isExpired {
    return DateTime.now().isAfter(endDate);
  }

  /// Get days remaining (negative if expired, positive if upcoming/active)
  int get daysRemaining {
    if (isExpired) {
      return 0;
    }
    return endDate.difference(DateTime.now()).inDays;
  }

  /// Get hours remaining
  int get hoursRemaining {
    if (isExpired) {
      return 0;
    }
    return endDate.difference(DateTime.now()).inHours;
  }

  /// Get status text
  String get statusText {
    if (isUpcoming) {
      return 'Próximamente';
    } else if (isActive) {
      if (daysRemaining > 0) {
        return 'Quedan $daysRemaining días';
      } else {
        return 'Quedan $hoursRemaining horas';
      }
    } else {
      return 'Finalizada';
    }
  }
}

/// Types of promotions available
enum PromotionType {
  contest, // Competition with winners
  discount, // Special discount offer
  event, // Special event at location
  challenge, // Time-limited challenge
}

/// Extension to get promotion type display names
extension PromotionTypeExtension on PromotionType {
  String get displayName {
    switch (this) {
      case PromotionType.contest:
        return 'Concurso';
      case PromotionType.discount:
        return 'Descuento';
      case PromotionType.event:
        return 'Evento';
      case PromotionType.challenge:
        return 'Desafío';
    }
  }

  String get emoji {
    switch (this) {
      case PromotionType.contest:
        return '🏆';
      case PromotionType.discount:
        return '💰';
      case PromotionType.event:
        return '🎉';
      case PromotionType.challenge:
        return '⚡';
    }
  }
}

/// Mock data for promotions
List<Promotion> getMockPromotions() {
  final now = DateTime.now();

  return [
    // Active Promotions
    Promotion(
      id: 'promo_1',
      title: 'Desafío Explorador de Noviembre',
      description:
          'Visita 10 lugares históricos este mes y gana una camiseta exclusiva de Crazy Trip más 500 XP de bonificación.',
      location: 'Cualquier lugar histórico',
      category: 'Historical',
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month, 30),
      prize: 'Camiseta exclusiva + 500 XP',
      participantCount: 342,
      requirements: [
        'Visitar 10 lugares históricos',
        'Escanear con AR cada ubicación',
        'Completar antes del 30 de noviembre',
      ],
      imageUrl: '🏛️',
      type: PromotionType.challenge,
      xpReward: 500,
      linkedAchievementId: 'ach_4', // History Buff achievement
    ),
    Promotion(
      id: 'promo_2',
      title: 'Fin de Semana de XP Doble',
      description:
          'Este fin de semana, todos los escaneos de lugares naturales otorgan el doble de XP. ¡Aprovecha para subir de nivel!',
      location: 'Lugares de naturaleza',
      category: 'Nature',
      startDate: now.subtract(const Duration(days: 1)),
      endDate: now.add(const Duration(days: 2)),
      prize: 'XP Doble en todos los escaneos',
      participantCount: 1248,
      requirements: [
        'Escanear lugares de categoría Naturaleza',
        'Solo válido sábado y domingo',
        'Sin límite de escaneos',
      ],
      imageUrl: '🌲',
      type: PromotionType.event,
      xpReward: 0, // Variable based on discoveries
      linkedAchievementId: 'ach_3', // Nature Lover achievement
    ),
    Promotion(
      id: 'promo_3',
      title: 'Concurso Fotográfico de Arte',
      description:
          'Captura la mejor foto en un lugar artístico y gana un premio de 1000 XP más un vale de 50€ para la tienda de arte local.',
      location: 'Museos y galerías',
      category: 'Art',
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 10)),
      prize: '1000 XP + Vale de 50€',
      participantCount: 87,
      requirements: [
        'Visitar un lugar de arte',
        'Tomar una foto creativa',
        'Compartir con #CrazyTripArt',
        'El jurado seleccionará al ganador',
      ],
      imageUrl: '🎨',
      type: PromotionType.contest,
      xpReward: 1000,
      linkedAchievementId: null,
    ),
    Promotion(
      id: 'promo_4',
      title: 'Descuento en Café Local',
      description:
          'Visita "Café Central" y muestra tu nivel 10+ de Crazy Trip para obtener un 20% de descuento en tu pedido.',
      location: 'Café Central, Centro Ciudad',
      category: 'Food',
      startDate: now.subtract(const Duration(days: 7)),
      endDate: now.add(const Duration(days: 23)),
      prize: '20% de descuento',
      participantCount: 456,
      requirements: [
        'Nivel 10 o superior',
        'Mostrar perfil de Crazy Trip',
        'Válido una vez por semana',
        'No acumulable con otras ofertas',
      ],
      imageUrl: '☕',
      type: PromotionType.discount,
      xpReward: 0,
      linkedAchievementId: null,
    ),

    // Upcoming Promotions
    Promotion(
      id: 'promo_5',
      title: 'Maratón de Descubrimientos Diciembre',
      description:
          'El primer usuario en descubrir 50 nuevos lugares en diciembre ganará un viaje para dos personas a un destino turístico.',
      location: 'Todos los lugares',
      category: 'Park',
      startDate: DateTime(now.year, now.month + 1, 1),
      endDate: DateTime(now.year, now.month + 1, 31),
      prize: 'Viaje para 2 personas',
      participantCount: 0,
      requirements: [
        'Descubrir 50 lugares nuevos',
        'Solo lugares no visitados previamente',
        'Primer usuario en completar gana',
        'Válido todo diciembre',
      ],
      imageUrl: '✈️',
      type: PromotionType.contest,
      xpReward: 2000,
      linkedAchievementId: 'ach_8', // Globe Trotter achievement
    ),
    Promotion(
      id: 'promo_6',
      title: 'Evento de Lanzamiento Winter',
      description:
          'Celebra la temporada con eventos especiales en parques. Completa el tour de 5 parques y desbloquea una insignia exclusiva.',
      location: 'Parques seleccionados',
      category: 'Park',
      startDate: DateTime(now.year, 12, 15),
      endDate: DateTime(now.year, 12, 25),
      prize: 'Insignia Winter Explorer',
      participantCount: 0,
      requirements: [
        'Visitar 5 parques específicos',
        'Escanear el código QR especial',
        'Completar entre el 15-25 dic',
        'Recibir insignia exclusiva',
      ],
      imageUrl: '❄️',
      type: PromotionType.event,
      xpReward: 300,
      linkedAchievementId: null,
    ),

    // Expired Promotions
    Promotion(
      id: 'promo_7',
      title: 'Desafío Halloween Spooky',
      description:
          'Visitaste lugares históricos "embrujados" durante Halloween y ganaste puntos bonus. Este evento ha finalizado.',
      location: 'Lugares históricos',
      category: 'Historical',
      startDate: DateTime(now.year, 10, 25),
      endDate: DateTime(now.year, 10, 31),
      prize: '400 XP + Insignia Halloween',
      participantCount: 723,
      requirements: [
        'Visitar 5 lugares históricos',
        'Durante la semana de Halloween',
        'Escanear de noche (después de 6pm)',
      ],
      imageUrl: '🎃',
      type: PromotionType.challenge,
      xpReward: 400,
      linkedAchievementId: null,
    ),
    Promotion(
      id: 'promo_8',
      title: 'Semana del Turismo Sostenible',
      description:
          'Evento finalizado: Los usuarios exploraron parques naturales y aprendieron sobre turismo sostenible.',
      location: 'Parques naturales',
      category: 'Nature',
      startDate: DateTime(now.year, 9, 20),
      endDate: DateTime(now.year, 9, 27),
      prize: '200 XP',
      participantCount: 892,
      requirements: [
        'Visitar 3 parques naturales',
        'Leer información educativa',
        'Completar quiz de sostenibilidad',
      ],
      imageUrl: '🌍',
      type: PromotionType.event,
      xpReward: 200,
      linkedAchievementId: 'ach_3',
    ),
  ];
}

/// Filter promotions by status
class PromotionFilters {
  static List<Promotion> getActive(List<Promotion> promotions) {
    return promotions.where((p) => p.isActive).toList();
  }

  static List<Promotion> getUpcoming(List<Promotion> promotions) {
    return promotions.where((p) => p.isUpcoming).toList();
  }

  static List<Promotion> getExpired(List<Promotion> promotions) {
    return promotions.where((p) => p.isExpired).toList();
  }

  static List<Promotion> getByType(
    List<Promotion> promotions,
    PromotionType type,
  ) {
    return promotions.where((p) => p.type == type).toList();
  }

  static List<Promotion> getByCategory(
    List<Promotion> promotions,
    String category,
  ) {
    return promotions.where((p) => p.category == category).toList();
  }
}
