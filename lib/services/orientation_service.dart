import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;

class CameraOrientation {
  final double bearing; // Dirección hacia donde apunta (0-360°, 0=Norte)
  final double pitch; // Inclinación vertical (-90 a 90°, 0=horizontal)
  final double? accuracy; // Precisión de la brújula

  CameraOrientation({required this.bearing, this.pitch = 0.0, this.accuracy});

  /// Convierte bearing a dirección cardinal
  String get cardinalDirection {
    if (bearing >= 337.5 || bearing < 22.5) return 'Norte';
    if (bearing >= 22.5 && bearing < 67.5) return 'Noreste';
    if (bearing >= 67.5 && bearing < 112.5) return 'Este';
    if (bearing >= 112.5 && bearing < 157.5) return 'Sureste';
    if (bearing >= 157.5 && bearing < 202.5) return 'Sur';
    if (bearing >= 202.5 && bearing < 247.5) return 'Suroeste';
    if (bearing >= 247.5 && bearing < 292.5) return 'Oeste';
    if (bearing >= 292.5 && bearing < 337.5) return 'Noroeste';
    return 'Desconocido';
  }

  /// Retorna descripción legible de la orientación
  String get description {
    final pitchDesc =
        pitch > 30
            ? 'apuntando hacia arriba'
            : pitch < -30
            ? 'apuntando hacia abajo'
            : 'horizontal';
    return 'Dirección: $cardinalDirection (${bearing.toStringAsFixed(0)}°), $pitchDesc';
  }

  @override
  String toString() =>
      'CameraOrientation(bearing: ${bearing.toStringAsFixed(1)}°, pitch: ${pitch.toStringAsFixed(1)}°, direction: $cardinalDirection)';
}

/// Servicio para obtener la orientación de la cámara
/// usando la brújula y sensores de inclinación del dispositivo
class OrientationService {
  StreamSubscription<CompassEvent>? _compassSubscription;
  CameraOrientation? _lastOrientation;

  /// Obtiene la orientación actual de la cámara (una sola vez)
  Future<CameraOrientation?> getCurrentOrientation() async {
    try {
      // Verificar si el sensor está disponible
      final hasCompass = await FlutterCompass.events?.first != null;
      if (!hasCompass) {
        debugPrint('⚠️ Compass sensor not available');
        return null;
      }

      // Obtener lectura de la brújula
      CompassEvent? compassEvent;
      try {
        compassEvent = await FlutterCompass.events?.first.timeout(
          const Duration(seconds: 2),
        );
      } catch (e) {
        debugPrint('⚠️ Compass timeout: $e');
        return null;
      }

      if (compassEvent == null) {
        debugPrint('⚠️ Could not read compass');
        return null;
      }

      final bearing = compassEvent.heading ?? 0.0;
      final accuracy = compassEvent.accuracy;

      debugPrint(
        '🧭 Compass: ${bearing.toStringAsFixed(1)}° (accuracy: ${accuracy?.toStringAsFixed(1) ?? "unknown"})',
      );

      _lastOrientation = CameraOrientation(
        bearing: bearing,
        pitch: 0.0, // TODO: Implementar pitch con acelerómetro si se necesita
        accuracy: accuracy,
      );

      return _lastOrientation;
    } catch (e) {
      debugPrint('OrientationService error: $e');
      return null;
    }
  }

  /// Inicia stream continuo de orientación (para actualizaciones en tiempo real)
  Stream<CameraOrientation> getOrientationStream() {
    return FlutterCompass.events!.map((event) {
      final bearing = event.heading ?? 0.0;
      final accuracy = event.accuracy;

      _lastOrientation = CameraOrientation(
        bearing: bearing,
        pitch: 0.0,
        accuracy: accuracy,
      );

      return _lastOrientation!;
    });
  }

  /// Calcula el punto aproximado hacia donde apunta la cámara
  /// basándose en ubicación actual, bearing y distancia estimada
  ({double latitude, double longitude}) calculatePointingLocation({
    required double currentLat,
    required double currentLng,
    required double bearing,
    double distanceKm = 5.0, // Distancia estimada por defecto: 5km
  }) {
    // Radio de la Tierra en km
    const earthRadius = 6371.0;

    // Convertir a radianes
    final lat1 = _toRadians(currentLat);
    final lng1 = _toRadians(currentLng);
    final bearingRad = _toRadians(bearing);
    final angularDistance = distanceKm / earthRadius;

    // Calcular nueva latitud
    final lat2 = math.asin(
      math.sin(lat1) * math.cos(angularDistance) +
          math.cos(lat1) * math.sin(angularDistance) * math.cos(bearingRad),
    );

    // Calcular nueva longitud
    final lng2 =
        lng1 +
        math.atan2(
          math.sin(bearingRad) * math.sin(angularDistance) * math.cos(lat1),
          math.cos(angularDistance) - math.sin(lat1) * math.sin(lat2),
        );

    return (latitude: _toDegrees(lat2), longitude: _toDegrees(lng2));
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;
  double _toDegrees(double radians) => radians * 180 / math.pi;

  /// Última orientación capturada (útil para debugging)
  CameraOrientation? get lastOrientation => _lastOrientation;

  /// Limpia recursos
  void dispose() {
    _compassSubscription?.cancel();
  }
}
