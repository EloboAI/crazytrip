import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';

/// Banner de advertencia para mostrar cuando una imagen no es auténtica
///
/// Se muestra cuando el campo `authenticity` de VisionResult no es "real".
/// Indica al usuario que la imagen podría ser de una pantalla o impresión.
class AuthenticityWarningBanner extends StatelessWidget {
  /// Tipo de autenticidad detectado: "screen", "print", "unknown"
  final String authenticity;

  /// Si se muestra como overlay flotante (por defecto true)
  final bool isFloating;

  const AuthenticityWarningBanner({
    super.key,
    required this.authenticity,
    this.isFloating = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar texto y color según el tipo
    final String warningText;
    final Color backgroundColor;
    final IconData icon;

    switch (authenticity) {
      case 'screen':
        warningText = 'Posible foto de pantalla detectada';
        backgroundColor = Colors.orange.shade700;
        icon = Icons.smartphone;
        break;
      case 'print':
        warningText = 'Posible foto de impresión detectada';
        backgroundColor = Colors.orange.shade700;
        icon = Icons.print;
        break;
      case 'unknown':
        warningText = 'No se pudo verificar autenticidad';
        backgroundColor = Colors.orange.shade600;
        icon = Icons.help_outline;
        break;
      default:
        // No mostrar banner si es "real"
        return const SizedBox.shrink();
    }

    final banner = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.9),
        borderRadius: isFloating ? BorderRadius.circular(8) : null,
        boxShadow:
            isFloating
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
                : null,
      ),
      child: Row(
        mainAxisSize: isFloating ? MainAxisSize.min : MainAxisSize.max,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              warningText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.warning, color: Colors.white, size: 18),
        ],
      ),
    );

    // Si es flotante, envolverlo en Positioned para overlay
    if (isFloating) {
      return Positioned(top: 16, left: 16, right: 16, child: banner);
    }

    return banner;
  }
}
