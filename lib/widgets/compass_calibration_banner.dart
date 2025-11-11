import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Banner flotante que informa al usuario que necesita calibrar la brújula
/// Se muestra cuando el sensor de brújula tiene baja precisión
class CompassCalibrationBanner extends StatefulWidget {
  final VoidCallback? onDismiss;
  final bool autoHide;

  const CompassCalibrationBanner({
    super.key,
    this.onDismiss,
    this.autoHide = false,
  });

  @override
  State<CompassCalibrationBanner> createState() =>
      _CompassCalibrationBannerState();
}

class _CompassCalibrationBannerState extends State<CompassCalibrationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.all(AppSpacing.m),
          padding: EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color:
                isDark
                    ? AppColors.darkSurface.withOpacity(0.95)
                    : AppColors.lightSurface.withOpacity(0.95),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            border: Border.all(
              color: AppColors.warningColor.withOpacity(0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono de advertencia
              Container(
                padding: EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.warningColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.explore,
                  color: AppColors.warningColor,
                  size: AppSpacing.iconMedium,
                ),
              ),
              SizedBox(width: AppSpacing.m),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Calibrar Brújula',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.warningColor,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        const Text('📱', style: TextStyle(fontSize: 16)),
                        SizedBox(width: AppSpacing.xxs),
                        Expanded(
                          child: Text(
                            'Mueve tu dispositivo en forma de 8',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Botón de cerrar (opcional)
              if (!widget.autoHide)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: AppSpacing.iconSmall,
                    color:
                        isDark
                            ? AppColors.darkOnSurface.withOpacity(0.6)
                            : AppColors.lightOnSurface.withOpacity(0.6),
                  ),
                  onPressed: _handleDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
