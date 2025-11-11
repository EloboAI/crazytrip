import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/camera_settings.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  CameraSettings _settings = const CameraSettings();
  DateTime? _recordingStartTime;
  static const String _settingsKey = 'camera_settings';
  bool _initializing = false; // Previene inicializaciones concurrentes
  bool _enableAudio = true; // control de audio según modo actual

  CameraController? get controller => _controller;
  CameraSettings get settings => _settings;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  // Stream para notificar cambios en la configuración
  final _settingsController = StreamController<CameraSettings>.broadcast();
  Stream<CameraSettings> get settingsStream => _settingsController.stream;

  /// Inicializa las cámaras disponibles (alias para initialize)
  Future<void> initializeCameras({bool enableAudio = true}) async {
    _enableAudio = enableAudio;
    return initialize(enableAudio: enableAudio);
  }

  /// Carga las configuraciones guardadas
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString(_settingsKey);

      if (settingsJson != null) {
        _settings = CameraSettings.fromJson(settingsJson);
      }
    } catch (e) {
      // Si hay error al cargar, usar configuraciones por defecto
      _settings = const CameraSettings();
    }
  }

  /// Guarda las configuraciones actuales
  Future<void> saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_settingsKey, _settings.toJson());
    } catch (e) {
      // Error al guardar, pero no lanzamos excepción para no interrumpir el flujo
      throw Exception('Error al guardar configuración: $e');
    }
  }

  /// Inicializa las cámaras disponibles
  Future<void> initialize({bool enableAudio = true}) async {
    try {
      // Cargar configuraciones guardadas primero
      await loadSettings();

      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No hay cámaras disponibles');
      }

      // Encontrar el índice correcto de la cámara
      int cameraIndex = 0;
      if (_settings.useFrontCamera) {
        // Buscar cámara frontal
        final frontCameraIndex = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        if (frontCameraIndex != -1) {
          cameraIndex = frontCameraIndex;
        } else if (_cameras.length > 1) {
          // Si no hay frontal pero hay más de una, usar la segunda
          cameraIndex = 1;
        }
      } else {
        // Buscar cámara trasera
        final backCameraIndex = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        if (backCameraIndex != -1) {
          cameraIndex = backCameraIndex;
        } else {
          // Si no hay trasera, usar la primera disponible
          cameraIndex = 0;
        }
      }

      await initializeCamera(
        cameraIndex: cameraIndex,
        enableAudio: enableAudio,
      );
    } catch (e) {
      throw Exception('Error al inicializar cámara: $e');
    }
  }

  /// Inicializa una cámara específica
  Future<void> initializeCamera({
    int cameraIndex = 0,
    bool? enableAudio,
  }) async {
    if (_initializing) return; // Evitar doble init concurrente
    _initializing = true;
    try {
      await _controller?.dispose();
      _controller = null;

      if (cameraIndex >= _cameras.length) {
        throw Exception('Índice de cámara inválido');
      }

      final camera = _cameras[cameraIndex];
      // Determinar si audio debe estar activo (scan vs reel)
      if (enableAudio != null) {
        _enableAudio = enableAudio;
      }

      final preset = _getResolutionPreset(_settings.quality);
      CameraController? created;
      // Intento con preset elegido; si falla, degradar secuencialmente
      // Priorizar presets altos para mejor calidad
      final fallbackPresets =
          <ResolutionPreset>[
            ResolutionPreset.ultraHigh,
            ResolutionPreset.veryHigh,
            ResolutionPreset.max,
            preset,
            ResolutionPreset.high,
            ResolutionPreset.medium,
            ResolutionPreset.low,
          ].toSet().toList(); // Eliminar duplicados
      for (final p in fallbackPresets) {
        try {
          created = CameraController(camera, p, enableAudio: _enableAudio);
          await created.initialize();
          // Éxito
          break;
        } catch (_) {
          await created?.dispose();
          created = null;
          continue; // probar siguiente
        }
      }
      if (created == null) {
        throw Exception('No se pudo inicializar cámara con ningún preset');
      }
      _controller = created;

      // Intentar aplicar el flash actual; si falla, degradar a off
      if (_settings.flashMode != CameraFlashMode.off) {
        try {
          await _controller!.setFlashMode(_getFlashMode(_settings.flashMode));
        } catch (_) {
          _settings = _settings.copyWith(flashMode: CameraFlashMode.off);
        }
      }

      // Establecer el zoom a 1.0 y aplicar ajustes iniciales
      final settingsWithNoZoom = _settings.copyWith(zoomLevel: 1.0);
      await applySettings(settingsWithNoZoom);
    } catch (e) {
      throw Exception('Error al inicializar cámara $cameraIndex: $e');
    } finally {
      _initializing = false;
    }
  }

  /// Aplica la configuración a la cámara
  Future<void> applySettings(CameraSettings newSettings) async {
    if (!isInitialized) return;

    try {
      _settings = newSettings;

      // Configurar flash
      await _controller!.setFlashMode(_getFlashMode(newSettings.flashMode));

      // Configurar zoom
      await _controller!.setZoomLevel(newSettings.zoomLevel);

      // Guardar configuraciones automáticamente
      await saveSettings();

      // Notificar cambios solo si el stream no está cerrado
      if (!_settingsController.isClosed) {
        _settingsController.add(_settings);
      }
    } catch (e) {
      throw Exception('Error al aplicar configuración: $e');
    }
  }

  /// Actualiza la configuración parcialmente
  Future<void> updateSettings({
    CameraFlashMode? flashMode,
    bool? hdrEnabled,
    CameraQuality? quality,
    bool? useFrontCamera,
    double? zoomLevel,
  }) async {
    final newSettings = _settings.copyWith(
      flashMode: flashMode,
      hdrEnabled: hdrEnabled,
      quality: quality,
      useFrontCamera: useFrontCamera,
      zoomLevel: zoomLevel,
    );

    // Si cambia la calidad o la cámara, reinicializar
    if (quality != _settings.quality ||
        useFrontCamera != _settings.useFrontCamera) {
      // Encontrar el índice correcto de la cámara
      int cameraIndex = 0;
      if (newSettings.useFrontCamera) {
        // Buscar cámara frontal
        final frontCameraIndex = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
        );
        if (frontCameraIndex != -1) {
          cameraIndex = frontCameraIndex;
        } else if (_cameras.length > 1) {
          // Si no hay frontal pero hay más de una, usar la segunda
          cameraIndex = 1;
        }
      } else {
        // Buscar cámara trasera
        final backCameraIndex = _cameras.indexWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
        );
        if (backCameraIndex != -1) {
          cameraIndex = backCameraIndex;
        } else {
          // Si no hay trasera, usar la primera disponible
          cameraIndex = 0;
        }
      }

      _settings = newSettings;
      await initializeCamera(
        cameraIndex: cameraIndex,
        enableAudio: _enableAudio,
      );
      // Guardar configuraciones después de reinicializar
      await saveSettings();
      if (!_settingsController.isClosed) {
        _settingsController.add(_settings);
      }
    } else {
      await applySettings(newSettings);
    }
  }

  /// Toma una foto
  Future<XFile?> takePicture() async {
    if (!isInitialized || _controller!.value.isTakingPicture) {
      return null;
    }

    try {
      final XFile image = await _controller!.takePicture();
      return image;
    } catch (e) {
      throw Exception('Error al tomar foto: $e');
    }
  }

  /// Inicia la grabación de video
  Future<void> startVideoRecording() async {
    if (!isInitialized || _controller!.value.isRecordingVideo) {
      return;
    }

    try {
      await _controller!.startVideoRecording();
      _recordingStartTime = DateTime.now();
    } catch (e) {
      throw Exception('Error al iniciar grabación: $e');
    }
  }

  /// Detiene la grabación de video
  Future<XFile?> stopVideoRecording() async {
    if (!isInitialized || !_controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      final XFile video = await _controller!.stopVideoRecording();
      _recordingStartTime = null;
      return video;
    } catch (e) {
      throw Exception('Error al detener grabación: $e');
    }
  }

  /// Convierte CameraQuality a ResolutionPreset
  ResolutionPreset _getResolutionPreset(CameraQuality quality) {
    switch (quality) {
      case CameraQuality.low:
        return ResolutionPreset.medium; // Mejorar mínimo
      case CameraQuality.medium:
        return ResolutionPreset.high;
      case CameraQuality.high:
        return ResolutionPreset.veryHigh;
      case CameraQuality.max:
        // Buscar el preset más alto disponible
        return ResolutionPreset.ultraHigh;
    }
  }

  /// Permite cambiar si el audio está habilitado sin modificar otros ajustes.
  Future<void> setEnableAudio(bool value) async {
    if (_enableAudio == value && isInitialized) return;
    if (_initializing) {
      // Evitar reinit concurrente durante cambio de audio
      debugPrint('Skipping audio change: camera initializing');
      return;
    }

    // Guardar zoom actual antes de reinicializar
    final currentZoom = _settings.zoomLevel;
    _enableAudio = value;

    // Reinicializar cámara actual para aplicar cambio de audio
    // Obtener índice actual de la cámara según configuración
    int cameraIndex = 0;
    if (_settings.useFrontCamera) {
      final frontIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (frontIndex != -1) cameraIndex = frontIndex;
    } else {
      final backIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (backIndex != -1) cameraIndex = backIndex;
    }
    try {
      await initializeCamera(
        cameraIndex: cameraIndex,
        enableAudio: _enableAudio,
      );
      // Restaurar zoom
      if (currentZoom != 1.0 && isInitialized) {
        await _controller!.setZoomLevel(currentZoom);
      }
    } catch (e) {
      debugPrint('Error reinitializing camera for audio change: $e');
      rethrow;
    }
  }

  /// Convierte CameraFlashMode a FlashMode
  FlashMode _getFlashMode(CameraFlashMode flashMode) {
    switch (flashMode) {
      case CameraFlashMode.off:
        return FlashMode.off;
      case CameraFlashMode.auto:
        return FlashMode.auto;
      case CameraFlashMode.always:
        // Usamos torch para mantener luz encendida en preview; FlashMode.always solo aplica al disparo
        return FlashMode.torch;
    }
  }

  /// Actualiza el modo de flash
  Future<void> updateFlashMode(CameraFlashMode flashMode) async {
    if (!isInitialized) return;

    try {
      await _controller!.setFlashMode(_getFlashMode(flashMode));
      _settings = _settings.copyWith(flashMode: flashMode);
      await saveSettings();
      if (!_settingsController.isClosed) {
        _settingsController.add(_settings);
      }
    } catch (e) {
      // Si falla y no era off, degradar a off
      if (flashMode != CameraFlashMode.off) {
        _settings = _settings.copyWith(flashMode: CameraFlashMode.off);
        if (!_settingsController.isClosed) {
          _settingsController.add(_settings);
        }
      }
      throw Exception('Error al actualizar flash: $e');
    }
  }

  /// Actualiza el nivel de zoom
  Future<void> updateZoomLevel(double zoomLevel) async {
    if (!isInitialized) return;

    try {
      await _controller!.setZoomLevel(zoomLevel);
      _settings = _settings.copyWith(zoomLevel: zoomLevel);
      await saveSettings();
      if (!_settingsController.isClosed) {
        _settingsController.add(_settings);
      }
    } catch (e) {
      throw Exception('Error al actualizar zoom: $e');
    }
  }

  /// Cambia entre cámara frontal y trasera
  Future<void> switchCamera() async {
    if (_cameras.length < 2) return;

    // Evitar cambio mientras se graba o toma foto
    if (_controller?.value.isRecordingVideo == true ||
        _controller?.value.isTakingPicture == true) {
      throw Exception('No se puede cambiar cámara durante captura/grabación');
    }

    // Encontrar el índice de la cámara opuesta
    final oppositeLensDirection =
        _settings.useFrontCamera
            ? CameraLensDirection.back
            : CameraLensDirection.front;

    final oppositeCameraIndex = _cameras.indexWhere(
      (camera) => camera.lensDirection == oppositeLensDirection,
    );

    if (oppositeCameraIndex != -1) {
      await updateSettings(useFrontCamera: !_settings.useFrontCamera);
    }
  }

  /// Obtiene el tiempo de grabación actual
  Duration getRecordingDuration() {
    if (_recordingStartTime == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(_recordingStartTime!);
  }

  /// Libera recursos
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
    _recordingStartTime = null;
    await _settingsController.close();
  }
}
