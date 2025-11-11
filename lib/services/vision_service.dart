import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'env.dart';

class VisionResult {
  final String name;
  final String type;
  final String category;
  final String description;
  final String rarity;
  final Position? location;

  VisionResult({
    required this.name,
    required this.type,
    required this.category,
    required this.description,
    required this.rarity,
    this.location,
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
    Duration timeout = const Duration(seconds: 8),
  }) async {
    try {
      final apiKey = Env.googleGeminiApiKey;
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt =
          '''Identify the main object in this image and respond ONLY with this JSON (no markdown, no code blocks):
{"name": "specific object name", "type": "specific type/breed/model", "category": "landmark|animal|food|building|nature|product|vehicle|other", "description": "brief description in Spanish", "rarity": "common|uncommon|rare|epic|legendary"}

Examples:
- Animal: {"name": "Perro", "type": "Pomerania", "category": "animal", "description": "Peludo y adorable", "rarity": "common"}
- Landmark: {"name": "Torre Eiffel", "type": "Monumento histórico", "category": "landmark", "description": "Icónica torre de París", "rarity": "legendary"}
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
          'maxOutputTokens': 500,
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
        location: location,
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
