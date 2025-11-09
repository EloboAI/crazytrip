import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../providers/theme_provider.dart';
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
  
  // Google Maps Controller
  GoogleMapController? _mapController;
  
  // Map styles
  String? _lightMapStyle;
  String? _darkMapStyle;
  
  // Posición inicial del mapa (San José, Costa Rica)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(9.9281, -84.0907),
    zoom: 14.0,
  );

  // Mock data
  late List<Promotion> _promotions;
  late List<CrazyDexItem> _items;
  late List<Discovery> _places;

  @override
  void initState() {
    super.initState();
    _loadMapData();
    _loadMapStyles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Actualizar el estilo del mapa cuando cambia el tema
    if (_mapController != null) {
      final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
      _applyMapStyle(themeProvider.isDarkMode);
    }
  }

  Future<void> _loadMapStyles() async {
    try {
      _lightMapStyle = await rootBundle.loadString(
        'assets/map_styles/light_map_style.json',
      );
      _darkMapStyle = await rootBundle.loadString(
        'assets/map_styles/dark_map_style.json',
      );
      setState(() {});
    } catch (e) {
      debugPrint('Error loading map styles: $e');
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isDark ? colorScheme.surfaceContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.s),
            Expanded(
              child: TextField(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Buscar lugares, promos, items...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
              color: colorScheme.outline.withOpacity(0.3),
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
    final colorScheme = Theme.of(context).colorScheme;
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
        backgroundColor: colorScheme.surface,
        selectedColor: colorScheme.primaryContainer,
        showCheckmark: false,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: isActive ? Colors.white : colorScheme.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color:
              isActive
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildMapView() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return GoogleMap(
      initialCameraPosition: _initialPosition,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      // Gestos de interacción habilitados
      zoomGesturesEnabled: true,
      scrollGesturesEnabled: true,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
      minMaxZoomPreference: const MinMaxZoomPreference(10.0, 20.0),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        _applyMapStyle(isDark);
      },
    );
  }
  
  Future<void> _applyMapStyle(bool isDark) async {
    if (_mapController == null) return;
    
    try {
      final style = isDark ? _darkMapStyle : _lightMapStyle;
      if (style != null) {
        await _mapController!.setMapStyle(style);
      }
    } catch (e) {
      debugPrint('Error applying map style: $e');
    }
  }

  Widget _buildListView() {
    final content = _filteredContent;

    if (content.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80, color: colorScheme.outline),
            const SizedBox(height: AppSpacing.m),
            Text(
              'No hay resultados',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Intenta ajustar los filtros',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
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
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLarge),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.2),
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
                  color: colorScheme.outline.withOpacity(0.3),
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
                            color: colorScheme.outline,
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
                              color: colorScheme.outline,
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
                        color: Theme.of(context).colorScheme.outline,
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
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            promotion.address,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Theme.of(context).colorScheme.outline,
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
                        color: Theme.of(context).colorScheme.outline,
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
                        color: Theme.of(context).colorScheme.outline,
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
