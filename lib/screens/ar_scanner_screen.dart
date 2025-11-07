import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum CameraMode { scan, reel }

class ARScannerScreen extends StatefulWidget {
  const ARScannerScreen({super.key});

  @override
  State<ARScannerScreen> createState() => _ARScannerScreenState();
}

class _ARScannerScreenState extends State<ARScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;
  CameraMode _mode = CameraMode.scan;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera View
          Container(
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
                    'AR Camera View',
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

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
                      // Mode Switcher
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.arOverlayBackground,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
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
                      _GlassButton(
                        icon: Icons.flash_off,
                        onTap: () {
                          // Toggle flash
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Mode Description
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.arOverlayBackground,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _mode == CameraMode.scan ? Icons.info_outline : Icons.video_library,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _mode == CameraMode.scan
                              ? 'Apunta a objetos para identificarlos'
                              : 'Graba reels para compartir',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
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

                  // Capture Button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_mode == CameraMode.scan) {
                          _isScanning = !_isScanning;
                        } else {
                          _isRecording = !_isRecording;
                        }
                      });
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
                                  : (_isRecording ? BoxShape.rectangle : BoxShape.circle),
                          color:
                              _mode == CameraMode.scan
                                  ? (_isScanning ? AppColors.primaryColor : Colors.white)
                                  : (_isRecording ? Colors.red : Colors.red.withOpacity(0.8)),
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
                        ? (_isScanning ? 'Identificando...' : 'Toca para escanear')
                        : (_isRecording ? 'Grabando reel...' : 'Toca para grabar'),
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
          color: isActive ? AppColors.primaryColor.withOpacity(0.8) : Colors.transparent,
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
