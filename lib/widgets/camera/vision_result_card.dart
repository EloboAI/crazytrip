import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../services/vision_service.dart';
import '../../services/database_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'image_fullscreen_viewer.dart';
import 'correction_suggestion_dialog.dart';

/// Tarjeta de resultados del análisis de Vision AI
/// Muestra la imagen capturada y toda la información analizada
class VisionResultCard extends StatelessWidget {
  final ui.Image image;
  final Uint8List imageBytes;
  final VisionResult result;
  final int? captureId; // ID de la captura en BD (para eliminar si rechaza)
  final String?
  imagePath; // Ruta del archivo de imagen (para eliminar si rechaza)
  final VoidCallback? onAccept; // Callback cuando acepta
  final VoidCallback? onReject; // Callback cuando rechaza

  const VisionResultCard({
    super.key,
    required this.image,
    required this.imageBytes,
    required this.result,
    this.captureId,
    this.imagePath,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            Theme.of(context).brightness == Brightness.dark
                ? Colors.black87
                : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.m),
            child: Row(
              children: [
                Text(
                  'Vision AI',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Contenido scrollable
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                0,
                AppSpacing.l,
                AppSpacing.l,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen con Hero animation, tap para expandir y banderita para reportar
                  Hero(
                    tag: 'analysis_image_${image.hashCode}',
                    child: GestureDetector(
                      onTap: () => _openFullscreenImage(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              RawImage(
                                image: image,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              // Indicador de tap para expandir (esquina inferior derecha)
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              // Banderita discreta para reportar (esquina superior derecha)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () => _showReportOptions(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.flag_outlined,
                                      color: Colors.orange,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.m),

                  // Información principal
                  _buildMainInfo(context),

                  const SizedBox(height: AppSpacing.m),

                  // Badges de métricas
                  _buildMetricsBadges(context),

                  const SizedBox(height: AppSpacing.m),

                  // Task #269: Medalla de rareza movida a _buildMainInfo (derecha de nombre/tipo)

                  // Descripción
                  if (result.description.isNotEmpty) ...[
                    _buildSection(
                      context,
                      title: 'Descripción',
                      content: result.description,
                    ),
                    const SizedBox(height: AppSpacing.m),
                  ],

                  // Contexto amplio
                  if (result.broaderContext != null &&
                      result.broaderContext!.isNotEmpty) ...[
                    _buildBroaderContext(context),
                    const SizedBox(height: AppSpacing.m),
                  ],

                  // Información de ubicación
                  if (result.locationInfo != null) ...[
                    _buildLocationInfo(context),
                    const SizedBox(height: AppSpacing.m),
                  ],

                  // Orientación de la cámara
                  if (result.orientation != null) ...[
                    _buildOrientationInfo(context),
                  ],
                ],
              ),
            ),
          ),

          // Botones de acción
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[900]
                      : Colors.grey[100],
              border: Border(
                top: BorderSide(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]!
                          : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check),
                label: const Text('Aceptar'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullscreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withOpacity(0.9),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: ImageFullscreenViewer(
              image: image,
              heroTag: 'analysis_image_${image.hashCode}',
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showReportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  child: Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: Colors.orange),
                      const SizedBox(width: 12),
                      Text(
                        'Reportar un problema',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Opción 1: Rechazar identificación
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                  title: const Text('No es correcto'),
                  subtitle: const Text(
                    'Esta identificación no coincide con la imagen',
                  ),
                  onTap: () {
                    Navigator.pop(context); // Cerrar bottom sheet
                    _handleRejectIdentification(context);
                  },
                ),

                // Opción 2: Sugerir corrección
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.edit, color: Colors.white, size: 20),
                  ),
                  title: const Text('Sugerir corrección'),
                  subtitle: const Text(
                    'Proponer el nombre y descripción correctos',
                  ),
                  onTap: () {
                    Navigator.pop(context); // Cerrar bottom sheet
                    _handleSuggestCorrection(context);
                  },
                ),

                const SizedBox(height: AppSpacing.m),
              ],
            ),
          ),
    );
  }

  void _handleRejectIdentification(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Rechazar identificación'),
            content: const Text(
              '¿Estás seguro de que esta identificación no es correcta?\n\n'
              'La captura será eliminada y no aparecerá en tu CrazyDex.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () async {
                  Navigator.of(dialogContext).pop(); // Cerrar diálogo

                  // Eliminar de base de datos y archivo
                  try {
                    if (captureId != null) {
                      final dbService = DatabaseService();
                      await dbService.deleteCapture(captureId!);
                      debugPrint('🗑️ Capture deleted from DB: $captureId');
                    }

                    if (imagePath != null) {
                      final file = File(imagePath!);
                      if (await file.exists()) {
                        await file.delete();
                        debugPrint('🗑️ Image file deleted: $imagePath');
                      }
                    }

                    // Llamar callback si existe
                    onReject?.call();

                    if (context.mounted) {
                      Navigator.of(context).pop(); // Cerrar tarjeta

                      // Mostrar mensaje de confirmación
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Captura eliminada correctamente'),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } catch (e) {
                    debugPrint('❌ Error deleting capture: $e');
                    if (context.mounted) {
                      Navigator.of(
                        context,
                      ).pop(); // Cerrar tarjeta de todos modos
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error al eliminar: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: FilledButton.styleFrom(backgroundColor: Colors.red[700]),
                child: const Text('Rechazar y eliminar'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleSuggestCorrection(BuildContext context) async {
    // Abrir diálogo de pantalla completa para sugerencia
    final suggestion = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder:
            (context) => CorrectionSuggestionDialog(
              originalName: result.name,
              originalDescription: result.description,
            ),
        fullscreenDialog: true,
      ),
    );

    if (suggestion != null) {
      debugPrint('📝 Corrección sugerida: $suggestion');

      // Mostrar confirmación
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Sugerencia enviada. ¡Gracias por ayudarnos!',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildMainInfo(BuildContext context) {
    return Row(
      children: [
        // Icono de categoría
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(result.category),
            color: AppColors.primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        // Nombre y tipo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (result.type.isNotEmpty)
                Text(
                  result.type,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
            ],
          ),
        ),
        // Task #269: Medalla de rareza a la derecha (vertical)
        if (result.rarity.isNotEmpty) _buildRarityMedal(context),
      ],
    );
  }

  Widget _buildMetricsBadges(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.s,
      runSpacing: AppSpacing.s,
      children: [
        // Confidence
        if (result.confidence > 0)
          _buildBadge(
            context,
            label: 'Confianza',
            value: '${(result.confidence * 100).toStringAsFixed(0)}%',
            color: _getConfidenceColor(result.confidence),
            onTap:
                () => _showInfoDialog(
                  context,
                  title: 'Confianza',
                  content:
                      'Indica qué tan seguro está el modelo de su identificación. Mayor porcentaje = mayor certeza.',
                ),
          ),

        // Encounter Rarity
        if (result.encounterRarity.isNotEmpty)
          _buildBadge(
            context,
            label: 'Encuentro',
            value: _formatEncounterRarity(result.encounterRarity),
            color: _getEncounterRarityColor(result.encounterRarity),
            onTap:
                () => _showInfoDialog(
                  context,
                  title: 'Rareza de Encuentro',
                  content:
                      'Qué tan común es encontrar este objeto o ser vivo en la naturaleza o vida cotidiana.',
                ),
          ),

        // Authenticity
        if (result.authenticity.isNotEmpty && result.authenticity != 'unknown')
          _buildBadge(
            context,
            label: 'Autenticidad',
            value: result.authenticity,
            color: _getAuthenticityColor(result.authenticity),
            onTap:
                () => _showInfoDialog(
                  context,
                  title: 'Autenticidad',
                  content:
                      'Indica si el objeto es real, una réplica, arte, o una representación digital.',
                ),
          ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.info_outline, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }

  /// Task #269: Medalla de rareza vertical con colores de materiales estándar y tooltip
  Widget _buildRarityMedal(BuildContext context) {
    final rarity = result.rarity.toLowerCase();
    final medalData = _getRarityMedalData(rarity);

    return InkWell(
      onTap:
          () => _showInfoDialog(
            context,
            title: 'Rareza Global',
            content:
                'Nivel de rareza: ${medalData['name']}\n\n${medalData['description']}',
          ),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: medalData['colors'] as List<Color>,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (medalData['colors'] as List<Color>)[0].withOpacity(0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.white, size: 28),
            const SizedBox(height: 2),
            Text(
              result.rarity,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroaderContext(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Contexto',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            result.broaderContext!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context) {
    final locationInfo = result.locationInfo!;

    return _buildSection(
      context,
      title: 'Ubicación',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (locationInfo.country.isNotEmpty)
            _buildInfoRow(context, Icons.flag, locationInfo.country),
          if (locationInfo.state.isNotEmpty)
            _buildInfoRow(context, Icons.map, locationInfo.state),
          if (locationInfo.city.isNotEmpty)
            _buildInfoRow(context, Icons.location_city, locationInfo.city),
          if (locationInfo.placeName != null &&
              locationInfo.placeName!.isNotEmpty)
            _buildInfoRow(
              context,
              Icons.place_outlined,
              locationInfo.placeName!,
            ),
          if (result.location != null)
            _buildInfoRow(
              context,
              Icons.my_location,
              '${result.location!.latitude.toStringAsFixed(6)}, ${result.location!.longitude.toStringAsFixed(6)}',
            ),
        ],
      ),
    );
  }

  Widget _buildOrientationInfo(BuildContext context) {
    final orientation = result.orientation!;

    return _buildSection(
      context,
      title: 'Orientación',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            context,
            Icons.explore,
            '${orientation.bearing.toStringAsFixed(1)}° ${orientation.cardinalDirection}',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required dynamic content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.s),
        if (content is String)
          Text(content, style: Theme.of(context).textTheme.bodyMedium)
        else
          content,
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: AppSpacing.s),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }

  // Helper methods
  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.category;
    switch (category.toLowerCase()) {
      case 'animal':
        return Icons.pets;
      case 'plant':
        return Icons.local_florist;
      case 'landmark':
        return Icons.landscape;
      case 'building':
        return Icons.location_city;
      case 'object':
        return Icons.category;
      default:
        return Icons.category;
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.9) return Colors.green;
    if (confidence > 0.7) return Colors.blue;
    if (confidence > 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getEncounterRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.blue;
      case 'hard':
        return Colors.orange;
      case 'epic':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Color _getAuthenticityColor(String authenticity) {
    switch (authenticity.toLowerCase()) {
      case 'real':
        return Colors.green;
      case 'replica':
        return Colors.orange;
      case 'art':
        return Colors.purple;
      case 'digital':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _formatEncounterRarity(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'easy':
        return 'Fácil';
      case 'medium':
        return 'Medio';
      case 'hard':
        return 'Difícil';
      case 'epic':
        return 'Épico';
      default:
        return rarity;
    }
  }

  /// Task #269: Retorna datos de la medalla (colores, nombre, descripción)
  Map<String, dynamic> _getRarityMedalData(String rarity) {
    switch (rarity) {
      case 'legendary':
        return {
          'colors': [const Color(0xFFFFD700), const Color(0xFFFFA500)], // Gold
          'name': 'LEGENDARY',
          'description':
              'Objeto extremadamente raro y valioso en el mundo. Solo unos pocos existen.',
        };
      case 'epic':
        return {
          'colors': [
            const Color(0xFFC0C0C0),
            const Color(0xFF808080),
          ], // Silver
          'name': 'EPIC',
          'description':
              'Objeto muy raro y difícil de encontrar. Requiere dedicación.',
        };
      case 'rare':
        return {
          'colors': [
            const Color(0xFFCD7F32),
            const Color(0xFF8B4513),
          ], // Bronze
          'name': 'RARE',
          'description': 'Objeto poco común que requiere búsqueda activa.',
        };
      case 'uncommon':
        return {
          'colors': [
            const Color(0xFFB87333),
            const Color(0xFF996515),
          ], // Copper
          'name': 'UNCOMMON',
          'description':
              'Objeto ocasional que puede encontrarse con algo de suerte.',
        };
      default:
        return {
          'colors': [Colors.grey[600]!, Colors.grey[800]!], // Stone/Common
          'name': 'COMMON',
          'description': 'Objeto común y fácil de encontrar en la vida diaria.',
        };
    }
  }
}
