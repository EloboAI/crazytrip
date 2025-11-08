import 'package:flutter/material.dart';
import '../models/crazydex_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Screen showing user's complete CrazyDex collection across all discoveries
class CrazyDexCollectionScreen extends StatefulWidget {
  const CrazyDexCollectionScreen({super.key});

  @override
  State<CrazyDexCollectionScreen> createState() =>
      _CrazyDexCollectionScreenState();
}

class _CrazyDexCollectionScreenState extends State<CrazyDexCollectionScreen> {
  CrazyDexCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final allItems = getMockCrazyDexItems();
    final discovered = allItems.where((item) => item.isDiscovered).toList();
    final locked = allItems.where((item) => !item.isDiscovered).toList();

    // Filter by category if selected
    final filteredDiscovered =
        _selectedCategory == null
            ? discovered
            : discovered
                .where((item) => item.category == _selectedCategory)
                .toList();
    final filteredLocked =
        _selectedCategory == null
            ? locked
            : locked
                .where((item) => item.category == _selectedCategory)
                .toList();

    final progress = calculateProgress(allItems);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi CrazyDex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showInfoDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Header
          _buildProgressHeader(progress),

          // Category Filter
          _buildCategoryFilter(),

          // Items List
          Expanded(
            child:
                filteredDiscovered.isEmpty && filteredLocked.isEmpty
                    ? _buildEmptyState()
                    : ListView(
                      padding: EdgeInsets.all(AppSpacing.m),
                      children: [
                        if (filteredDiscovered.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Descubiertos',
                            filteredDiscovered.length,
                          ),
                          SizedBox(height: AppSpacing.m),
                          ...filteredDiscovered.map(
                            (item) => _buildItemCard(item, isDiscovered: true),
                          ),
                          SizedBox(height: AppSpacing.l),
                        ],
                        if (filteredLocked.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Por descubrir',
                            filteredLocked.length,
                          ),
                          SizedBox(height: AppSpacing.m),
                          ...filteredLocked.map(
                            (item) => _buildItemCard(item, isDiscovered: false),
                          ),
                        ],
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(CrazyDexProgress progress) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn(
                'Total',
                progress.totalItems.toString(),
                Icons.list,
              ),
              _buildStatColumn(
                'Descubiertos',
                progress.discoveredItems.toString(),
                Icons.check_circle,
              ),
              _buildStatColumn(
                'Progreso',
                '${progress.completionPercentage}%',
                Icons.emoji_events,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.m),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.discoveredItems / progress.totalItems,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: AppSpacing.s),
          Text(
            'Rango: ${progress.rank}',
            style: AppTextStyles.titleMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.m),
        children: [
          _buildCategoryChip(null, 'Todos', Icons.apps),
          ...CrazyDexCategory.values.map((category) {
            return _buildCategoryChip(
              category,
              category.displayName,
              _getCategoryIcon(category),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    CrazyDexCategory? category,
    String label,
    IconData icon,
  ) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: EdgeInsets.only(right: AppSpacing.s),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primaryColor,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(label),
          ],
        ),
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: AppColors.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.primaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  IconData _getCategoryIcon(CrazyDexCategory category) {
    switch (category) {
      case CrazyDexCategory.fauna:
        return Icons.pets;
      case CrazyDexCategory.flora:
        return Icons.local_florist;
      case CrazyDexCategory.mountains:
        return Icons.terrain;
      case CrazyDexCategory.waterBodies:
        return Icons.water;
      case CrazyDexCategory.buildings:
        return Icons.apartment;
      case CrazyDexCategory.food:
        return Icons.restaurant;
      case CrazyDexCategory.art:
        return Icons.palette;
      case CrazyDexCategory.culture:
        return Icons.theater_comedy;
      case CrazyDexCategory.landmarks:
        return Icons.location_city;
      case CrazyDexCategory.transportation:
        return Icons.directions_bus;
    }
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: AppSpacing.xs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s,
            vertical: AppSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItemCard(CrazyDexItem item, {required bool isDiscovered}) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.m),
      color: isDiscovered ? null : Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            // Image/Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color:
                    isDiscovered
                        ? AppColors.primaryColor.withOpacity(0.1)
                        : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child:
                    isDiscovered
                        ? Text(
                          item.imageUrl,
                          style: const TextStyle(fontSize: 32),
                        )
                        : Icon(Icons.lock, size: 32, color: Colors.grey),
              ),
            ),
            SizedBox(width: AppSpacing.m),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDiscovered ? item.name : '???',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDiscovered ? null : Colors.grey,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(item.rarityStars, style: const TextStyle(fontSize: 12)),
                  SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDiscovered
                                  ? _getCategoryColor(item.category)
                                  : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: isDiscovered ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.s),
                      Icon(
                        Icons.star,
                        size: 12,
                        color: isDiscovered ? Colors.amber : Colors.grey,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '+${item.xpReward} XP',
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              isDiscovered
                                  ? Colors.amber.shade700
                                  : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (isDiscovered && item.discoveredAt != null) ...[
                    SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Descubierto hace ${_getTimeAgo(item.discoveredAt!)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (isDiscovered)
              Icon(Icons.check_circle, color: Colors.green, size: 24)
            else
              Icon(Icons.help_outline, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(CrazyDexCategory category) {
    switch (category) {
      case CrazyDexCategory.fauna:
        return Colors.green;
      case CrazyDexCategory.flora:
        return Colors.blue;
      case CrazyDexCategory.mountains:
        return Colors.brown;
      case CrazyDexCategory.waterBodies:
        return Colors.cyan;
      case CrazyDexCategory.buildings:
        return Colors.grey;
      case CrazyDexCategory.food:
        return Colors.orange;
      case CrazyDexCategory.art:
        return Colors.purple;
      case CrazyDexCategory.culture:
        return Colors.pink;
      case CrazyDexCategory.landmarks:
        return Colors.indigo;
      case CrazyDexCategory.transportation:
        return Colors.teal;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: AppSpacing.m),
            Text(
              'No hay items en esta categoría',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s),
            Text(
              'Visita diferentes lugares y usa tu cámara para descubrir nuevos items',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'recién';
    }
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('¿Qué es el CrazyDex?'),
            content: const Text(
              'El CrazyDex es tu colección personal de descubrimientos. '
              'Cada lugar que visitas tiene items únicos que puedes identificar '
              'usando tu cámara.\n\n'
              'Colecciona flora, fauna, monumentos, comida típica y más. '
              '¡Completa categorías para desbloquear logros especiales!',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
    );
  }
}
