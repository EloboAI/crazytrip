import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../services/camera_service.dart';
import '../models/camera_settings.dart';
import '../services/filter_service.dart';
import '../models/image_filter.dart';
import '../widgets/filter_selector.dart';
import 'camera_settings_screen.dart';
import 'video_preview_screen.dart';

enum CameraMode { scan, reel }

class ARScannerScreen extends StatefulWidget {
  const ARScannerScreen({super.key});

  @override
  State<ARScannerScreen> createState() => _ARScannerScreenState();
}

class _ARScannerScreenState extends State<ARScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late CameraService _cameraService;
  late FilterService _filterService;
  CameraController? _cameraController;
  bool _isScanning = false;
  CameraMode _mode = CameraMode.scan;
  bool _isRecording = false;
  bool _isCameraInitialized = false;
  CameraSettings _cameraSettings = const CameraSettings();
  bool _showFilters = false;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  static const Duration _maxRecordingDuration = Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _filterService = FilterService();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameraService = CameraService();
      await _cameraService.initializeCameras();
      
      // Obtener el controlador del servicio
      _cameraController = _cameraService.controller;
      
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        // Escuchar cambios en la configuración
        _cameraService.settingsStream.listen((settings) {
          if (mounted) {
            setState(() {
              _cameraSettings = settings;
            });
          }
        });
        
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      } else {
        throw Exception('El controlador de cámara no se inicializó correctamente');
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al inicializar cámara: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    _recordingTimer?.cancel();
    _cameraController?.dispose();
    _cameraService.dispose();
    _filterService.dispose();
    super.dispose();
  }

  IconData _getFlashIcon() {
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
    
    CameraFlashMode newFlashMode;
    switch (_cameraSettings.flashMode) {
      case CameraFlashMode.off:
        newFlashMode = CameraFlashMode.always;
        break;
      case CameraFlashMode.always:
        newFlashMode = CameraFlashMode.auto;
        break;
      case CameraFlashMode.auto:
        newFlashMode = CameraFlashMode.off;
        break;
    }
    
    _cameraService.updateFlashMode(newFlashMode);
  }

  Future<void> _handleCapture() async {
    if (!_isCameraInitialized || _cameraController == null) return;

    try {
      if (_mode == CameraMode.scan) {
        // Tomar foto
        final XFile? photo = await _cameraService.takePicture();
        if (photo == null) return;
        
        // Aplicar filtro si no es el filtro "none"
        if (_filterService.currentFilter.type != FilterType.none) {
          final originalBytes = await photo.readAsBytes();
          final filteredBytes = await _filterService.applyFilterToBytes(
            originalBytes,
            _filterService.currentFilter,
          );
          
          // Guardar la imagen filtrada
          final filteredPhoto = XFile.fromData(filteredBytes);
          await _showImagePreview(filteredPhoto);
        } else {
          await _showImagePreview(photo);
        }
      } else {
        // Grabar video
        if (!_isRecording) {
          await _startVideoRecording();
        } else {
          await _stopVideoRecording();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _openCameraSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraSettingsScreen(
          cameraService: _cameraService,
        ),
      ),
    );
  }

  Future<void> _switchCamera() async {
    try {
      await _cameraService.switchCamera();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cambiar cámara: $e')),
        );
      }
    }
  }

  Future<void> _showImagePreview(XFile image) async {
    // TODO: Implementar pantalla de preview para fotos
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto capturada exitosamente')),
      );
    }
  }

  Future<void> _startVideoRecording() async {
    try {
      await _cameraService.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordingDuration = Duration.zero;
      });
      
      // Iniciar timer para actualizar el contador cada segundo
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        final duration = _cameraService.getRecordingDuration();
        setState(() {
          _recordingDuration = duration;
        });
        
        // Detener automáticamente a los 30 segundos
        if (duration >= _maxRecordingDuration) {
          timer.cancel();
          await _stopVideoRecording();
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al iniciar grabación: $e')),
        );
      }
    }
  }

  Future<void> _stopVideoRecording() async {
    try {
      _recordingTimer?.cancel();
      _recordingTimer = null;
      
      final XFile? video = await _cameraService.stopVideoRecording();
      if (video == null) return;
      
      setState(() {
        _isRecording = false;
        _recordingDuration = Duration.zero;
      });
      
      await _showVideoPreview(video);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al detener grabación: $e')),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _showVideoPreview(XFile video) async {
    if (!mounted) return;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreviewScreen(
          videoFile: video,
          onConfirm: () async {
            await _saveVideo(video);
          },
          onDiscard: () async {
            await _deleteVideo(video);
          },
          onRetake: () async {
            await _deleteVideo(video);
          },
        ),
      ),
    );
  }

  Future<void> _saveVideo(XFile video) async {
    try {
      // Obtener directorio de documentos de la app
      final directory = await getApplicationDocumentsDirectory();
      final videosDir = Directory('${directory.path}/videos');
      
      // Crear directorio si no existe
      if (!await videosDir.exists()) {
        await videosDir.create(recursive: true);
      }
      
      // Generar nombre único para el video
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'video_$timestamp.mp4';
      final savedPath = '${videosDir.path}/$fileName';
      
      // Leer el video y copiarlo al directorio de almacenamiento
      final videoBytes = await video.readAsBytes();
      final savedFile = File(savedPath);
      await savedFile.writeAsBytes(videoBytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Video guardado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteVideo(XFile video) async {
    try {
      final file = File(video.path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting video: $e');
    }
  }

  Widget _buildCameraPreview() {
    if (_isCameraInitialized && 
        _cameraController != null && 
        _cameraController!.value.isInitialized) {
      final needsFilterOverlay = _showFilters && 
          _mode == CameraMode.scan && 
          _filterService.currentFilter.type != FilterType.none;
      
      // Obtener el aspect ratio de la cámara
      final aspectRatio = _cameraController!.value.aspectRatio;
      
      Widget preview = SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: 1,
            height: 1 / aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
      );
      
      if (needsFilterOverlay) {
        preview = ColorFiltered(
          colorFilter: _previewColorFilterFor(_filterService.currentFilter),
          child: preview,
        );
      }
      
      return preview;
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [AppColors.primaryColor.withOpacity(0.2), Colors.black],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 120,
              color: Colors.white.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              _isCameraInitialized ? 'Cargando cámara...' : 'Inicializando cámara...',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ColorFilter _previewColorFilterFor(ImageFilter filter) {
    final t = filter.intensity.clamp(0.0, 1.0);
    List<double> identity() => [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ];

    List<double> blend(List<double> a, List<double> b, double alpha) {
      final out = List<double>.from(a);
      for (int i = 0; i < out.length; i++) {
        out[i] = a[i] * (1 - alpha) + b[i] * alpha;
      }
      return out;
    }

    List<double> sepia = [
      0.393, 0.769, 0.189, 0, 0,
      0.349, 0.686, 0.168, 0, 0,
      0.272, 0.534, 0.131, 0, 0,
      0,     0,     0,     1, 0,
    ];

    List<double> grayscale = [
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0.2126, 0.7152, 0.0722, 0, 0,
      0,      0,      0,      1, 0,
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
      return [
        a, d, g, 0, 0,
        b, e, h, 0, 0,
        c, f, i, 0, 0,
        0, 0, 0, 1, 0,
      ];
    }

    List<double> contrast(double c) {
      final o = 128.0 * (1 - c);
      return [
        c, 0, 0, 0, o,
        0, c, 0, 0, o,
        0, 0, c, 0, o,
        0, 0, 0, 1, 0,
      ];
    }

    List<double> temperature(double f, {bool warm = true}) {
      final rScale = warm ? 1 + 0.2 * f : 1 - 0.1 * f;
      final bScale = warm ? 1 - 0.1 * f : 1 + 0.2 * f;
      return [
        rScale, 0,      0,      0, 0,
        0,      1,      0,      0, 0,
        0,      0,      bScale, 0, 0,
        0,      0,      0,      1, 0,
      ];
    }

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
        // Slight sepia + slight desaturation
        final m1 = blend(identity(), sepia, t * 0.6);
        final m2 = saturation(1 - 0.3 * t);
        // Multiply matrices approximately by blending again
        matrix = blend(m1, m2, 0.5);
        break;
      case FilterType.vivid:
        matrix = saturation(1 + 0.5 * t);
        break;
      case FilterType.warm:
        matrix = temperature(t, warm: true);
        break;
      case FilterType.cool:
        matrix = temperature(t, warm: false);
        break;
      case FilterType.dramatic:
        final m1 = contrast(1 + 0.3 * t);
        final m2 = saturation(1 - 0.2 * t);
        matrix = blend(m1, m2, 0.5);
        break;
    }
    return ColorFilter.matrix(matrix);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera View
          _buildCameraPreview(),
          
          // Scanning Reticle
          Center(
            child: AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(250, 250),
                  painter: _ScanReticlePainter(
                    progress: _scanController.value,
                    isScanning: _isScanning,
                  ),
                );
              },
            ),
          ),

          
          // Top Controls with Glassmorphism
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        _GlassButton(
                          icon: Icons.close,
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                        _GlassButton(
                          icon: Icons.flip_camera_ios,
                          onTap: _switchCamera,
                        ),
                      // Mode Switcher
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.arOverlayBackground,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ModeButton(
                              icon: Icons.document_scanner,
                              label: 'SCAN',
                              isActive: _mode == CameraMode.scan,
                              onTap: () {
                                setState(() {
                                  _mode = CameraMode.scan;
                                  _isRecording = false;
                                });
                              },
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            _ModeButton(
                              icon: Icons.videocam,
                              label: 'REEL',
                              isActive: _mode == CameraMode.reel,
                              onTap: () {
                                setState(() {
                                  _mode = CameraMode.reel;
                                  _isScanning = false;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _GlassButton(
                            icon: Icons.settings,
                            onTap: _openCameraSettings,
                          ),
                          const SizedBox(width: AppSpacing.s),
                          _GlassButton(
                            icon: _getFlashIcon(),
                            onTap: () {
                              _toggleFlash();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Recording Timer (visible during recording)
                  if (_isRecording && _mode == CameraMode.reel)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      decoration: BoxDecoration(
                        color: _recordingDuration.inSeconds >= 25
                            ? Colors.red.withOpacity(0.9)
                            : AppColors.arOverlayBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                        border: Border.all(
                          color: _recordingDuration.inSeconds >= 25
                              ? Colors.red
                              : Colors.white.withOpacity(0.3),
                          width: _recordingDuration.inSeconds >= 25 ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Text(
                            _formatDuration(_recordingDuration),
                            style: AppTextStyles.titleMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFeatures: [const FontFeature.tabularFigures()],
                            ),
                          ),
                          if (_recordingDuration.inSeconds >= 25)
                            Padding(
                              padding: const EdgeInsets.only(left: AppSpacing.s),
                              child: Text(
                                '/ ${_formatDuration(_maxRecordingDuration)}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  else
                    // Mode Description
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.arOverlayBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMedium,
                        ),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _mode == CameraMode.scan
                                ? Icons.info_outline
                                : Icons.video_library,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _mode == CameraMode.scan
                                ? 'Apunta a objetos para identificarlos'
                                : 'Graba reels para compartir',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: [
                  // Scanning Status
                  if (_isScanning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.arOverlayBackground,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                        border: Border.all(
                          color: AppColors.primaryColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.s),
                          Text(
                            'Scanning for discoveries...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppSpacing.l),

                  // Filter Selector
                  if (_showFilters && _mode == CameraMode.scan) ...[
                    FilterSelector(
                      filterService: _filterService,
                      onFilterSelected: (filter) {
                        // El filtro ya se aplica automáticamente
                      },
                      showIntensitySlider: true,
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],

                  // Capture Button
                  GestureDetector(
                    onTap: () {
                      _handleCapture();
                    },
                    child: Container(
                      width: 80,
                      height: 80,
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
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape:
                              _mode == CameraMode.scan
                                  ? BoxShape.circle
                                  : (_isRecording
                                      ? BoxShape.rectangle
                                      : BoxShape.circle),
                          color:
                              _mode == CameraMode.scan
                                  ? (_isScanning
                                      ? AppColors.primaryColor
                                      : Colors.white)
                                  : (_isRecording
                                      ? Colors.red
                                      : Colors.red.withOpacity(0.8)),
                          borderRadius:
                              _mode == CameraMode.reel && _isRecording
                                  ? BorderRadius.circular(8)
                                  : null,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.s),

                  // Instructions
                  Text(
                    _mode == CameraMode.scan
                        ? (_isScanning
                            ? 'Identificando...'
                            : 'Toca para escanear')
                        : (_isRecording
                            ? 'Grabando reel...'
                            : 'Toca para grabar'),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.l),

                  // Quick Stats
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.arOverlayBackground,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMedium,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ARStat(
                          icon: Icons.explore,
                          value: '47',
                          label: 'Scanned',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _ARStat(
                          icon: Icons.stars,
                          value: '3.4k',
                          label: 'XP Earned',
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _ARStat(
                          icon: Icons.local_fire_department,
                          value: '9',
                          label: 'Streak',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.m),
                ],
              ),
            ),
          ),
        ],
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
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class _ARStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ARStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primaryColor, size: AppSpacing.iconSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class _ScanReticlePainter extends CustomPainter {
  final double progress;
  final bool isScanning;

  _ScanReticlePainter({required this.progress, required this.isScanning});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color =
              isScanning
                  ? AppColors.primaryColor.withOpacity(0.8)
                  : Colors.white.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw corner brackets
    final cornerLength = radius * 0.3;

    // Top-left
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx - radius + cornerLength, center.dy - radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy - radius),
      Offset(center.dx - radius, center.dy - radius + cornerLength),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx + radius - cornerLength, center.dy - radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy - radius),
      Offset(center.dx + radius, center.dy - radius + cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius),
      Offset(center.dx - radius + cornerLength, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, center.dy + radius),
      Offset(center.dx - radius, center.dy + radius - cornerLength),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(center.dx + radius, center.dy + radius),
      Offset(center.dx + radius - cornerLength, center.dy + radius),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, center.dy + radius),
      Offset(center.dx + radius, center.dy + radius - cornerLength),
      paint,
    );

    // Animated scanning line
    if (isScanning) {
      final scanY = center.dy - radius + (radius * 2 * progress);
      final scanPaint =
          Paint()
            ..color = AppColors.primaryColor.withOpacity(0.6)
            ..strokeWidth = 2;

      canvas.drawLine(
        Offset(center.dx - radius, scanY),
        Offset(center.dx + radius, scanY),
        scanPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ScanReticlePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isScanning != isScanning;
  }
}
