import 'dart:convert';

enum CameraFlashMode { off, auto, always }

enum CameraQuality { low, medium, high, max }

class CameraSettings {
  final CameraFlashMode flashMode;
  final bool hdrEnabled;
  final CameraQuality quality;
  final bool useFrontCamera;
  final double zoomLevel;

  const CameraSettings({
    this.flashMode = CameraFlashMode.auto,
    this.hdrEnabled = false,
    this.quality = CameraQuality.high,
    this.useFrontCamera = false,
    this.zoomLevel = 1.0,
  });

  CameraSettings copyWith({
    CameraFlashMode? flashMode,
    bool? hdrEnabled,
    CameraQuality? quality,
    bool? useFrontCamera,
    double? zoomLevel,
  }) {
    return CameraSettings(
      flashMode: flashMode ?? this.flashMode,
      hdrEnabled: hdrEnabled ?? this.hdrEnabled,
      quality: quality ?? this.quality,
      useFrontCamera: useFrontCamera ?? this.useFrontCamera,
      zoomLevel: zoomLevel ?? this.zoomLevel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'flashMode': flashMode.name,
      'hdrEnabled': hdrEnabled,
      'quality': quality.name,
      'useFrontCamera': useFrontCamera,
      'zoomLevel': zoomLevel,
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
        other.zoomLevel == zoomLevel;
  }

  @override
  int get hashCode {
    return flashMode.hashCode ^
        hdrEnabled.hashCode ^
        quality.hashCode ^
        useFrontCamera.hashCode ^
        zoomLevel.hashCode;
  }
}
