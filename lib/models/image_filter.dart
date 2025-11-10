import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image/image.dart' as img;

enum FilterType {
  none,
  vintage,
  blackAndWhite,
  sepia,
  vivid,
  warm,
  cool,
  dramatic,
}

class ImageFilter {
  final FilterType type;
  final String name;
  final String description;
  final double intensity;

  ImageFilter({
    required this.type,
    required this.name,
    required this.description,
    this.intensity = 1.0,
  });

  ImageFilter copyWith({
    FilterType? type,
    String? name,
    String? description,
    double? intensity,
  }) {
    return ImageFilter(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      intensity: intensity ?? this.intensity,
    );
  }

  // Aplicar filtro a una imagen
  static Uint8List applyFilter(Uint8List imageBytes, ImageFilter filter) {
    if (filter.type == FilterType.none || filter.intensity == 0) {
      return imageBytes;
    }

    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;

    switch (filter.type) {
      case FilterType.vintage:
        return _applyVintageFilter(image, filter.intensity);
      case FilterType.blackAndWhite:
        return _applyBlackAndWhiteFilter(image, filter.intensity);
      case FilterType.sepia:
        return _applySepiaFilter(image, filter.intensity);
      case FilterType.vivid:
        return _applyVividFilter(image, filter.intensity);
      case FilterType.warm:
        return _applyWarmFilter(image, filter.intensity);
      case FilterType.cool:
        return _applyCoolFilter(image, filter.intensity);
      case FilterType.dramatic:
        return _applyDramaticFilter(image, filter.intensity);
      case FilterType.none:
        return imageBytes;
    }
  }

  static Uint8List _applyVintageFilter(img.Image image, double intensity) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        
        int r = (pixel.r * 0.9 * intensity + pixel.r * (1 - intensity)).toInt();
        int g = (pixel.g * 0.8 * intensity + pixel.g * (1 - intensity)).toInt();
        int b = (pixel.b * 0.6 * intensity + pixel.b * (1 - intensity)).toInt();
        
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);
        
        image.setPixel(x, y, img.ColorRgba8(r, g, b, pixel.a.toInt()));
      }
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  static Uint8List _applyBlackAndWhiteFilter(img.Image image, double intensity) {
    img.Image bwImage = img.grayscale(image);
    
    if (intensity < 1.0) {
      // Mezclar con la imagen original para ajustar intensidad
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          img.Pixel originalPixel = image.getPixel(x, y);
          img.Pixel bwPixel = bwImage.getPixel(x, y);
          
          int r = (bwPixel.r * intensity + originalPixel.r * (1 - intensity)).toInt();
          int g = (bwPixel.g * intensity + originalPixel.g * (1 - intensity)).toInt();
          int b = (bwPixel.b * intensity + originalPixel.b * (1 - intensity)).toInt();
          
          image.setPixel(x, y, img.ColorRgba8(r, g, b, originalPixel.a.toInt()));
        }
      }
      return Uint8List.fromList(img.encodeJpg(image));
    }
    
    return Uint8List.fromList(img.encodeJpg(bwImage));
  }

  static Uint8List _applySepiaFilter(img.Image image, double intensity) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        
        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();
        
        int tr = (0.393 * r + 0.769 * g + 0.189 * b).toInt();
        int tg = (0.349 * r + 0.686 * g + 0.168 * b).toInt();
        int tb = (0.272 * r + 0.534 * g + 0.131 * b).toInt();
        
        tr = (tr * intensity + r * (1 - intensity)).toInt();
        tg = (tg * intensity + g * (1 - intensity)).toInt();
        tb = (tb * intensity + b * (1 - intensity)).toInt();
        
        tr = tr.clamp(0, 255);
        tg = tg.clamp(0, 255);
        tb = tb.clamp(0, 255);
        
        image.setPixel(x, y, img.ColorRgba8(tr, tg, tb, pixel.a.toInt()));
      }
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  static Uint8List _applyVividFilter(img.Image image, double intensity) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        
        int r = (pixel.r * 1.2 * intensity + pixel.r * (1 - intensity)).toInt();
        int g = (pixel.g * 1.15 * intensity + pixel.g * (1 - intensity)).toInt();
        int b = (pixel.b * 1.1 * intensity + pixel.b * (1 - intensity)).toInt();
        
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);
        
        image.setPixel(x, y, img.ColorRgba8(r, g, b, pixel.a.toInt()));
      }
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  static Uint8List _applyWarmFilter(img.Image image, double intensity) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        
        int r = (pixel.r * 1.2 * intensity + pixel.r * (1 - intensity)).toInt();
        int g = pixel.g.toInt();
        int b = (pixel.b * 0.8 * intensity + pixel.b * (1 - intensity)).toInt();
        
        r = r.clamp(0, 255);
        b = b.clamp(0, 255);
        
        image.setPixel(x, y, img.ColorRgba8(r, g, b, pixel.a.toInt()));
      }
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  static Uint8List _applyCoolFilter(img.Image image, double intensity) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        
        int r = (pixel.r * 0.8 * intensity + pixel.r * (1 - intensity)).toInt();
        int g = pixel.g.toInt();
        int b = (pixel.b * 1.2 * intensity + pixel.b * (1 - intensity)).toInt();
        
        r = r.clamp(0, 255);
        b = b.clamp(0, 255);
        
        image.setPixel(x, y, img.ColorRgba8(r, g, b, pixel.a.toInt()));
      }
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  static Uint8List _applyDramaticFilter(img.Image image, double intensity) {
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        
        int r = (pixel.r * 0.9 * intensity + pixel.r * (1 - intensity)).toInt();
        int g = (pixel.g * 0.9 * intensity + pixel.g * (1 - intensity)).toInt();
        int b = (pixel.b * 0.9 * intensity + pixel.b * (1 - intensity)).toInt();
        
        // Aumentar contraste
        r = ((r - 128) * 1.2 + 128).toInt();
        g = ((g - 128) * 1.2 + 128).toInt();
        b = ((b - 128) * 1.2 + 128).toInt();
        
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);
        
        image.setPixel(x, y, img.ColorRgba8(r, g, b, pixel.a.toInt()));
      }
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  // Lista de filtros predefinidos
  static List<ImageFilter> getPredefinedFilters() {
    return [
      ImageFilter(
        type: FilterType.none,
        name: 'Original',
        description: 'Sin filtro',
      ),
      ImageFilter(
        type: FilterType.vintage,
        name: 'Vintage',
        description: 'Apariencia retro',
      ),
      ImageFilter(
        type: FilterType.blackAndWhite,
        name: 'B&N',
        description: 'Blanco y negro',
      ),
      ImageFilter(
        type: FilterType.sepia,
        name: 'Sepia',
        description: 'Tono cálido antiguo',
      ),
      ImageFilter(
        type: FilterType.vivid,
        name: 'Vivo',
        description: 'Colores intensos',
      ),
      ImageFilter(
        type: FilterType.warm,
        name: 'Cálido',
        description: 'Tono cálido',
      ),
      ImageFilter(
        type: FilterType.cool,
        name: 'Frío',
        description: 'Tono frío',
      ),
      ImageFilter(
        type: FilterType.dramatic,
        name: 'Dramático',
        description: 'Alto contraste',
      ),
    ];
  }
}