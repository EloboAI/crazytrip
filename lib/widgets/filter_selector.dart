import 'package:flutter/material.dart';
import '../models/image_filter.dart';
import '../services/filter_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class FilterSelector extends StatefulWidget {
  final FilterService filterService;
  final Function(ImageFilter)? onFilterSelected;
  final bool showIntensitySlider;

  const FilterSelector({
    super.key,
    required this.filterService,
    this.onFilterSelected,
    this.showIntensitySlider = true,
  });

  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  late ImageFilter _currentFilter;
  late double _currentIntensity;
  List<ImageFilter> _availableFilters = [];

  @override
  void initState() {
    super.initState();
    _availableFilters = ImageFilter.getPredefinedFilters();
    _currentFilter = widget.filterService.currentFilter;
    _currentIntensity = widget.filterService.intensity;

    // Escuchar cambios en el servicio
    widget.filterService.filterStream.listen((filter) {
      if (mounted) {
        setState(() {
          _currentFilter = filter;
        });
      }
    });

    widget.filterService.intensityStream.listen((intensity) {
      if (mounted) {
        setState(() {
          _currentIntensity = intensity;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: AppColors.arOverlayBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selector de filtros
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _availableFilters.length,
              itemBuilder: (context, index) {
                final filter = _availableFilters[index];
                final isSelected = filter.type == _currentFilter.type;
                
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.s),
                  child: _FilterItem(
                    filter: filter,
                    isSelected: isSelected,
                    onTap: () => _selectFilter(filter),
                  ),
                );
              },
            ),
          ),
          
          if (widget.showIntensitySlider) ...[
            const SizedBox(height: AppSpacing.m),
            
            // Control de intensidad
            _IntensityControl(
              intensity: _currentIntensity,
              onChanged: _updateIntensity,
            ),
          ],
        ],
      ),
    );
  }

  void _selectFilter(ImageFilter filter) {
    setState(() {
      _currentFilter = filter;
    });
    widget.filterService.setFilter(filter);
    widget.onFilterSelected?.call(filter);
  }

  void _updateIntensity(double intensity) {
    setState(() {
      _currentIntensity = intensity;
    });
    widget.filterService.setIntensity(intensity);
  }
}

class _FilterItem extends StatelessWidget {
  final ImageFilter filter;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterItem({
    required this.filter,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vista previa del filtro (placeholder)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getFilterColor(),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              filter.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getFilterColor() {
    switch (filter.type) {
      case FilterType.none:
        return Colors.grey[300]!;
      case FilterType.vintage:
        return Colors.brown[300]!;
      case FilterType.blackAndWhite:
        return Colors.grey[600]!;
      case FilterType.sepia:
        return Colors.amber[300]!;
      case FilterType.vivid:
        return Colors.red[300]!;
      case FilterType.warm:
        return Colors.orange[300]!;
      case FilterType.cool:
        return Colors.blue[300]!;
      case FilterType.dramatic:
        return Colors.black87;
    }
  }
}

class _IntensityControl extends StatelessWidget {
  final double intensity;
  final Function(double) onChanged;

  const _IntensityControl({
    required this.intensity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensidad',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(Icons.water_drop, color: Colors.white, size: 16),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Slider(
                value: intensity,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                onChanged: onChanged,
                activeColor: AppColors.primaryColor,
                inactiveColor: Colors.white.withOpacity(0.3),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              '${(intensity * 100).toInt()}%',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ],
    );
  }
}