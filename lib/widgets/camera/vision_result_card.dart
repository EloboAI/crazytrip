import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../services/vision_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import 'image_fullscreen_viewer.dart';

/// Tarjeta de resultados del análisis de Vision AI
/// Muestra la imagen capturada y toda la información analizada
class VisionResultCard extends StatelessWidget {
  final ui.Image image;
  final Uint8List imageBytes;
  final VisionResult result;

  const VisionResultCard({
    super.key,
    required this.image,
    required this.imageBytes,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black87
            : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
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
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                  // Imagen con Hero animation y tap para expandir
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
                              // Indicador de tap para expandir
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

                  // Medalla de rareza
                  if (result.rarity.isNotEmpty) ...[
                    _buildRarityMedal(context),
                    const SizedBox(height: AppSpacing.m),
                  ],

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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (result.type.isNotEmpty)
                Text(
                  result.type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
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
            onTap: () => _showInfoDialog(
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
            onTap: () => _showInfoDialog(
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
            onTap: () => _showInfoDialog(
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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

  Widget _buildRarityMedal(BuildContext context) {
    final rarity = result.rarity.toLowerCase();
    final colors = _getRarityColors(rarity);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[0], colors[1]],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 32),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rareza',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                Text(
                  result.rarity,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
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
              Icon(Icons.lightbulb_outline,
                  color: AppColors.primaryColor, size: 20),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Contexto',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                context, Icons.place_outlined, locationInfo.placeName!),
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
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
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
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
      builder: (context) => AlertDialog(
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

  List<Color> _getRarityColors(String rarity) {
    switch (rarity) {
      case 'legendary':
        return [const Color(0xFFFFD700), const Color(0xFFFFA500)]; // Gold
      case 'epic':
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)]; // Silver
      case 'rare':
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)]; // Bronze
      case 'uncommon':
        return [const Color(0xFFB87333), const Color(0xFF996515)]; // Copper
      default:
        return [Colors.grey[600]!, Colors.grey[800]!]; // Common
    }
  }
}
