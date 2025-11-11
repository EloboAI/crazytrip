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
  final double confidence; // 0.0-1.0 confidence score
  final String specificityLevel; // specific|general|group|unknown
  final String? broaderContext; // e.g., "Parte de la Cordillera de Talamanca"
  final String
  encounterRarity; // easy|medium|hard|epic - qué tan raro es ver esto AQUÍ
  final String authenticity; // real|screen|print|unknown - autenticidad de la imagen
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
    required this.confidence,
    required this.specificityLevel,
    this.broaderContext,
    required this.encounterRarity,
    this.authenticity = 'unknown', // Default si no viene en respuesta
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
    Duration timeout = const Duration(seconds: 30),
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
              '\nCamera: ${orientation.bearing.toStringAsFixed(0)}° ${orientation.cardinalDirection}';
          locationContext +=
              '\nUse bearing to identify landmarks (e.g., volcano, mountain) in that direction by EXACT name.';
        }

        locationContext +=
            '\n\nRULES:\n- Landmarks: Use GPS+bearing for EXACT names (not generic terms)';
        locationContext +=
            '\n- Replicas: If monument GPS doesn\'t match origin, mark as replica';
        locationContext +=
            '\n- Species: Use LOCAL regional names based on country (e.g., "Tucán Pico Iris" in Costa Rica)';
        locationContext +=
            '\n- Encounter rarity: Consider if object is geographically common/rare HERE (arctic animal in tropics=epic)';
      } else if (location == null) {
        // Modo degradado: sin GPS
        debugPrint('⚠️ Vision API - No location context available (GPS disabled)');
        locationContext =
            '\n\nNOTE: GPS unavailable. Identify without geographic context. Use generic international names for species/landmarks.';
      }

      final prompt =
          '''Identify objects/landmarks with precision. Analyze image and provide JSON response.

RULES:
- Use GPS+bearing for EXACT landmark names ("Volcán Turrialba" not "Cordillera")
- If uncertain (confidence<0.6): name="Objeto no identificado"
- Prefer specific over general identification
- Never guess

ENCOUNTER RARITY (how rare to see THIS object HERE):
- easy: Very common here (gallo pinto in Costa Rica)
- medium: Somewhat common, needs luck (toucan in Costa Rica)
- hard: Rare here (jaguar in Costa Rica)
- epic: Geographically impossible/extreme (polar bear in tropics)

AUTHENTICITY CHECK (detect if image is real or reproduced):
LOOK FOR:
- Screen pixels: Digital display grid, pixel patterns, refresh lines, backlight glow
- Printer dots: CMYK dot matrix, halftone patterns, ink bleeding, paper texture
- Flat surface: No depth parallax, uniform lighting, lack of natural shadows
- Frame borders: Phone/monitor bezels, TV edges, computer screen frame
- Glare patterns: Unnatural reflections from glass surfaces (screens, frames)
- Color uniformicity: Digital color clipping, unnatural saturation

CLASSIFY AS:
- "real": Direct capture of physical 3D object/scene with natural depth and lighting
- "screen": Photo of digital display (phone, TV, monitor, tablet)
- "print": Photo of printed image (magazine, poster, photo paper)
- "unknown": Cannot determine (low quality, extreme angle, unclear source)

DEFAULT: If no screen/print indicators present → "real"

RESPONSE (JSON only, no markdown):
{
  "name": "specific name OR 'Objeto no identificado'",
  "type": "specific type/species OR 'Desconocido'",
  "category": "landmark|animal|food|building|nature|product|vehicle|other|unknown",
  "description": "brief Spanish description",
  "rarity": "common|uncommon|rare|epic|legendary",
  "confidence": 0.0-1.0,
  "specificity_level": "specific|general|group|unknown",
  "broader_context": "optional context",
  "encounter_rarity": "easy|medium|hard|epic",
  "authenticity": "real|screen|print|unknown"
}$locationContext

EXAMPLES:
{"name": "Volcán Turrialba", "type": "Volcán estratovolcán activo", "category": "landmark", "description": "Volcán activo de 3340m en Costa Rica", "rarity": "epic", "confidence": 0.95, "specificity_level": "specific", "broader_context": "Cordillera Volcánica Central", "encounter_rarity": "medium", "authenticity": "real"}
{"name": "Tucán Pico Iris", "type": "Ramphastos sulfuratus", "category": "animal", "description": "Ave emblemática de Centroamérica", "rarity": "uncommon", "confidence": 0.93, "specificity_level": "specific", "broader_context": null, "encounter_rarity": "medium", "authenticity": "real"}
{"name": "Gallo Pinto", "type": "Plato típico", "category": "food", "description": "Arroz con frijoles tradicional", "rarity": "uncommon", "confidence": 0.91, "specificity_level": "specific", "broader_context": null, "encounter_rarity": "easy", "authenticity": "screen"}
{"name": "Jaguar", "type": "Panthera onca", "category": "animal", "description": "Felino en peligro de extinción", "rarity": "legendary", "confidence": 0.89, "specificity_level": "specific", "broader_context": null, "encounter_rarity": "epic", "authenticity": "print"}''';

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
          'temperature': 0.1, // Más determinístico para mayor precisión
          'topK': 1,
          'topP': 0.8,
          'maxOutputTokens': 2048,
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

      final name = result['name'] as String? ?? 'Objeto no identificado';
      final type = result['type'] as String? ?? 'Desconocido';
      final category = result['category'] as String? ?? 'unknown';
      final description = result['description'] as String? ?? '';
      final rarity = result['rarity'] as String? ?? 'common';
      final confidence = (result['confidence'] as num?)?.toDouble() ?? 0.5;
      final specificityLevel =
          result['specificity_level'] as String? ?? 'unknown';
      final broaderContext = result['broader_context'] as String?;
      final encounterRarity = result['encounter_rarity'] as String? ?? 'easy';
      final authenticity = result['authenticity'] as String? ?? 'unknown';

      debugPrint(
        '✅ Detected: $name ($type) - $rarity (confidence: ${(confidence * 100).toStringAsFixed(0)}%, specificity: $specificityLevel, encounter: $encounterRarity, authenticity: $authenticity)',
      );

      return VisionResult(
        name: name,
        type: type,
        category: category,
        description: description,
        rarity: rarity,
        confidence: confidence,
        specificityLevel: specificityLevel,
        broaderContext: broaderContext,
        encounterRarity: encounterRarity,
        authenticity: authenticity,
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
