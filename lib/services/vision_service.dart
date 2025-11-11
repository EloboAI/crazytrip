import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'env.dart';

/// Service para Google Cloud Vision (Landmark Detection).
/// Minimal MVP: enviar imagen JPEG y recibir landmarks (máx 3s).
class VisionService {
  static const _endpoint = 'https://vision.googleapis.com/v1/images:annotate';

  /// Detecta landmarks en un archivo de imagen (JPEG recomendado).
  /// Retorna lista de descripciones; si timeout o error, retorna lista vacía.
  Future<List<String>> detectLandmarks(File imageFile, {Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final apiKey = Env.googleVisionApiKey; // Puede lanzar si falta.
      final bytes = await imageFile.readAsBytes();
      final content = base64Encode(bytes);

      final body = jsonEncode({
        'requests': [
          {
            'image': {'content': content},
            'features': [
              {'type': 'LANDMARK_DETECTION', 'maxResults': 5}
            ]
          }
        ]
      });

      final uri = Uri.parse('$_endpoint?key=$apiKey');
      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(timeout);

      if (response.statusCode != 200) {
        debugPrint('VisionService: status ${response.statusCode} body=${response.body}');
        return [];
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final responses = decoded['responses'] as List<dynamic>?;
      if (responses == null || responses.isEmpty) return [];
      final annotations = (responses.first as Map<String, dynamic>)['landmarkAnnotations'] as List<dynamic>?;
      if (annotations == null) return [];
      return annotations
          .map((a) => (a as Map<String, dynamic>)['description'] as String? ?? '')
          .where((d) => d.isNotEmpty)
          .toList();
    } on TimeoutException catch (e) {
      debugPrint('VisionService: timeout $e');
      return [];
    } on SocketException catch (e) {
      debugPrint('VisionService: network error $e');
      return [];
    } catch (e) {
      debugPrint('VisionService: error $e');
      return [];
    }
  }
}
