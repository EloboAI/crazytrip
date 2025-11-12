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
  final String
  authenticity; // real|screen|print|unknown - autenticidad de la imagen
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
          locationContext += '\n\n🔍 CRITICAL FOR MOUNTAINS/PEAKS:';
          locationContext +=
              '\n- Use GPS + bearing to identify EXACT peak names by triangulation';
          locationContext +=
              '\n- Analyze peak shapes, ridges, and silhouettes visible from this viewpoint';
          locationContext +=
              '\n- Cross-reference visible peaks with known mountains in that direction';
          locationContext +=
              '\n- If multiple peaks visible, identify the most prominent/central one';
          locationContext +=
              '\n- Include elevation if known for identified peak';
          locationContext +=
              '\n- Example: From San José (9.93°N, -84.08°W) looking N (0°) → "Volcán Barva"';
          locationContext +=
              '\n- Example: From Cartago (9.86°N, -83.92°W) looking NE (45°) → "Volcán Irazú"';
        }

        locationContext +=
            '\n\nRULES:\n- Mountains/Peaks: MANDATORY use GPS+bearing for triangulation and EXACT peak names';
        locationContext +=
            '\n- Never use generic terms like "Cordillera" or "Montaña" - identify SPECIFIC peaks';
        locationContext +=
            '\n- Landmarks: Use GPS+bearing for EXACT names (not generic terms)';
        locationContext +=
            '\n- Replicas: If monument GPS doesn\'t match origin, mark as replica';
        locationContext +=
            '\n- Species: Use LOCAL regional names based on country (e.g., "Tucán Pico Iris" in Costa Rica)';
        locationContext +=
            '\n- Encounter rarity: Consider if object is geographically common/rare HERE (arctic animal in tropics=epic)';
      } else if (location == null) {
        // Modo degradado: sin GPS
        debugPrint(
          '⚠️ Vision API - No location context available (GPS disabled)',
        );
        locationContext =
            '\n\nNOTE: GPS unavailable. Identify without geographic context. Use generic international names for species/landmarks.';
      }

      final prompt =
          '''Identify and analyze. Return ONLY valid JSON, no markdown.

GPS+BEARING: Use for EXACT landmark/mountain names via triangulation.
CONFIDENCE<0.6: name="Objeto no identificado"

ENCOUNTER_RARITY (how rare HERE): easy|medium|hard|epic

AUTHENTICITY (real scene vs screen/print):
- real: Direct 3D capture
- screen: Digital display photo
- print: Printed image photo
- unknown: Cannot determine

CATEGORY_METADATA (include relevant fields):

ANIMAL: {"species":"Scientific name","conservation_status":"LC|NT|VU|EN|CR","conservation_label":"Spanish label","habitat":"Description","is_endemic":bool,"endemic_region":"Region or null"}

VEHICLE: {"brand":"Brand","model":"Model","year_range":"Year","vehicle_type":"Type","is_electric":bool,"sustainability_note":"Note or null"}

BUILDING: {"building_type":"Type","certifications":["Bandera Azul","LEED"] or null,"sustainability_features":"Features or null"}

FOOD: {"cuisine":"Type","is_traditional":bool,"main_ingredients":["list"],"dietary_info":["vegetarian","vegan"] or null}

NATURE: {"nature_type":"mountain|volcano|peak|plant|etc","elevation_meters":int or null,"mountain_range":"Range or null","volcanic_status":"active|dormant|extinct|not_applicable","last_eruption":"Year or null","visible_peaks":["Peak1","Peak2"] or null,"identification_method":"GPS+bearing triangulation|visual|database"}

LANDMARK: {"cultural_significance":"Description","unesco_status":bool,"construction_year":"Year or null"}

PRODUCT: {"brand":"Brand or null","is_handmade":bool,"sustainability_note":"Note or null"}

RESPONSE:
{
  "name": "Specific name or 'Objeto no identificado'",
  "type": "Specific type or 'Desconocido'",
  "category": "landmark|animal|food|building|nature|product|vehicle|other|unknown",
  "description": "Brief Spanish description",
  "rarity": "common|uncommon|rare|epic|legendary",
  "confidence": 0.0-1.0,
  "specificity_level": "specific|general|group|unknown",
  "broader_context": "Context or null",
  "encounter_rarity": "easy|medium|hard|epic",
  "authenticity": "real|screen|print|unknown",
  "category_metadata": {}
}$locationContext''';

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
          'maxOutputTokens': 5000, // Reducido para prompt más conciso
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

      // Check finish reason
      final finishReason = firstCandidate['finishReason'] as String?;
      if (finishReason != null && finishReason != 'STOP') {
        debugPrint('⚠️ Response finished with reason: $finishReason');
        if (finishReason == 'MAX_TOKENS') {
          debugPrint('💡 Hint: Prompt too long, response truncated');
        } else if (finishReason == 'SAFETY') {
          debugPrint('💡 Hint: Content blocked by safety filters');
        } else if (finishReason == 'RECITATION') {
          debugPrint('💡 Hint: Content flagged as recitation');
        }
      }

      final content = firstCandidate['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = (parts?.first as Map<String, dynamic>?)?['text'] as String?;

      if (text == null || text.isEmpty) {
        debugPrint('⚠️ Empty response text');
        debugPrint('🔍 Content: $content');
        debugPrint('🔍 Parts: $parts');
        debugPrint('🔍 Finish reason: $finishReason');

        // Check for safety ratings
        final safetyRatings = firstCandidate['safetyRatings'] as List?;
        if (safetyRatings != null) {
          debugPrint('🔍 Safety ratings: $safetyRatings');
        }

        return null;
      }

      debugPrint('📝 Gemini response: $text');

      // Extraer JSON del texto (puede venir con markdown o texto adicional)
      // Buscar el JSON completo balanceando llaves
      String? jsonText;
      final firstBrace = text.indexOf('{');

      if (firstBrace == -1) {
        debugPrint('⚠️ No JSON found in response');
        return null;
      }

      // Extraer JSON balanceando llaves
      int braceCount = 0;
      int startIndex = firstBrace;
      int endIndex = startIndex;

      for (int i = startIndex; i < text.length; i++) {
        if (text[i] == '{') {
          braceCount++;
        } else if (text[i] == '}') {
          braceCount--;
          if (braceCount == 0) {
            endIndex = i + 1;
            break;
          }
        }
      }

      if (braceCount != 0) {
        debugPrint('⚠️ Unbalanced JSON braces in response');
        return null;
      }

      jsonText = text.substring(startIndex, endIndex);
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
