import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'env.dart';

class LocationInfo {
  final String country;
  final String state; // Provincia/Estado
  final String city; // Ciudad/Distrito
  final String address;
  final String? placeName; // Nombre del lugar específico si existe

  LocationInfo({
    required this.country,
    required this.state,
    required this.city,
    required this.address,
    this.placeName,
  });

  String get fullLocation => '$city, $state, $country';
}

/// Servicio para obtener información de ubicación desde coordenadas GPS
class GeocodingService {
  /// Obtiene información de ubicación usando Google Maps Geocoding API
  Future<LocationInfo?> getLocationInfo(Position position) async {
    try {
      final apiKey = Env.googleMapsApiKey;
      final lat = position.latitude;
      final lng = position.longitude;

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey&language=es',
      );

      debugPrint('🌍 Geocoding: $lat, $lng');

      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        debugPrint('❌ Geocoding error: ${response.statusCode}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List<dynamic>?;

      if (results == null || results.isEmpty) {
        debugPrint('⚠️ No geocoding results');
        return null;
      }

      // Primer resultado tiene la info más detallada
      final result = results.first as Map<String, dynamic>;
      final components = result['address_components'] as List<dynamic>;

      String country = '';
      String state = '';
      String city = '';
      String? placeName;

      // Extraer componentes de la dirección
      for (final component in components) {
        final types = (component['types'] as List<dynamic>).cast<String>();
        final longName = component['long_name'] as String;

        if (types.contains('country')) {
          country = longName;
        } else if (types.contains('administrative_area_level_1')) {
          state = longName; // Provincia/Estado
        } else if (types.contains('administrative_area_level_2') ||
            types.contains('locality')) {
          city = longName; // Ciudad/Distrito
        } else if (types.contains('point_of_interest') ||
            types.contains('establishment')) {
          placeName = longName; // Nombre del lugar específico
        }
      }

      final address = result['formatted_address'] as String? ?? '';

      debugPrint('✅ Location: $city, $state, $country');
      if (placeName != null) debugPrint('📍 Place: $placeName');

      return LocationInfo(
        country: country,
        state: state,
        city: city,
        address: address,
        placeName: placeName,
      );
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return null;
    }
  }
}
