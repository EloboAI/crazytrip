import 'dart:convert';

enum CameraFlashMode { off, auto, always }

enum CameraQuality { low, medium, high, max }

class CameraSettings {
  final CameraFlashMode flashMode;
  final bool hdrEnabled;
  final CameraQuality quality;
  final bool useFrontCamera;
  final double zoomLevel;
  // Compass / orientation UI settings
  final bool compassEnabled; // show any compass
  final bool
  compassStyleCircular; // true = circular dial, false = rectangular panel
  final bool
  compassShowDegrees; // show numeric degrees alongside cardinal direction

  const CameraSettings({
    this.flashMode = CameraFlashMode.auto,
    this.hdrEnabled = false,
    this.quality = CameraQuality.high,
    this.useFrontCamera = false,
    this.zoomLevel = 1.0,
    this.compassEnabled = true,
    this.compassStyleCircular = true,
    this.compassShowDegrees = true,
  });

  CameraSettings copyWith({
    CameraFlashMode? flashMode,
    bool? hdrEnabled,
    CameraQuality? quality,
    bool? useFrontCamera,
    double? zoomLevel,
    bool? compassEnabled,
    bool? compassStyleCircular,
    bool? compassShowDegrees,
  }) {
    return CameraSettings(
      flashMode: flashMode ?? this.flashMode,
      hdrEnabled: hdrEnabled ?? this.hdrEnabled,
      quality: quality ?? this.quality,
      useFrontCamera: useFrontCamera ?? this.useFrontCamera,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      compassEnabled: compassEnabled ?? this.compassEnabled,
      compassStyleCircular: compassStyleCircular ?? this.compassStyleCircular,
      compassShowDegrees: compassShowDegrees ?? this.compassShowDegrees,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flashMode': flashMode.name,
      'hdrEnabled': hdrEnabled,
      'quality': quality.name,
      'useFrontCamera': useFrontCamera,
      'zoomLevel': zoomLevel,
      'compassEnabled': compassEnabled,
      'compassStyleCircular': compassStyleCircular,
      'compassShowDegrees': compassShowDegrees,
    };
  }

  factory CameraSettings.fromMap(Map<String, dynamic> map) {
    return CameraSettings(
      flashMode: CameraFlashMode.values.firstWhere(
        (e) => e.name == map['flashMode'],
        orElse: () => CameraFlashMode.auto,
      ),
      hdrEnabled: map['hdrEnabled'] ?? false,
      quality: CameraQuality.values.firstWhere(
        (e) => e.name == map['quality'],
        orElse: () => CameraQuality.high,
      ),
      useFrontCamera: map['useFrontCamera'] ?? false,
      zoomLevel: map['zoomLevel']?.toDouble() ?? 1.0,
      compassEnabled: map['compassEnabled'] ?? true,
      compassStyleCircular: map['compassStyleCircular'] ?? true,
      compassShowDegrees: map['compassShowDegrees'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory CameraSettings.fromJson(String source) =>
      CameraSettings.fromMap(json.decode(source));

  @override
  String toString() {
    return 'CameraSettings(flashMode: $flashMode, hdrEnabled: $hdrEnabled, quality: $quality, useFrontCamera: $useFrontCamera, zoomLevel: $zoomLevel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CameraSettings &&
        other.flashMode == flashMode &&
        other.hdrEnabled == hdrEnabled &&
        other.quality == quality &&
        other.useFrontCamera == useFrontCamera &&
        other.zoomLevel == zoomLevel &&
        other.compassEnabled == compassEnabled &&
        other.compassStyleCircular == compassStyleCircular &&
        other.compassShowDegrees == compassShowDegrees;
  }

  @override
  int get hashCode {
    return flashMode.hashCode ^
        hdrEnabled.hashCode ^
        quality.hashCode ^
        useFrontCamera.hashCode ^
        zoomLevel.hashCode ^
        compassEnabled.hashCode ^
        compassStyleCircular.hashCode ^
        compassShowDegrees.hashCode;
  }
}
