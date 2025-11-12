import 'package:flutter/material.dart';
import '../../services/location_service.dart';
import '../../theme/app_spacing.dart';

/// Muestra un diálogo cuando el GPS está deshabilitado
///
/// Permite al usuario elegir entre:
/// - Activar GPS (abre configuración del sistema)
/// - Continuar sin GPS (modo degradado)
Future<bool?> showGPSDisabledDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const _GPSDisabledDialog(),
  );
}

class _GPSDisabledDialog extends StatelessWidget {
  const _GPSDisabledDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Container(
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.location_off, size: 48, color: Colors.orange),
      ),
      title: const Text('GPS inactivo', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'El GPS está deshabilitado. Para obtener identificaciones más precisas basadas en tu ubicación, activa el GPS.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.m),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Sin GPS, las identificaciones serán menos específicas',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Botón para continuar sin GPS
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Continuar sin GPS'),
        ),

        // Botón para activar GPS
        FilledButton.icon(
          onPressed: () async {
            // Abrir configuración de ubicación
            await LocationService.openLocationSettings();

            // Cerrar diálogo
            if (context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
          icon: const Icon(Icons.settings),
          label: const Text('Activar GPS'),
        ),
      ],
    );
  }
}
