import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/promotion.dart';
import '../models/crazydex_item.dart';
import '../models/discovery.dart';

enum MapViewMode { map, list }

enum MapFilter { promotions, items, places, contests, events }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapViewMode _viewMode = MapViewMode.map;
  final Set<MapFilter> _activeFilters = {
    MapFilter.promotions,
    MapFilter.items,
    MapFilter.places,
  };
  double _searchRadius = 5.0; // km por defecto
  String _searchQuery = '';

  // Mock data
  late List<Promotion> _promotions;
  late List<CrazyDexItem> _items;
  late List<Discovery> _places;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  void _loadMapData() {
    _promotions = getMockPromotions().where((p) => p.isActive).toList();
    _items = getMockCrazyDexItems().where((i) => !i.isDiscovered).toList();
    _places = Discovery.getMockDiscoveries();
  }

  List<dynamic> get _filteredContent {
    List<dynamic> content = [];

    // Prioridad 1: Promociones y Concursos (de paga)
    if (_activeFilters.contains(MapFilter.promotions)) {
      content.addAll(
        _promotions.where(
          (p) =>
              p.type == PromotionType.discount || p.type == PromotionType.event,
        ),
      );
    }
    if (_activeFilters.contains(MapFilter.contests)) {
      content.addAll(
        _promotions.where(
          (p) =>
              p.type == PromotionType.contest ||
              p.type == PromotionType.challenge,
        ),
      );
    }

    // Prioridad 2: Items y Lugares (clusterizables)
    if (_activeFilters.contains(MapFilter.items)) {
      content.addAll(_items);
    }
    if (_activeFilters.contains(MapFilter.places)) {
      content.addAll(_places);
    }

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      content =
          content.where((item) {
            final query = _searchQuery.toLowerCase();
            if (item is Promotion) {
              return item.title.toLowerCase().contains(query) ||
                  item.businessName.toLowerCase().contains(query);
            } else if (item is CrazyDexItem) {
              return item.name.toLowerCase().contains(query);
            } else if (item is Discovery) {
              return item.name.toLowerCase().contains(query) ||
                  item.category.toLowerCase().contains(query);
            }
            return false;
          }).toList();
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content area
          _viewMode == MapViewMode.map ? _buildMapView() : _buildListView(),

          // Top controls
          SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: AppSpacing.s),
                _buildFilterChips(),
              ],
            ),
          ),

          // Bottom sheet with results
          if (_viewMode == MapViewMode.map) _buildBottomSheet(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey[600]),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar lugares, promos, items...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              color: AppColors.primaryColor,
              onPressed: _showFilterDialog,
            ),
            Container(
              width: 1,
              height: 24,
              color: Colors.grey[300],
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            ),
            IconButton(
              icon: Icon(_viewMode == MapViewMode.map ? Icons.list : Icons.map),
              color: AppColors.primaryColor,
              onPressed: () {
                setState(() {
                  _viewMode =
                      _viewMode == MapViewMode.map
                          ? MapViewMode.list
                          : MapViewMode.map;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
        children: [
          _buildFilterChip(
            label: '💰 Promociones',
            filter: MapFilter.promotions,
          ),
          _buildFilterChip(label: '🏆 Concursos', filter: MapFilter.contests),
          _buildFilterChip(label: '🔍 Items', filter: MapFilter.items),
          _buildFilterChip(label: '📍 Lugares', filter: MapFilter.places),
          _buildFilterChip(label: '🎉 Eventos', filter: MapFilter.events),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required MapFilter filter}) {
    final isActive = _activeFilters.contains(filter);
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s),
      child: FilterChip(
        label: Text(label),
        selected: isActive,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _activeFilters.add(filter);
            } else {
              _activeFilters.remove(filter);
            }
          });
        },
        backgroundColor: Colors.white,
        selectedColor: AppColors.primaryColor.withOpacity(0.2),
        checkmarkColor: AppColors.primaryColor,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isActive ? AppColors.primaryColor : Colors.grey[700],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isActive ? AppColors.primaryColor : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildMapView() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.tertiaryColor.withOpacity(0.3),
            AppColors.lightBackground,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 120, color: Colors.grey[400]),
            const SizedBox(height: AppSpacing.m),
            Text(
              'Vista de Mapa',
              style: AppTextStyles.headlineSmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Integración de Google Maps aquí',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '${_filteredContent.length} items en ${_searchRadius.toInt()}km',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    final content = _filteredContent;

    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No hay resultados',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Intenta ajustar los filtros',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 120, // Space for search bar and filters
        left: AppSpacing.m,
        right: AppSpacing.m,
        bottom: AppSpacing.m,
      ),
      itemCount: content.length,
      itemBuilder: (context, index) {
        final item = content[index];
        if (item is Promotion) {
          return _buildPromotionListCard(item);
        } else if (item is CrazyDexItem) {
          return _buildItemListCard(item);
        } else if (item is Discovery) {
          return _buildPlaceListCard(item);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        final content = _filteredContent;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.s),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resultados', style: AppTextStyles.titleLarge),
                        Text(
                          '${content.length} items en ${_searchRadius.toInt()}km',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              // Results list
              Expanded(
                child:
                    content.isEmpty
                        ? Center(
                          child: Text(
                            'No hay resultados',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        )
                        : ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.m,
                          ),
                          itemCount: content.length,
                          itemBuilder: (context, index) {
                            final item = content[index];
                            if (item is Promotion) {
                              return _buildPromotionListCard(item);
                            } else if (item is CrazyDexItem) {
                              return _buildItemListCard(item);
                            } else if (item is Discovery) {
                              return _buildPlaceListCard(item);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPromotionListCard(Promotion promotion) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        onTap: () {
          // Navigate to promotion details
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_offer,
                    color: AppColors.primaryColor,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            promotion.businessName,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSmall,
                            ),
                          ),
                          child: Text(
                            '${promotion.discountPercent}% OFF',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      promotion.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            promotion.address,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemListCard(CrazyDexItem item) {
    final stars = '⭐' * item.rarity;
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        onTap: () {
          // Navigate to item details
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    item.imageUrl,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTextStyles.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(stars, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      item.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.s,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSmall,
                            ),
                          ),
                          child: Text(
                            item.category.name,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceListCard(Discovery place) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        onTap: () {
          // Navigate to place details
        },
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    place.imageUrl,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.m),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: AppTextStyles.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      place.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.catching_pokemon,
                          size: 16,
                          color: AppColors.tertiaryColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${place.crazyDexItemsCollected}/${place.crazyDexItemsAvailable} items',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.tertiaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Radio de Búsqueda', style: AppTextStyles.titleLarge),
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _searchRadius,
                          min: 1.0,
                          max: 50.0,
                          divisions: 49,
                          label: '${_searchRadius.toInt()} km',
                          activeColor: AppColors.primaryColor,
                          onChanged: (value) {
                            setState(() {
                              _searchRadius = value;
                            });
                            // Update parent state
                            this.setState(() {});
                          },
                        ),
                      ),
                      Text(
                        '${_searchRadius.toInt()} km',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.m,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusMedium,
                          ),
                        ),
                      ),
                      child: Text(
                        'Aplicar',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
