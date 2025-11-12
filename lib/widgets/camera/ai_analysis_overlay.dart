import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Overlay de pantalla completa que muestra la imagen capturada con efecto de análisis AI
/// Simula el proceso de análisis visual con puntos de brillo y líneas de escaneo
class AIAnalysisOverlay extends StatefulWidget {
  final ui.Image image;
  final VoidCallback? onCancel;
  final String? errorMessage;
  final VoidCallback? onRetry;

  const AIAnalysisOverlay({
    super.key,
    required this.image,
    this.onCancel,
    this.errorMessage,
    this.onRetry,
  });

  @override
  State<AIAnalysisOverlay> createState() => _AIAnalysisOverlayState();
}

class _AIAnalysisOverlayState extends State<AIAnalysisOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _particlesController;
  final List<ScanParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Controller para efecto de pulso del grid
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Controller para fade in/out más suave de partículas
    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500), // Ciclo más lento: 1.5s
    )..repeat();

    // Generar partículas con tiempos de vida y posiciones aleatorias
    _initializeParticles();

    // Regenerar partículas cuando completan su ciclo de vida
    _particlesController.addListener(() {
      if (_random.nextDouble() < 0.12) {
        // 12% probabilidad (menos frecuente, menos molesto)
        final index = _random.nextInt(_particles.length);
        setState(() {
          _particles[index] = _createRandomParticle();
        });
      }
    });
  }

  void _initializeParticles() {
    // Menos partículas para efecto más sutil
    for (int i = 0; i < 8; i++) {
      _particles.add(_createRandomParticle());
    }
  }

  ScanParticle _createRandomParticle() {
    return ScanParticle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 6.0 + _random.nextDouble() * 4.0, // 6-10px (más pequeños)
      speed: 0, // Sin movimiento, solo fade
      phase: _random.nextDouble() * 2 * pi, // fase inicial aleatoria para desfase
      pulseSpeed: 0.7 + _random.nextDouble() * 0.3, // fade más lento: 0.7-1.0x
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _particlesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen capturada de fondo
          Hero(
            tag: 'analysis_image_${widget.image.hashCode}',
            child: RawImage(
              image: widget.image,
              fit: BoxFit.contain,
            ),
          ),

          // Overlay oscuro semitransparente
          Container(
            color: Colors.black.withOpacity(0.6),
          ),

          // Efecto de análisis animado (solo si no hay error)
          if (widget.errorMessage == null)
            AnimatedBuilder(
              animation: Listenable.merge([_scanController, _particlesController]),
              builder: (context, child) {
                return CustomPaint(
                  painter: AIAnalysisPainter(
                    scanProgress: _scanController.value,
                    particles: _particles,
                    time: _particlesController.value,
                  ),
                );
              },
            ),

          // Mensaje de error o estado de análisis
          Positioned(
            left: 0,
            right: 0,
            bottom: 100,
            child: widget.errorMessage != null
                ? _buildErrorState()
                : _buildAnalyzingState(),
          ),

          // Botón de cancelar (opcional)
          if (widget.onCancel != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.tertiaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Analizando imagen...',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mensaje de error
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.shade900.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.shade300.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'Error en el análisis',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.errorMessage ?? 'No se pudo analizar la imagen',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Botón Cancelar
              if (widget.onCancel != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                    label: const Text('Cancelar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              if (widget.onCancel != null && widget.onRetry != null)
                const SizedBox(width: 16),
              // Botón Reintentar
              if (widget.onRetry != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Datos de una partícula de escaneo
class ScanParticle {
  final double x; // Posición X normalizada (0-1)
  final double y; // Posición Y normalizada (0-1)
  final double size; // Tamaño en pixels
  final double speed; // Velocidad de movimiento
  final double phase; // Fase inicial para variación
  final double pulseSpeed; // Velocidad de pulsación

  ScanParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.pulseSpeed,
  });
}

/// Painter para el efecto de análisis AI
class AIAnalysisPainter extends CustomPainter {
  final double scanProgress;
  final List<ScanParticle> particles;
  final double time;

  AIAnalysisPainter({
    required this.scanProgress,
    required this.particles,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Dibujar grid sutil de análisis
    _drawAnalysisGrid(canvas, size);

    // Dibujar puntos de reconocimiento (estilo AI)
    _drawParticles(canvas, size);

    // Dibujar pulsos desde puntos de interés
    _drawPulseWaves(canvas, size);
  }

  void _drawAnalysisGrid(Canvas canvas, Size size) {
    // Grid sutil que pulsa, estilo análisis AI
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = AppColors.primaryColor.withOpacity(0.15 * (0.5 + 0.5 * sin(scanProgress * 2 * pi)));

    // Líneas verticales
    final gridSpacing = size.width / 6;
    for (int i = 1; i < 6; i++) {
      final x = i * gridSpacing;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Líneas horizontales
    final gridSpacingV = size.height / 8;
    for (int i = 1; i < 8; i++) {
      final y = i * gridSpacingV;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Borde que pulsa
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = AppColors.primaryColor.withOpacity(0.3 * (0.7 + 0.3 * sin(scanProgress * 2 * pi)));

    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      borderPaint,
    );
  }

  void _drawParticles(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Posición fija (sin vibración)
      final x = particle.x * size.width;
      final y = particle.y * size.height;

      // Fade in/out suave: 0.0 → 1.0 → 0.0 en ciclo de 1.5s
      final fadeProgress = (time * particle.pulseSpeed + particle.phase / (2 * pi)) % 1.0;
      final opacity = fadeProgress < 0.5
          ? (fadeProgress * 2) // Fade in: 0 → 1 en primera mitad
          : ((1 - fadeProgress) * 2); // Fade out: 1 → 0 en segunda mitad

      // Solo dibujar si tiene opacidad visible (optimización)
      if (opacity < 0.05) continue;

      // Dibujar cruz de "punto de reconocimiento" estilo AI (más translúcida)
      final crossPaint = Paint()
        ..color = AppColors.primaryColor.withOpacity(opacity * 0.5) // 50% más translúcido
        ..strokeWidth = 1.5 // Línea más fina
        ..style = PaintingStyle.stroke;

      final crossSize = particle.size;
      
      // Línea horizontal
      canvas.drawLine(
        Offset(x - crossSize, y),
        Offset(x + crossSize, y),
        crossPaint,
      );
      
      // Línea vertical
      canvas.drawLine(
        Offset(x, y - crossSize),
        Offset(x, y + crossSize),
        crossPaint,
      );

      // Círculo exterior (tamaño fijo, solo fade, muy translúcido)
      canvas.drawCircle(
        Offset(x, y),
        crossSize * 1.5,
        Paint()
          ..color = AppColors.tertiaryColor.withOpacity(opacity * 0.3) // Más translúcido
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Punto central brillante pero sutil
      canvas.drawCircle(
        Offset(x, y),
        2.0,
        Paint()..color = Colors.white.withOpacity(opacity * 0.7), // Más translúcido
      );

      // Glow effect muy sutil
      canvas.drawCircle(
        Offset(x, y),
        crossSize * 2.5,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.primaryColor.withOpacity(opacity * 0.25), // Más translúcido
              AppColors.tertiaryColor.withOpacity(opacity * 0.12), // Más translúcido
              Colors.transparent,
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(
            Rect.fromCircle(center: Offset(x, y), radius: crossSize * 2.5),
          ),
      );
    }
  }

  void _drawPulseWaves(Canvas canvas, Size size) {
    // Ondas desde varios puntos de la imagen (simula análisis múltiple)
    final wavePhase = scanProgress;
    
    // Múltiples centros de análisis
    final centers = [
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.5, size.height * 0.7),
    ];

    for (int i = 0; i < centers.length; i++) {
      final phaseOffset = i * 0.33; // Desfase entre ondas
      final localPhase = (wavePhase + phaseOffset) % 1.0;
      
      if (localPhase < 0.7) {
        final center = centers[i];
        final maxRadius = size.width * 0.2;
        final currentRadius = maxRadius * localPhase / 0.7;
        final opacity = (1 - localPhase / 0.7) * 0.4;

        final paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = AppColors.tertiaryColor.withOpacity(opacity);

        canvas.drawCircle(center, currentRadius, paint);

        // Onda secundaria más sutil
        if (localPhase > 0.2) {
          final secondRadius = maxRadius * (localPhase - 0.2) / 0.7;
          final secondOpacity = (1 - (localPhase - 0.2) / 0.7) * 0.2;
          
          canvas.drawCircle(
            center,
            secondRadius,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.5
              ..color = AppColors.primaryColor.withOpacity(secondOpacity),
          );
        }
      }
    }
  }  @override
  bool shouldRepaint(AIAnalysisPainter oldDelegate) {
    return oldDelegate.scanProgress != scanProgress ||
        oldDelegate.time != time ||
        oldDelegate.particles != particles;
  }
}
