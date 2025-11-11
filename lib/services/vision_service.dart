import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'env.dart';
import 'geocoding_service.dart';
import 'orientation_service.dart';

class VisionResult {
  final String name;
  final String type;
  final String category;
  final String description;
  final String rarity;
  final Position? location;
  final LocationInfo? locationInfo;
  final CameraOrientation? orientation;
  final File imageFile;

  VisionResult({
    required this.name,
    required this.type,
    required this.category,
    required this.description,
    required this.rarity,
    required this.imageFile,
    this.location,
    this.locationInfo,
    this.orientation,
  });
}

/// Service para Google Gemini Vision (IA generativa, mucho mejor que Vision API).
class VisionService {
  static const _geminiEndpoint =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent';

  /// Detecta y describe la imagen usando Gemini Vision AI.
  Future<VisionResult?> detectBestMatch(
    File imageFile, {
    Position? location,
    LocationInfo? locationInfo,
    CameraOrientation? orientation,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final apiKey = Env.googleGeminiApiKey;
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Construir contexto de ubicación si existe
      String locationContext = '';
      if (location != null && locationInfo != null) {
        locationContext =
            '\n\nIMPORTANT CONTEXT - Photo taken at:\nLocation: ${locationInfo.fullLocation}\nCoordinates: ${location.latitude}, ${location.longitude}';
        if (locationInfo.placeName != null) {
          locationContext += '\nNearby place: ${locationInfo.placeName}';
        }

        // Agregar orientación de cámara si está disponible
        if (orientation != null) {
          locationContext +=
              '\nCamera pointing at: ${orientation.bearing.toStringAsFixed(0)}° (${orientation.cardinalDirection})';
          locationContext +=
              '\n\nCRITICAL: Use the camera bearing to identify distant landmarks. The camera is pointing ${orientation.cardinalDirection} from the user location. If there are famous landmarks, mountains, volcanoes, or buildings in that direction, identify them by name.';
          locationContext +=
              '\nExample: User at coordinates near La Fortuna, Costa Rica, camera pointing West (270°) = Volcán Arenal is in that direction, so identify it as "Volcán Arenal".';
        }

        locationContext +=
            '\n\nIf this is a landmark, building, mountain, river, or famous place, use the GPS location and camera direction to identify its EXACT name. For example, if coordinates are near "Volcán Arenal" in Costa Rica, identify it as "Volcán Arenal", not just "Volcán".';
        locationContext +=
            '\n\nIMPORTANT FOR LANDMARKS AND MONUMENTS:\n- Real vs Replica: If you see a famous monument (e.g., Eiffel Tower, Statue of Liberty) but GPS shows it\'s NOT in the original location, identify it as a REPLICA. Example: Eiffel Tower photo in Las Vegas = "Torre Eiffel (Réplica de Las Vegas)", NOT "Torre Eiffel".';
        locationContext +=
            '\n- Miniatures/Souvenirs: If the scale/context suggests it\'s a miniature, keychain, or souvenir (visible hands holding it, indoor setting, small size), identify it as such. Example: "Torre Eiffel (Llavero/Miniatura)", NOT the real monument.';
        locationContext +=
            '\n- Local Replicas: Many countries have replicas of famous monuments. Always specify the location. Example: "Torre Eiffel (Réplica en Parque de la Paz, Guatemala)" or "Estatua de la Libertad (Réplica en Tokio, Japón)".';
        locationContext +=
            '\n\nIMPORTANT FOR SPECIES IDENTIFICATION:\n- Trees/Plants: Geographic location is CRITICAL. Many trees look similar but are different species depending on the country. Example: "Ceiba" in Costa Rica vs "Kapok" in Asia - same family, different species. Use country/region to identify the EXACT species name and local name.';
        locationContext +=
            '\n- Animals: Some animals have regional variations or subspecies. Example: "Tucán Pico Iris" in Central America vs other toucan species in South America. Always specify the regional species.';
        locationContext +=
            '\n- Fruits: Many tropical fruits have regional names and varieties. Example: "Guanábana" in Costa Rica, "Soursop" elsewhere, "Graviola" in Brazil - botanically Annona muricata. Use the LOCAL name for the country.';
        locationContext +=
            '\n- Regional Endemic Species: If the species is endemic or native to this specific region/country, mention it in the description (e.g., "Endémico de Costa Rica").';
      }

      final prompt =
          '''Identify the main object in this image and respond ONLY with this JSON (no markdown, no code blocks):
{"name": "specific object name", "type": "specific type/breed/model", "category": "landmark|animal|food|building|nature|product|vehicle|other", "description": "brief description in Spanish", "rarity": "common|uncommon|rare|epic|legendary"}$locationContext

Examples:
- Animal: {"name": "Perro", "type": "Pomerania", "category": "animal", "description": "Peludo y adorable", "rarity": "common"}
- Real Landmark (Paris, France): {"name": "Torre Eiffel", "type": "Monumento icónico", "category": "landmark", "description": "Torre de hierro de 330m en París", "rarity": "legendary"}
- Replica (Las Vegas, USA): {"name": "Torre Eiffel (Réplica)", "type": "Réplica a escala 1:2", "category": "landmark", "description": "Réplica del Hotel Paris en Las Vegas", "rarity": "rare"}
- Miniature/Souvenir: {"name": "Torre Eiffel (Llavero)", "type": "Souvenir miniatura", "category": "product", "description": "Llavero decorativo de la Torre Eiffel", "rarity": "common"}
- Tree with GPS (Costa Rica): {"name": "Ceiba", "type": "Ceiba pentandra", "category": "nature", "description": "Árbol sagrado maya nativo de Centroamérica", "rarity": "rare"}
- Animal with GPS (Costa Rica): {"name": "Tucán Pico Iris", "type": "Ramphastos sulfuratus", "category": "animal", "description": "Ave nacional de Belice, común en Costa Rica", "rarity": "uncommon"}
- Landmark with GPS: {"name": "Volcán Arenal", "type": "Volcán estratovolcán", "category": "landmark", "description": "Volcán activo en Costa Rica", "rarity": "epic"}
- Food: {"name": "Gallo Pinto", "type": "Plato típico", "category": "food", "description": "Arroz con frijoles costarricense", "rarity": "uncommon"}''';

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.2,
          'topK': 1,
          'topP': 0.8,
          'maxOutputTokens': 600,
        },
      });

      final uri = Uri.parse('$_geminiEndpoint?key=$apiKey');
      debugPrint('🌐 Gemini: Analyzing image...');

      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(timeout);

      debugPrint('📡 Gemini status: ${response.statusCode}');

      if (response.statusCode != 200) {
        debugPrint('❌ Gemini error: ${response.body}');
        return null;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('🔍 Full response: $decoded');

      final candidates = decoded['candidates'] as List<dynamic>?;

      if (candidates == null || candidates.isEmpty) {
        debugPrint('⚠️ No candidates returned');
        return null;
      }

      final firstCandidate = candidates.first as Map<String, dynamic>;
      debugPrint('🔍 First candidate: $firstCandidate');

      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = (parts?.first as Map<String, dynamic>?)?['text'] as String?;

      if (text == null || text.isEmpty) {
        debugPrint('⚠️ Empty response text');
        debugPrint('🔍 Content: $content');
        debugPrint('🔍 Parts: $parts');
        return null;
      }

      debugPrint('📝 Gemini response: $text');

      // Extraer JSON del texto (puede venir con markdown)
      final jsonMatch = RegExp(r'\{[^\}]+\}').firstMatch(text);
      if (jsonMatch == null) {
        debugPrint('⚠️ No JSON found in response');
        return null;
      }

      final jsonText = jsonMatch.group(0)!;
      final result = jsonDecode(jsonText) as Map<String, dynamic>;

      final name = result['name'] as String? ?? 'Unknown Object';
      final type = result['type'] as String? ?? 'Unknown Type';
      final category = result['category'] as String? ?? 'other';
      final description = result['description'] as String? ?? '';
      final rarity = result['rarity'] as String? ?? 'common';

      debugPrint('✅ Detected: $name ($type) - $rarity');

      return VisionResult(
        name: name,
        type: type,
        category: category,
        description: description,
        rarity: rarity,
        imageFile: imageFile,
        location: location,
        locationInfo: locationInfo,
        orientation: orientation,
      );
    } on TimeoutException {
      debugPrint('VisionService timeout');
      return null;
    } on SocketException {
      debugPrint('VisionService network error');
      return null;
    } catch (e, stack) {
      debugPrint('VisionService error: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }
}
