import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/vision_capture.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';

/// Modal BottomSheet con detalles completos de una captura
///
/// Muestra: imagen grande, metadata completa (ubicación, timestamp,
/// orientación, confidence, rarity, authenticity, etc.)
class VisionCaptureDetailCard extends StatelessWidget {
  final VisionCapture capture;
  final VoidCallback? onDelete;

  const VisionCaptureDetailCard({
    super.key,
    required this.capture,
    this.onDelete,
  });

  /// Muestra el modal con los detalles de la captura
  static Future<void> show(
    BuildContext context, {
    required VisionCapture capture,
    VoidCallback? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) =>
              VisionCaptureDetailCard(capture: capture, onDelete: onDelete),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visionResult = capture.visionResult;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSpacing.l),
                  children: [
                    // Imagen grande
                    _buildHeroImage(context),
                    const SizedBox(height: AppSpacing.l),

                    // Nombre y tipo
                    _buildTitle(context, visionResult),
                    const SizedBox(height: AppSpacing.m),

                    // Chips de metadata
                    _buildMetadataChips(context, visionResult),
                    const SizedBox(height: AppSpacing.l),

                    // Descripción
                    _buildDescription(context, visionResult),
                    const SizedBox(height: AppSpacing.l),

                    // Ubicación
                    if (capture.location != null)
                      _buildLocationSection(context),
                    if (capture.location != null)
                      const SizedBox(height: AppSpacing.l),

                    // Orientación
                    if (capture.orientation != null)
                      _buildOrientationSection(context),
                    if (capture.orientation != null)
                      const SizedBox(height: AppSpacing.l),

                    // Timestamp
                    _buildTimestampSection(context),
                    const SizedBox(height: AppSpacing.l),

                    // Información técnica
                    _buildTechnicalInfo(context, visionResult, isDark),
                    const SizedBox(height: AppSpacing.xl),

                    // Botón de eliminar
                    if (onDelete != null) _buildDeleteButton(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(capture.imagePath),
        height: 300,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 300,
            color: Colors.grey[300],
            child: const Center(
              child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(BuildContext context, Map<String, dynamic> visionResult) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          visionResult['name'] as String,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          visionResult['type'] as String,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildMetadataChips(
    BuildContext context,
    Map<String, dynamic> visionResult,
  ) {
    final category = visionResult['category'] as String;
    final rarity = visionResult['rarity'] as String;
    final confidence = ((visionResult['confidence'] as num) * 100)
        .toStringAsFixed(0);
    final encounterRarity = visionResult['encounter_rarity'] as String;
    final authenticity = visionResult['authenticity'] as String? ?? 'unknown';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildChip(
          context,
          icon: _getCategoryIcon(category),
          label: _capitalize(category),
          color: AppColors.primaryColor,
        ),
        _buildChip(
          context,
          icon: Icons.diamond,
          label: _capitalize(rarity),
          color: _getRarityColor(rarity),
        ),
        _buildChip(
          context,
          icon: Icons.verified,
          label: '$confidence%',
          color: Colors.green,
        ),
        _buildChip(
          context,
          icon: Icons.explore,
          label: _capitalize(encounterRarity),
          color: _getEncounterRarityColor(encounterRarity),
        ),
        if (authenticity != 'real')
          _buildChip(
            context,
            icon: Icons.warning,
            label: _capitalize(authenticity),
            color: Colors.orange,
          ),
      ],
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  Widget _buildDescription(
    BuildContext context,
    Map<String, dynamic> visionResult,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Descripción',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          visionResult['description'] as String,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (visionResult['broader_context'] != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    visionResult['broader_context'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final location = capture.location!;
    final lat = (location['latitude'] as num).toDouble();
    final lng = (location['longitude'] as num).toDouble();

    String locationText =
        '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

    if (capture.locationInfo != null) {
      final locationInfo = capture.locationInfo!;
      if (locationInfo['fullLocation'] != null) {
        locationText = locationInfo['fullLocation'] as String;
      }
    }

    return _buildInfoSection(
      context,
      icon: Icons.location_on,
      title: 'Ubicación',
      content: locationText,
      iconColor: Colors.red,
    );
  }

  Widget _buildOrientationSection(BuildContext context) {
    final orientation = capture.orientation!;
    final bearing = (orientation['bearing'] as num).toDouble();
    final cardinalDirection = orientation['cardinalDirection'] as String;

    return _buildInfoSection(
      context,
      icon: Icons.explore,
      title: 'Orientación de la cámara',
      content: '$cardinalDirection (${bearing.toStringAsFixed(0)}°)',
      iconColor: Colors.blue,
    );
  }

  Widget _buildTimestampSection(BuildContext context) {
    final formattedDate = _formatTimestamp(capture.timestamp);

    return _buildInfoSection(
      context,
      icon: Icons.access_time,
      title: 'Fecha y hora',
      content: formattedDate,
      iconColor: Colors.purple,
    );
  }

  Widget _buildInfoSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(content, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicalInfo(
    BuildContext context,
    Map<String, dynamic> visionResult,
    bool isDark,
  ) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      leading: const Icon(Icons.code),
      title: Text(
        'Información técnica',
        style: Theme.of(context).textTheme.titleSmall,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.m),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTechRow(
                context,
                'Specificity Level',
                visionResult['specificity_level'] as String,
              ),
              _buildTechRow(
                context,
                'Confidence',
                ((visionResult['confidence'] as num) * 100).toStringAsFixed(2) +
                    '%',
              ),
              _buildTechRow(
                context,
                'Authenticity',
                visionResult['authenticity'] as String? ?? 'unknown',
              ),
              _buildTechRow(
                context,
                'Database ID',
                capture.id?.toString() ?? 'N/A',
              ),
              _buildTechRow(context, 'Synced', capture.isSynced ? 'Yes' : 'No'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTechRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _showDeleteConfirmation(context),
      icon: const Icon(Icons.delete_outline, color: Colors.red),
      label: const Text(
        'Eliminar captura',
        style: TextStyle(color: Colors.red),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar captura'),
            content: Text(
              '¿Estás seguro de que deseas eliminar "${capture.name}"?\n\nEsta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(); // Cerrar el modal
      onDelete?.call();
    }
  }

  // Helper methods
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'landmark':
        return Icons.landscape;
      case 'animal':
        return Icons.pets;
      case 'food':
        return Icons.restaurant;
      case 'building':
        return Icons.apartment;
      case 'nature':
        return Icons.park;
      case 'product':
        return Icons.shopping_bag;
      case 'vehicle':
        return Icons.directions_car;
      default:
        return Icons.category;
    }
  }

  Color _getRarityColor(String rarity) {
    switch (rarity.toLowerCase()) {
      case 'legendary':
        return const Color(0xFFFFD700); // Gold
      case 'epic':
        return const Color(0xFFA335EE); // Purple
      case 'rare':
        return const Color(0xFF0070DD); // Blue
      case 'uncommon':
        return const Color(0xFF1EFF00); // Green
      default:
        return Colors.grey;
    }
  }

  Color _getEncounterRarityColor(String encounterRarity) {
    switch (encounterRarity.toLowerCase()) {
      case 'epic':
        return Colors.purple;
      case 'hard':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'easy':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return 'Hoy a las ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Ayer a las ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      final weekdays = [
        'Lunes',
        'Martes',
        'Miércoles',
        'Jueves',
        'Viernes',
        'Sábado',
        'Domingo',
      ];
      return '${weekdays[timestamp.weekday - 1]} a las ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year} a las ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}
