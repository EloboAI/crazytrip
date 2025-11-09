import 'package:geolocator/geolocator.dart';

/// Servicio para manejar permisos y obtención de ubicación del usuario
class LocationService {
  /// Verifica y solicita permisos de ubicación
  /// 
  /// Retorna `true` si los permisos están concedidos o el usuario los acepta
  /// Retorna `false` si los permisos son denegados
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si el servicio de ubicación está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // El servicio de ubicación no está habilitado, no se puede continuar
      return false;
    }

    // Verificar el estado actual de los permisos
    permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // Los permisos están denegados, solicitar permisos
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Los permisos fueron denegados
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Los permisos están permanentemente denegados
      // El usuario debe habilitarlos manualmente desde configuración
      return false;
    }

    // Los permisos están concedidos
    return true;
  }

  /// Obtiene la ubicación actual del usuario
  /// 
  /// Retorna `null` si no se puede obtener la ubicación
  static Future<Position?> getCurrentLocation() async {
    try {
      // Verificar permisos antes de obtener la ubicación
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Obtener la ubicación actual con alta precisión
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10, // Actualizar solo si se mueve 10 metros
        ),
      );

      return position;
    } catch (e) {
      // Error al obtener la ubicación
      return null;
    }
  }

  /// Crea un stream para escuchar cambios de ubicación en tiempo real
  /// 
  /// Este stream emite la nueva posición cada vez que el usuario se mueve
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Actualizar solo si se mueve 10 metros
        timeLimit: Duration(seconds: 10), // Timeout después de 10 segundos
      ),
    );
  }

  /// Verifica el estado actual de los permisos sin solicitarlos
  /// 
  /// Retorna el estado actual del permiso de ubicación
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Verifica si el servicio de ubicación está habilitado en el dispositivo
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Abre la configuración de la aplicación para que el usuario pueda
  /// habilitar los permisos manualmente
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Abre la configuración de ubicación del dispositivo
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Calcula la distancia entre dos puntos en metros
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }
}
