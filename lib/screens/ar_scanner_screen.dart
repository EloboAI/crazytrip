import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';
import '../services/geocoding_service.dart';
import '../services/orientation_service.dart';
import '../models/camera_settings.dart';
import '../services/filter_service.dart';
import '../models/image_filter.dart';
import '../widgets/filter_selector.dart';
import 'camera_settings_screen.dart';
import 'video_preview_screen.dart';
import '../services/vision_service.dart';

enum CameraMode { scan, reel }

class ARScannerScreen extends StatefulWidget {
  const ARScannerScreen({super.key});
  @override
  State<ARScannerScreen> createState() => _ARScannerScreenState();
}

class _ARScannerScreenState extends State<ARScannerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _scanAnim;
  late CameraService _cameraService;
  late FilterService _filterService;
  final VisionService _visionService = VisionService();
  final OrientationService _orientationService = OrientationService();
  CameraController? _cameraController;
  CameraMode _mode = CameraMode.scan;
  bool _isCameraInitialized = false;
  bool _isRecording = false;
  bool _showFilters = false;
  bool _isScanning = false;
  bool _showCompassDebug = true; // Mostrar indicador de brújula
  CameraOrientation? _currentOrientation;
  StreamSubscription<CameraOrientation>? _orientationSubscription;
  CameraSettings _cameraSettings = const CameraSettings();
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  static const Duration _maxRecordingDuration = Duration(seconds: 30);
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _baseZoom = 1.0;
  double _currentZoom = 1.0;
  int _pointers = 0; // contar dedos para pinch
  void initState() {
    super.initState();
    _scanAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _filterService = FilterService();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _startOrientationStream();
  }

  void _startOrientationStream() {
    _orientationSubscription = _orientationService.getOrientationStream().listen(
      (orientation) {
        if (mounted) {
          setState(() {
            _currentOrientation = orientation;
          });
        }
      },
      onError: (error) {
        debugPrint('Orientation stream error: $error');
      },
    );
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraService = CameraService();
      // Activar audio solo en modo REEL (grabación video)
      await _cameraService.initializeCameras(
        enableAudio: _mode == CameraMode.reel,
      );
      _cameraController = _cameraService.controller;
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized) {
        throw Exception('Controlador de cámara no inicializado');
      }
      // Valores de zoom soportados
      _minZoom = await _cameraController!.getMinZoomLevel();
      _maxZoom = await _cameraController!.getMaxZoomLevel();
      _currentZoom = _cameraSettings.zoomLevel;
      _cameraService.settingsStream.listen((s) {
        if (mounted) setState(() => _cameraSettings = s);
      });
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('Init cam error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cámara: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanAnim.dispose();
    _recordingTimer?.cancel();
    _orientationSubscription?.cancel();
    _orientationService.dispose();
    _cameraController?.dispose();
    _cameraService.dispose();
    _filterService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final controller = _cameraController;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Si está grabando, detener grabación antes de pausar
      if (_isRecording && mounted) {
        _recordingTimer?.cancel();
        _recordingTimer = null;
        _cameraService.stopVideoRecording().catchError((_) => null);
      }
      // App va a background, marcar como no inicializada y pausar cámara
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _isRecording = false;
          _recordingDuration = Duration.zero;
        });
      }
      if (controller != null && controller.value.isInitialized) {
        controller.dispose();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App regresa a foreground, reiniciar cámara
      if (mounted) {
        _initializeCamera();
      }
    }
  }

  IconData _flashIcon() {
    switch (_cameraSettings.flashMode) {
      case CameraFlashMode.auto:
        return Icons.flash_auto;
      case CameraFlashMode.always:
        return Icons.flash_on;
      case CameraFlashMode.off:
        return Icons.flash_off;
    }
  }

  void _toggleFlash() {
    if (!_isCameraInitialized) return;
    CameraFlashMode next;
    switch (_cameraSettings.flashMode) {
      case CameraFlashMode.off:
        next = CameraFlashMode.always;
        break;
      case CameraFlashMode.always:
        next = CameraFlashMode.auto;
        break;
      case CameraFlashMode.auto:
        next = CameraFlashMode.off;
        break;
    }
    _cameraService.updateFlashMode(next);
  }

  Future<void> _handleCapture() async {
    if (!_isCameraInitialized || _cameraController == null) return;
    try {
      if (_mode == CameraMode.scan) {
        setState(() => _isScanning = true);
        final photo = await _cameraService.takePicture();
        if (photo == null) return;
        if (_filterService.currentFilter.type != FilterType.none) {
          final bytes = await photo.readAsBytes();
          final filtered = await _filterService.applyFilterToBytes(
            bytes,
            _filterService.currentFilter,
          );
          await _analyzePhoto(XFile.fromData(filtered));
        } else {
          await _analyzePhoto(photo);
        }
        if (mounted) setState(() => _isScanning = false);
      } else {
        if (!_isRecording) {
          await _startVideoRecording();
        } else {
          await _stopVideoRecording();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _openCameraSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => CameraSettingsScreen(cameraService: _cameraService),
      ),
    );
  }

  Future<void> _switchCamera() async {
    if (!_isCameraInitialized) return;
    try {
      setState(() => _isCameraInitialized = false);
      await _cameraService.switchCamera();
      await _cameraService.setEnableAudio(_mode == CameraMode.reel);
      _cameraController = _cameraService.controller;
      if (mounted &&
          _cameraController != null &&
          _cameraController!.value.isInitialized) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      if (mounted) {
        _cameraController = _cameraService.controller;
        final ok = _cameraController?.value.isInitialized ?? false;
        setState(() => _isCameraInitialized = ok);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cambio cámara: $e')));
      }
    }
  }

  Future<void> _changeCameraMode(CameraMode newMode, bool enableAudio) async {
    if (_mode == newMode) return;
    setState(() {
      _mode = newMode;
      if (newMode == CameraMode.scan) _isRecording = false;
      if (newMode == CameraMode.reel) _isScanning = false;
      _isCameraInitialized = false;
    });
    Future.microtask(() async {
      try {
        await _cameraService.setEnableAudio(enableAudio);
        _cameraController = _cameraService.controller;
        if (mounted && _cameraController?.value.isInitialized == true) {
          setState(() => _isCameraInitialized = true);
        }
      } catch (e) {
        debugPrint('Error setting audio: $e');
        if (mounted) setState(() => _isCameraInitialized = true);
      }
    });
  }

  // Eliminado preview simple; ahora se analiza directamente la foto.

  Future<void> _analyzePhoto(XFile image) async {
    try {
      // Convertir XFile a File (si proviene de bytes, crear temporal)
      File file;
      if (image.path.isEmpty) {
        final dir = await getTemporaryDirectory();
        final tmpPath =
            '${dir.path}/scan_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final bytes = await image.readAsBytes();
        file = File(tmpPath);
        await file.writeAsBytes(bytes, flush: true);
      } else {
        file = File(image.path);
      }

      // Obtener ubicación actual
      final location = await LocationService.getCurrentLocation();

      // Obtener información de ubicación (país, provincia, ciudad)
      LocationInfo? locationInfo;
      if (location != null) {
        locationInfo = await GeocodingService().getLocationInfo(location);
      }

      // Obtener orientación de la cámara (hacia dónde apunta)
      final orientationService = OrientationService();
      final orientation = await orientationService.getCurrentOrientation();

      if (orientation != null) {
        debugPrint('🧭 Camera orientation: ${orientation.description}');
      } else {
        debugPrint('⚠️ Could not get camera orientation');
      }

      final result = await _visionService.detectBestMatch(
        file,
        location: location,
        locationInfo: locationInfo,
        orientation: orientation,
      );
      if (!mounted) return;

      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo identificar el objeto')),
        );
        return;
      }

      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black87,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (c) {
          final icon = _getCategoryIcon(result.category);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Vision AI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(c),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 32),
                  // Imagen capturada
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      result.imageFile,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              result.type,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRarityColor(result.rarity),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    result.rarity.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    result.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  // Información de ubicación detallada
                  if (result.locationInfo != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Ubicación',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildLocationItem(
                      Icons.public,
                      'País',
                      result.locationInfo!.country,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationItem(
                      Icons.map,
                      'Provincia',
                      result.locationInfo!.state,
                    ),
                    const SizedBox(height: 8),
                    _buildLocationItem(
                      Icons.location_city,
                      'Ciudad',
                      result.locationInfo!.city,
                    ),
                    if (result.locationInfo!.placeName != null) ...[
                      const SizedBox(height: 8),
                      _buildLocationItem(
                        Icons.place,
                        'Lugar',
                        result.locationInfo!.placeName!,
                      ),
                    ],
                    const SizedBox(height: 12),
                  ],

                  // Orientación de la cámara
                  if (result.orientation != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.explore,
                            color: Colors.lightBlue,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Orientación',
                                  style: TextStyle(
                                    color: Colors.lightBlue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${result.orientation!.cardinalDirection} (${result.orientation!.bearing.toStringAsFixed(0)}°)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Coordenadas GPS
                  if (result.location != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.my_location,
                            color: Colors.white70,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${result.location!.latitude.toStringAsFixed(6)}, ${result.location!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error análisis: $e')));
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      await _cameraService.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (
        timer,
      ) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final d = _cameraService.getRecordingDuration();
        setState(() => _recordingDuration = d);
        if (d >= _maxRecordingDuration) {
          timer.cancel();
          await _stopVideoRecording();
        }
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error inicio grabación: $e')));
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      final video = await _cameraService.stopVideoRecording();
      if (video == null) return;
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      await _showVideoPreview(video);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error detener grabación: $e')));
    }
  }

  String _formatDuration(Duration d) {
    String td(int n) => n.toString().padLeft(2, '0');
    return '${td(d.inMinutes.remainder(60))}:${td(d.inSeconds.remainder(60))}';
  }

  Future<void> _showVideoPreview(XFile video) async {
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (c) => VideoPreviewScreen(
              videoFile: video,
              onConfirm: () async => _saveVideo(video),
              onDiscard: () async => _deleteVideo(video),
              onRetake: () async => _deleteVideo(video),
            ),
      ),
    );
  }

  Future<void> _saveVideo(XFile video) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory('${dir.path}/videos');
      if (!await folder.exists()) await folder.create(recursive: true);
      final ts = DateTime.now().millisecondsSinceEpoch;
      final path = '${folder.path}/video_$ts.mp4';
      final bytes = await video.readAsBytes();
      await File(path).writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Video guardado')));
      }
    } catch (e) {
      debugPrint('Save video error: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error guardar video: $e'),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  Future<void> _deleteVideo(XFile video) async {
    try {
      final f = File(video.path);
      if (await f.exists()) await f.delete();
    } catch (e) {
      debugPrint('Delete video error: $e');
    }
  }

  Widget _buildPreview() {
    final controller = _cameraService.controller ?? _cameraController;
    if (!_isCameraInitialized ||
        controller == null ||
        !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    // Calcular aspect ratio correcto basado en previewSize y orientación.
    final orientation = MediaQuery.of(context).orientation;
    final size = controller.value.previewSize;
    double displayAspect;
    if (size != null) {
      final w = size.width;
      final h = size.height;
      if (orientation == Orientation.portrait) {
        // Si los datos están en landscape (w>h) invertimos.
        displayAspect = w > h ? h / w : w / h;
      } else {
        // Landscape: usar width/height directamente.
        displayAspect = w / h;
      }
    } else {
      // Fallback: invertir el aspectRatio reportado (históricamente height/width)
      final raw = controller.value.aspectRatio;
      displayAspect = 1 / raw;
    }

    final screenSize = MediaQuery.of(context).size;
    final screenRatio = screenSize.width / screenSize.height;
    // Factor de escala para cubrir pantalla sin distorsión.
    double scale = displayAspect / screenRatio;
    if (scale < 1) scale = 1 / scale;

    Widget preview = ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: AspectRatio(
            aspectRatio: displayAspect,
            child: CameraPreview(controller),
          ),
        ),
      ),
    );

    final needsFilter =
        _showFilters &&
        _mode == CameraMode.scan &&
        _filterService.currentFilter.type != FilterType.none;
    if (needsFilter) {
      preview = ColorFiltered(
        colorFilter: _previewColorFilterFor(_filterService.currentFilter),
        child: preview,
      );
    }

    // Gestos para zoom: contamos dedos pero exigimos >=2; Listener cubre toda el área
    return Listener(
      onPointerDown: (_) => _pointers = (_pointers + 1).clamp(0, 10),
      onPointerUp: (_) => _pointers = (_pointers - 1).clamp(0, 10),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: (_) => _baseZoom = _currentZoom,
        onScaleUpdate: (details) async {
          if (_pointers < 2) return; // requerir al menos dos dedos
          final desired = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);
          if ((desired - _currentZoom).abs() >= 0.01) {
            _currentZoom = desired;
            try {
              await _cameraService.updateZoomLevel(_currentZoom);
              if (mounted) setState(() {}); // reflejar cambios si es necesario
            } catch (_) {}
          }
        },
        child: preview,
      ),
    );
  }

  ColorFilter _previewColorFilterFor(ImageFilter filter) {
    final t = filter.intensity.clamp(0.0, 1.0);
    List<double> identity() => [
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
    List<double> blend(List<double> a, List<double> b, double alpha) {
      final o = List<double>.from(a);
      for (int i = 0; i < o.length; i++) {
        o[i] = a[i] * (1 - alpha) + b[i] * alpha;
      }
      return o;
    }

    List<double> sepia = [
      0.393,
      0.769,
      0.189,
      0,
      0,
      0.349,
      0.686,
      0.168,
      0,
      0,
      0.272,
      0.534,
      0.131,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
    List<double> grayscale = [
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0.2126,
      0.7152,
      0.0722,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
    List<double> saturation(double s) {
      const rw = 0.2126, gw = 0.7152, bw = 0.0722;
      final a = (1 - s) * rw + s;
      final b = (1 - s) * rw;
      final c = (1 - s) * rw;
      final d = (1 - s) * gw;
      final e = (1 - s) * gw + s;
      final f = (1 - s) * gw;
      final g = (1 - s) * bw;
      final h = (1 - s) * bw;
      final i = (1 - s) * bw + s;
      return [a, d, g, 0, 0, b, e, h, 0, 0, c, f, i, 0, 0, 0, 0, 0, 1, 0];
    }

    List<double> contrast(double c) {
      final o = 128.0 * (1 - c);
      return [c, 0, 0, 0, o, 0, c, 0, 0, o, 0, 0, c, 0, o, 0, 0, 0, 1, 0];
    }

    List<double> temperature(double f, {bool warm = true}) {
      final r = warm ? 1 + 0.2 * f : 1 - 0.1 * f;
      final b = warm ? 1 - 0.1 * f : 1 + 0.2 * f;
      return [r, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, b, 0, 0, 0, 0, 0, 1, 0];
    }

    List<double> vivid = saturation(1 + 0.5 * t);
    List<double> cool = temperature(
      t,
      warm: false,
    ); // reuse temperature if needed
    List<double> warm = temperature(t, warm: true);
    List<double> dramatic = blend(
      contrast(1 + 0.3 * t),
      saturation(1 - 0.2 * t),
      0.5,
    );
    List<double> matrix;
    switch (filter.type) {
      case FilterType.none:
        matrix = identity();
        break;
      case FilterType.sepia:
        matrix = blend(identity(), sepia, t);
        break;
      case FilterType.blackAndWhite:
        matrix = blend(identity(), grayscale, t);
        break;
      case FilterType.vintage:
        matrix = blend(
          blend(identity(), sepia, t * 0.6),
          saturation(1 - 0.3 * t),
          0.5,
        );
        break;
      case FilterType.vivid:
        matrix = vivid;
        break;
      case FilterType.warm:
        matrix = warm;
        break;
      case FilterType.cool:
        matrix = cool;
        break;
      case FilterType.dramatic:
        matrix = dramatic;
        break;
    }
    return ColorFilter.matrix(matrix);
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return const Color(0xFFFFD700); // Gold
      case 'epic':
        return const Color(0xFF9C27B0); // Purple
      case 'rare':
        return const Color(0xFF2196F3); // Blue
      case 'uncommon':
        return const Color(0xFF4CAF50); // Green
      case 'common':
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'landmark':
        return Icons.landscape;
      case 'animal':
        return Icons.pets;
      case 'food':
        return Icons.restaurant;
      case 'building':
        return Icons.business;
      case 'nature':
        return Icons.nature;
      case 'product':
        return Icons.shopping_bag;
      case 'vehicle':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  Widget _buildLocationItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _buildPreview()),
            if (_mode == CameraMode.scan)
              IgnorePointer(
                child: Center(
                  child: AnimatedBuilder(
                    animation: _scanAnim,
                    builder:
                        (_, __) => CustomPaint(
                          size: const Size(220, 220),
                          painter: _ScanReticlePainter(
                            progress: _scanAnim.value,
                            isScanning: _isScanning,
                          ),
                        ),
                  ),
                ),
              ),
            // Indicador de brújula en tiempo real (DEBUG)
            if (_showCompassDebug && _currentOrientation != null)
              Positioned(
                bottom: 120,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.explore,
                            color: Colors.lightBlue,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Brújula',
                            style: TextStyle(
                              color: Colors.lightBlue.shade200,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currentOrientation!.bearing.toStringAsFixed(0)}° ${_currentOrientation!.cardinalDirection}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (_currentOrientation!.accuracy != null)
                        Text(
                          'Precisión: ${_currentOrientation!.accuracy!.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GlassButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      _GlassButton(
                        icon: Icons.flip_camera_ios,
                        onTap: _switchCamera,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      _GlassButton(icon: _flashIcon(), onTap: _toggleFlash),
                      const SizedBox(width: AppSpacing.s),
                      _GlassButton(
                        icon: Icons.settings,
                        onTap: _openCameraSettings,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 70,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ModeButton(
                    icon: Icons.document_scanner,
                    label: 'SCAN',
                    isActive: _mode == CameraMode.scan,
                    isDisabled: _isRecording,
                    onTap: () => _changeCameraMode(CameraMode.scan, false),
                  ),
                  const SizedBox(width: AppSpacing.s),
                  _ModeButton(
                    icon: Icons.videocam,
                    label: 'REEL',
                    isActive: _mode == CameraMode.reel,
                    isDisabled: _isScanning,
                    onTap: () => _changeCameraMode(CameraMode.reel, true),
                  ),
                ],
              ),
            ),
            if (_mode == CameraMode.scan && _showFilters)
              Positioned(
                bottom: 170,
                left: 0,
                right: 0,
                child: FilterSelector(
                  filterService: _filterService,
                  onFilterSelected: (_) {},
                  showIntensitySlider: true,
                ),
              ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isRecording && _mode == CameraMode.reel)
                    _RecordingBanner(
                      duration: _recordingDuration,
                      format: _formatDuration,
                      maxDuration: _maxRecordingDuration,
                    ),
                  const SizedBox(height: AppSpacing.m),
                  GestureDetector(
                    onTap: _handleCapture,
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              _mode == CameraMode.scan
                                  ? Colors.white
                                  : Colors.red,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isRecording ? 32 : 54,
                          height: _isRecording ? 32 : 54,
                          decoration: BoxDecoration(
                            color:
                                _mode == CameraMode.scan
                                    ? (_isScanning
                                        ? AppColors.primaryColor
                                        : Colors.white)
                                    : (_isRecording
                                        ? Colors.red
                                        : Colors.red.withOpacity(0.8)),
                            borderRadius:
                                _isRecording && _mode == CameraMode.reel
                                    ? BorderRadius.circular(8)
                                    : BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    _mode == CameraMode.scan
                        ? (_isScanning ? 'Escaneando...' : 'Toca para escanear')
                        : (_isRecording ? 'Grabando...' : 'Toca para grabar'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSpacing.minTouchTarget,
        height: AppSpacing.minTouchTarget,
        decoration: BoxDecoration(
          color: AppColors.arOverlayBackground,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Icon(icon, color: Colors.white, size: AppSpacing.iconMedium),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDisabled;
  final VoidCallback onTap;
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    this.isDisabled = false,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: isDisabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color:
                isActive
                    ? AppColors.primaryColor.withOpacity(0.8)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecordingBanner extends StatelessWidget {
  final Duration duration;
  final String Function(Duration) format;
  final Duration maxDuration;
  const _RecordingBanner({
    required this.duration,
    required this.format,
    required this.maxDuration,
  });
  @override
  Widget build(BuildContext context) {
    final warn = duration.inSeconds >= 25;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color:
            warn ? Colors.red.withOpacity(0.85) : AppColors.arOverlayBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        border: Border.all(
          color: warn ? Colors.red : Colors.white.withOpacity(0.3),
          width: warn ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Text(
            format(duration),
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (warn)
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.s),
              child: Text(
                '/ ${format(maxDuration)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanReticlePainter extends CustomPainter {
  final double progress;
  final bool isScanning;
  _ScanReticlePainter({required this.progress, required this.isScanning});
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final l = r * 0.28;
    final base =
        Paint()
          ..color = (isScanning ? AppColors.primaryColor : Colors.white)
              .withOpacity(isScanning ? 0.85 : 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
    void corner(double sx, double sy, double dx, double dy) {
      canvas.drawLine(Offset(sx, sy), Offset(dx, sy), base);
      canvas.drawLine(Offset(sx, sy), Offset(sx, dy), base);
    }

    corner(c.dx - r, c.dy - r, c.dx - r + l, c.dy - r + l);
    corner(c.dx + r, c.dy - r, c.dx + r - l, c.dy - r + l);
    corner(c.dx - r, c.dy + r, c.dx - r + l, c.dy + r - l);
    corner(c.dx + r, c.dy + r, c.dx + r - l, c.dy + r - l);
    if (isScanning) {
      final y = c.dy - r + (r * 2 * progress);
      canvas.drawLine(
        Offset(c.dx - r, y),
        Offset(c.dx + r, y),
        Paint()
          ..color = AppColors.primaryColor.withOpacity(0.6)
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanReticlePainter o) =>
      o.progress != progress || o.isScanning != isScanning;
}
