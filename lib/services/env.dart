import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized access to environment variables.
class Env {
  static String _get(String key, {String? fallback}) {
    final v = dotenv.env[key];
    if (v == null || v.isEmpty) {
      if (fallback != null) return fallback;
      throw StateError('Missing env var: $key');
    }
    return v;
  }

  static String get googleMapsApiKey => _get('GOOGLE_MAPS_API_KEY');
  static String get googleVisionApiKey => _get('GOOGLE_VISION_API_KEY');
}
