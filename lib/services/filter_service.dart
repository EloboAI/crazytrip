import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import '../models/image_filter.dart';

class FilterService {
  ImageFilter _currentFilter = ImageFilter.getPredefinedFilters().first;
  double _intensity = 1.0;
  final StreamController<ImageFilter> _filterController = StreamController<ImageFilter>.broadcast();
  final StreamController<double> _intensityController = StreamController<double>.broadcast();

  Stream<ImageFilter> get filterStream => _filterController.stream;
  Stream<double> get intensityStream => _intensityController.stream;

  ImageFilter get currentFilter => _currentFilter;
  double get intensity => _intensity;

  void setFilter(ImageFilter filter) {
    _currentFilter = filter;
    _filterController.add(filter);
  }

  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0.0, 1.0);
    _intensityController.add(_intensity);
    
    // Actualizar el filtro actual con la nueva intensidad
    _currentFilter = _currentFilter.copyWith(intensity: _intensity);
    _filterController.add(_currentFilter);
  }

  Future<ui.Image> applyFilterToCameraImage(CameraImage cameraImage, ImageFilter filter) async {
    try {
      // Convertir CameraImage a imagen procesable
      final imageBytes = _convertCameraImageToBytes(cameraImage);
      if (imageBytes == null) {
        // Retornar una imagen mínima si la conversión falla
        final completer = Completer<ui.Image>();
        ui.decodeImageFromPixels(
          Uint8List.fromList([0, 0, 0, 0]),
          1,
          1,
          ui.PixelFormat.rgba8888,
          (ui.Image result) => completer.complete(result),
        );
        return completer.future;
      }

      // Aplicar filtro
      final filteredBytes = ImageFilter.applyFilter(imageBytes, filter);
      
      // Decodificar bytes filtrados (JPG/PNG) directamente a ui.Image de forma compatible con web
      final completer = Completer<ui.Image>();
      final codec = await ui.instantiateImageCodec(filteredBytes);
      final frame = await codec.getNextFrame();
      completer.complete(frame.image);
      return completer.future;
    } catch (e) {
      print('Error al aplicar filtro: $e');
      // Retornar imagen original si hay error
      final original = _convertCameraImageToBytes(cameraImage);
      final completer = Completer<ui.Image>();
      ui.decodeImageFromPixels(
        original ?? Uint8List.fromList([0, 0, 0, 0]),
        original != null ? cameraImage.width : 1,
        original != null ? cameraImage.height : 1,
        ui.PixelFormat.rgba8888,
        (ui.Image result) => completer.complete(result),
      );
      return completer.future;
    }
  }

  Future<Uint8List> applyFilterToFile(String filePath, ImageFilter filter) async {
    try {
      final imageBytes = await XFile(filePath).readAsBytes();
      return ImageFilter.applyFilter(imageBytes, filter);
    } catch (e) {
      print('Error al aplicar filtro a archivo: $e');
      rethrow;
    }
  }

  Future<Uint8List> applyFilterToBytes(Uint8List imageBytes, ImageFilter filter) async {
    try {
      return ImageFilter.applyFilter(imageBytes, filter);
    } catch (e) {
      print('Error al aplicar filtro a bytes: $e');
      rethrow;
    }
  }

  Uint8List? _convertCameraImageToBytes(CameraImage image) {
    try {
      final int width = image.width;
      final int height = image.height;
      final Uint8List rgbaBytes = Uint8List(width * height * 4);

      // Convertir YUV420 a RGBA
      if (image.format.group == ImageFormatGroup.yuv420) {
        final yRowStride = image.planes[0].bytesPerRow;
        final uvRowStride = image.planes[1].bytesPerRow;
        final uvPixelStride = image.planes[1].bytesPerPixel ?? 1;

        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final yIndex = y * yRowStride + x;
            final uvIndex = (y ~/ 2) * uvRowStride + (x ~/ 2) * uvPixelStride;
            
            final yValue = image.planes[0].bytes[yIndex];
            final uValue = image.planes[1].bytes[uvIndex];
            final vValue = image.planes[2].bytes[uvIndex];

            // Convertir YUV a RGB
            final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
            final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128)).clamp(0, 255).toInt();
            final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

            final rgbaIndex = (y * width + x) * 4;
            rgbaBytes[rgbaIndex] = r;
            rgbaBytes[rgbaIndex + 1] = g;
            rgbaBytes[rgbaIndex + 2] = b;
            rgbaBytes[rgbaIndex + 3] = 255; // Alpha
          }
        }
      } else if (image.format.group == ImageFormatGroup.bgra8888) {
        // Formato BGRA8888
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final pixelIndex = (y * width + x) * 4;
            final b = image.planes[0].bytes[pixelIndex];
            final g = image.planes[0].bytes[pixelIndex + 1];
            final r = image.planes[0].bytes[pixelIndex + 2];
            final a = image.planes[0].bytes[pixelIndex + 3];

            final rgbaIndex = (y * width + x) * 4;
            rgbaBytes[rgbaIndex] = r;
            rgbaBytes[rgbaIndex + 1] = g;
            rgbaBytes[rgbaIndex + 2] = b;
            rgbaBytes[rgbaIndex + 3] = a;
          }
        }
      }

      return rgbaBytes;
    } catch (e) {
      print('Error al convertir imagen de cámara: $e');
      return null;
    }
  }

  void dispose() {
    _filterController.close();
    _intensityController.close();
  }
}