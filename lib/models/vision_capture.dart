import 'dart:convert';

/// Representa una captura guardada localmente con metadata completa
///
/// Incluye toda la información de la identificación AI, ubicación,
/// orientación de cámara, timestamp, y ruta a la imagen almacenada.
class VisionCapture {
  /// ID único de la captura en la base de datos
  final int? id;

  /// Resultado de Vision AI serializado como JSON
  /// Incluye: name, type, category, description, rarity, confidence,
  /// specificityLevel, broaderContext, encounterRarity, authenticity
  final Map<String, dynamic> visionResult;

  /// Ruta local a la imagen almacenada
  final String imagePath;

  /// Timestamp de cuando se realizó la captura
  final DateTime timestamp;

  /// Ubicación donde se tomó la foto (JSON con lat, lon)
  /// Formato: {"latitude": double, "longitude": double}
  final Map<String, dynamic>? location;

  /// Información de geocoding (JSON)
  /// Formato: {"fullLocation": String, "placeName": String?, ...}
  final Map<String, dynamic>? locationInfo;

  /// Orientación de la cámara al tomar la foto (JSON)
  /// Formato: {"bearing": double, "pitch": double, "cardinalDirection": String}
  final Map<String, dynamic>? orientation;

  /// Indica si la captura ha sido sincronizada con backend (futuro)
  final bool isSynced;

  VisionCapture({
    this.id,
    required this.visionResult,
    required this.imagePath,
    required this.timestamp,
    this.location,
    this.locationInfo,
    this.orientation,
    this.isSynced = false,
  });

  /// Crea una instancia desde Map (para leer de SQLite)
  factory VisionCapture.fromMap(Map<String, dynamic> map) {
    return VisionCapture(
      id: map['id'] as int?,
      visionResult:
          jsonDecode(map['vision_result'] as String) as Map<String, dynamic>,
      imagePath: map['image_path'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      location:
          map['location'] != null
              ? jsonDecode(map['location'] as String) as Map<String, dynamic>
              : null,
      locationInfo:
          map['location_info'] != null
              ? jsonDecode(map['location_info'] as String)
                  as Map<String, dynamic>
              : null,
      orientation:
          map['orientation'] != null
              ? jsonDecode(map['orientation'] as String) as Map<String, dynamic>
              : null,
      isSynced: (map['is_synced'] as int) == 1,
    );
  }

  /// Convierte a Map (para guardar en SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vision_result': jsonEncode(visionResult),
      'image_path': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'location': location != null ? jsonEncode(location) : null,
      'location_info': locationInfo != null ? jsonEncode(locationInfo) : null,
      'orientation': orientation != null ? jsonEncode(orientation) : null,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  /// Convierte a JSON (para serialización/debugging)
  Map<String, dynamic> toJson() => toMap();

  /// Crea una instancia desde JSON
  factory VisionCapture.fromJson(Map<String, dynamic> json) {
    return VisionCapture(
      id: json['id'] as int?,
      visionResult:
          json['vision_result'] is String
              ? jsonDecode(json['vision_result'] as String)
                  as Map<String, dynamic>
              : json['vision_result'] as Map<String, dynamic>,
      imagePath: json['image_path'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location:
          json['location'] is String
              ? jsonDecode(json['location'] as String) as Map<String, dynamic>
              : json['location'] as Map<String, dynamic>?,
      locationInfo:
          json['location_info'] is String
              ? jsonDecode(json['location_info'] as String)
                  as Map<String, dynamic>
              : json['location_info'] as Map<String, dynamic>?,
      orientation:
          json['orientation'] is String
              ? jsonDecode(json['orientation'] as String)
                  as Map<String, dynamic>
              : json['orientation'] as Map<String, dynamic>?,
      isSynced:
          json['is_synced'] is int
              ? (json['is_synced'] as int) == 1
              : json['is_synced'] as bool,
    );
  }

  /// Obtiene el nombre del lugar desde visionResult
  String get name => visionResult['name'] as String;

  /// Obtiene la categoría desde visionResult
  String get category => visionResult['category'] as String;

  /// Obtiene la rareza desde visionResult
  String get rarity => visionResult['rarity'] as String;

  /// Obtiene la confianza desde visionResult (0.0-1.0)
  double get confidence => (visionResult['confidence'] as num).toDouble();

  /// Obtiene la autenticidad desde visionResult
  String get authenticity =>
      visionResult['authenticity'] as String? ?? 'unknown';

  /// Obtiene encounter_rarity desde visionResult (qué tan difícil es ver esto AQUÍ)
  String get encounterRarity =>
      visionResult['encounter_rarity'] as String? ?? 'easy';

  /// Obtiene la latitud desde location
  double? get latitude => location?['latitude'] as double?;

  /// Obtiene la longitud desde location
  double? get longitude => location?['longitude'] as double?;

  /// Crea una copia con campos modificados
  VisionCapture copyWith({
    int? id,
    Map<String, dynamic>? visionResult,
    String? imagePath,
    DateTime? timestamp,
    Map<String, dynamic>? location,
    Map<String, dynamic>? locationInfo,
    Map<String, dynamic>? orientation,
    bool? isSynced,
  }) {
    return VisionCapture(
      id: id ?? this.id,
      visionResult: visionResult ?? this.visionResult,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      location: location ?? this.location,
      locationInfo: locationInfo ?? this.locationInfo,
      orientation: orientation ?? this.orientation,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  String toString() {
    return 'VisionCapture(id: $id, name: $name, category: $category, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VisionCapture &&
        other.id == id &&
        other.imagePath == imagePath &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ imagePath.hashCode ^ timestamp.hashCode;
}
