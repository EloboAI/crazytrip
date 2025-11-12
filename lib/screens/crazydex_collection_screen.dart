import 'dart:io';
import 'package:flutter/material.dart';
import '../models/vision_capture.dart';
import '../services/database_service.dart';
import 'map_screen.dart';

/// Vista principal del CrazyDex - Colección de capturas del usuario
class CrazyDexCollectionScreen extends StatefulWidget {
  const CrazyDexCollectionScreen({super.key});

  @override
  State<CrazyDexCollectionScreen> createState() =>
      _CrazyDexCollectionScreenState();
}

class _CrazyDexCollectionScreenState extends State<CrazyDexCollectionScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<VisionCapture> _captures = [];
  bool _isLoading = true;

  // Filtros
  String _searchQuery = '';
  String? _selectedCategory;
  String? _selectedCountry;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _loadCaptures();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCaptures() async {
    try {
      final captures = await _dbService.getAllCaptures();
      if (mounted) {
        setState(() {
          _captures = captures;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando capturas: \$e')));
      }
    }
  }

  List<String> _getAvailableCountries() {
    final countries = <String>{};
    for (final capture in _captures) {
      if (capture.locationInfo != null) {
        final country = capture.locationInfo!['country'] as String?;
        if (country != null && country.isNotEmpty) {
          countries.add(country);
        }
      }
    }
    return countries.toList()..sort();
  }

  List<VisionCapture> get _filteredCaptures {
    var filtered = _captures;

    // Filtro por categoría
    if (_selectedCategory != null) {
      filtered =
          filtered
              .where((capture) => capture.category == _selectedCategory)
              .toList();
    }

    // Filtro por país
    if (_selectedCountry != null) {
      filtered =
          filtered.where((capture) {
            final country = capture.locationInfo?['country'] as String?;
            return country == _selectedCountry;
          }).toList();
    }

    // Filtro por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((capture) {
            return capture.name.toLowerCase().contains(_searchQuery) ||
                capture.category.toLowerCase().contains(_searchQuery) ||
                (capture.visionResult['description'] as String? ?? '')
                    .toLowerCase()
                    .contains(_searchQuery);
          }).toList();
    }

    return filtered;
  }

  void _showCaptureInMap(VisionCapture capture) {
    if (capture.location == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta captura no tiene ubicación GPS'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                MapScreen(initialCaptureId: capture.id, showOnlyCapture: true),
      ),
    );
  }

  void _showAllCapturesInMap() {
    final hasGPS = _captures.any((c) => c.location != null);
    if (!hasGPS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay capturas con ubicación GPS'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MapScreen(showOnlyCapturesFilter: true),
      ),
    );
  }

  /// Muestra el preview de una captura con diseño Material Design 3 optimizado
  Future<void> _showCapturePreview(VisionCapture capture) async {
    try {
      // Cargar imagen
      final imageFile = File(capture.imagePath);
      if (!await imageFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Imagen no encontrada')));
        }
        return;
      }

      if (!mounted) return;

      // Mostrar modal con diseño optimizado
      await showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        builder: (context) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  children: [
                    // Header fijo con SafeArea
                    SafeArea(
                      bottom: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Drag handle
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              width: 32,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Header con título y acciones
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capture.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        capture.category,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Botón de mapa (solo si tiene GPS)
                                if (capture.location != null)
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _showCaptureInMap(capture);
                                    },
                                    icon: const Icon(Icons.map_outlined),
                                    tooltip: 'Ver en mapa',
                                    style: IconButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondaryContainer,
                                      foregroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onSecondaryContainer,
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                // Botón de cerrar
                                IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                  tooltip: 'Cerrar',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                        ],
                      ),
                    ),
                    // Contenido scrolleable
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Imagen con tap para expandir
                            Hero(
                              tag: 'capture_${capture.id}',
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder:
                                          (context) => _FullScreenImage(
                                            imageFile: imageFile,
                                            heroTag: 'capture_${capture.id}',
                                            captureName: capture.name,
                                          ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(
                                          imageFile,
                                          fit: BoxFit.cover,
                                        ),
                                        // Indicador de que se puede expandir
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.6,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.zoom_out_map,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Descripción
                            if (capture.visionResult['description'] != null &&
                                (capture.visionResult['description'] as String)
                                    .isNotEmpty) ...[
                              Text(
                                'Descripción',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                capture.visionResult['description'] as String,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Información específica por categoría
                            ..._buildCategoryMetadata(context, capture),
                            // Información de ubicación
                            if (capture.locationInfo != null) ...[
                              _buildInfoSection(context, 'Ubicación', [
                                if ((capture.locationInfo!['country']
                                            as String?)
                                        ?.isNotEmpty ??
                                    false)
                                  _buildInfoChip(
                                    context,
                                    Icons.flag,
                                    capture.locationInfo!['country'] as String,
                                  ),
                                if ((capture.locationInfo!['placeName']
                                            as String?)
                                        ?.isNotEmpty ??
                                    false)
                                  _buildInfoChip(
                                    context,
                                    Icons.place,
                                    capture.locationInfo!['placeName']
                                        as String,
                                  ),
                                if (capture.latitude != null &&
                                    capture.longitude != null)
                                  _buildInfoChip(
                                    context,
                                    Icons.my_location,
                                    '${capture.latitude!.toStringAsFixed(4)}, ${capture.longitude!.toStringAsFixed(4)}',
                                  ),
                              ]),
                              const SizedBox(height: 24),
                            ],
                            // Información de orientación de cámara
                            if (capture.orientation != null) ...[
                              _buildInfoSection(
                                context,
                                'Orientación de la cámara',
                                [
                                  if (capture
                                          .orientation!['cardinalDirection'] !=
                                      null)
                                    _buildInfoChip(
                                      context,
                                      Icons.explore,
                                      capture.orientation!['cardinalDirection']
                                          as String,
                                    ),
                                  if (capture.orientation!['bearing'] != null)
                                    _buildInfoChip(
                                      context,
                                      Icons.navigation,
                                      '${(capture.orientation!['bearing'] as num).toStringAsFixed(1)}°',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                            // Metadata
                            _buildInfoSection(context, 'Detalles', [
                              _buildRarityChip(context, capture.rarity),
                              _buildInfoChip(
                                context,
                                Icons.calendar_today,
                                _formatDate(capture.timestamp),
                              ),
                              _buildInfoChip(
                                context,
                                Icons.remove_red_eye,
                                _getRarityLabel(capture.encounterRarity),
                              ),
                            ]),
                          ],
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar captura: \$e')));
      }
    }
  }

  Widget _buildInfoSection(
    BuildContext context,
    String title,
    List<Widget> chips,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: chips),
      ],
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildRarityChip(BuildContext context, String rarity) {
    // Colores sutiles según rareza
    Color backgroundColor;
    Color foregroundColor;
    IconData icon;
    String label;

    switch (rarity.toLowerCase()) {
      case 'legendary':
        backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
        foregroundColor = Theme.of(context).colorScheme.onTertiaryContainer;
        icon = Icons.auto_awesome;
        label = 'Legendario';
        break;
      case 'epic':
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        foregroundColor = Theme.of(context).colorScheme.onPrimaryContainer;
        icon = Icons.workspace_premium;
        label = 'Épico';
        break;
      case 'rare':
        backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
        foregroundColor = Theme.of(context).colorScheme.onSecondaryContainer;
        icon = Icons.stars;
        label = 'Raro';
        break;
      case 'uncommon':
        backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
        foregroundColor = Theme.of(context).colorScheme.onSurface;
        icon = Icons.star_half;
        label = 'Poco común';
        break;
      default: // common
        backgroundColor = Theme.of(context).colorScheme.surfaceContainerHigh;
        foregroundColor = Theme.of(context).colorScheme.onSurface;
        icon = Icons.circle;
        label = 'Común';
    }

    return Chip(
      avatar: Icon(icon, size: 18, color: foregroundColor),
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _getRarityLabel(String encounterRarity) {
    switch (encounterRarity.toLowerCase()) {
      case 'epic':
        return 'Muy difícil de ver';
      case 'hard':
        return 'Difícil de ver';
      case 'medium':
        return 'Moderado';
      case 'easy':
      default:
        return 'Fácil de ver';
    }
  }

  /// Construye información específica según la categoría del objeto
  List<Widget> _buildCategoryMetadata(
    BuildContext context,
    VisionCapture capture,
  ) {
    final metadata =
        capture.visionResult['category_metadata'] as Map<String, dynamic>?;
    if (metadata == null || metadata.isEmpty) return [];

    final category = capture.category.toLowerCase();
    final widgets = <Widget>[];

    switch (category) {
      case 'animal':
        widgets.add(_buildAnimalMetadata(context, metadata));
        break;
      case 'vehicle':
        widgets.add(_buildVehicleMetadata(context, metadata));
        break;
      case 'building':
        widgets.add(_buildBuildingMetadata(context, metadata));
        break;
      case 'food':
        widgets.add(_buildFoodMetadata(context, metadata));
        break;
      case 'nature':
        widgets.add(_buildNatureMetadata(context, metadata));
        break;
      case 'landmark':
        widgets.add(_buildLandmarkMetadata(context, metadata));
        break;
      case 'product':
        widgets.add(_buildProductMetadata(context, metadata));
        break;
      default:
        // Para 'other' o 'unknown', mostrar metadata genérica si existe
        if (metadata['object_type'] != null) {
          widgets.add(_buildGenericMetadata(context, metadata));
        }
    }

    return widgets;
  }

  Widget _buildAnimalMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    if (metadata['species'] != null) {
      chips.add(
        _buildInfoChip(context, Icons.science, metadata['species'] as String),
      );
    }

    if (metadata['conservation_label'] != null) {
      final status = metadata['conservation_status'] as String?;
      final label = metadata['conservation_label'] as String;
      Color? backgroundColor;
      Color? foregroundColor;

      // Colores según estado de conservación
      switch (status) {
        case 'CR': // En Peligro Crítico
        case 'EN': // En Peligro
          backgroundColor = Theme.of(context).colorScheme.errorContainer;
          foregroundColor = Theme.of(context).colorScheme.onErrorContainer;
          break;
        case 'VU': // Vulnerable
          backgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
          foregroundColor = Theme.of(context).colorScheme.onTertiaryContainer;
          break;
        case 'NT': // Casi Amenazado
          backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
          foregroundColor = Theme.of(context).colorScheme.onSecondaryContainer;
          break;
        default: // LC, etc.
          backgroundColor =
              Theme.of(context).colorScheme.surfaceContainerHighest;
          foregroundColor = Theme.of(context).colorScheme.onSurface;
      }

      chips.add(
        Chip(
          avatar: Icon(Icons.favorite, size: 18, color: foregroundColor),
          label: Text(label),
          backgroundColor: backgroundColor,
          labelStyle: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );
    }

    if (metadata['habitat'] != null) {
      chips.add(
        _buildInfoChip(context, Icons.forest, metadata['habitat'] as String),
      );
    }

    if (metadata['is_endemic'] == true && metadata['endemic_region'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.location_on,
          'Endémico: ${metadata['endemic_region']}',
        ),
      );
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información de la Especie', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  Widget _buildVehicleMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    if (metadata['brand'] != null || metadata['model'] != null) {
      final brand = metadata['brand'] as String? ?? '';
      final model = metadata['model'] as String? ?? '';
      chips.add(
        _buildInfoChip(context, Icons.drive_eta, '$brand $model'.trim()),
      );
    }

    if (metadata['year_range'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.calendar_today,
          metadata['year_range'] as String,
        ),
      );
    }

    if (metadata['is_electric'] == true) {
      chips.add(
        Chip(
          avatar: const Icon(Icons.ev_station, size: 18, color: Colors.green),
          label: Text(
            metadata['sustainability_note'] as String? ?? 'Vehículo Eléctrico',
          ),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer
              .withValues(red: 0.8, green: 1.0, blue: 0.8),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );
    }

    if (metadata['classic_value'] == 'classic') {
      chips.add(_buildInfoChip(context, Icons.star, 'Clásico'));
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información del Vehículo', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  Widget _buildBuildingMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    if (metadata['architectural_style'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.architecture,
          metadata['architectural_style'] as String,
        ),
      );
    }

    if (metadata['certifications'] != null) {
      final certs = metadata['certifications'] as List;
      for (final cert in certs) {
        chips.add(
          Chip(
            avatar: const Icon(Icons.eco, size: 18, color: Colors.blue),
            label: Text(cert as String),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer
                .withValues(red: 0.8, green: 0.9, blue: 1.0),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }
    }

    if (metadata['sustainability_features'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.energy_savings_leaf,
          metadata['sustainability_features'] as String,
        ),
      );
    }

    if (metadata['construction_period'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.history,
          metadata['construction_period'] as String,
        ),
      );
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información del Edificio', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  Widget _buildFoodMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    if (metadata['cuisine'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.restaurant,
          metadata['cuisine'] as String,
        ),
      );
    }

    if (metadata['is_traditional'] == true) {
      chips.add(_buildInfoChip(context, Icons.star, 'Plato Tradicional'));
    }

    if (metadata['main_ingredients'] != null) {
      final ingredients = (metadata['main_ingredients'] as List)
          .map((e) => e as String)
          .join(', ');
      chips.add(_buildInfoChip(context, Icons.restaurant_menu, ingredients));
    }

    if (metadata['dietary_info'] != null) {
      final dietary = (metadata['dietary_info'] as List)
          .map((e) => e as String)
          .join(', ');
      chips.add(_buildInfoChip(context, Icons.eco, dietary));
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información del Plato', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  Widget _buildNatureMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    // Elevación (para montañas/picos)
    if (metadata['elevation_meters'] != null) {
      chips.add(
        Chip(
          avatar: const Icon(Icons.trending_up, size: 18, color: Colors.brown),
          label: Text('${metadata['elevation_meters']} msnm'),
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );
    }

    // Cordillera/Rango montañoso
    if (metadata['mountain_range'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.landscape,
          metadata['mountain_range'] as String,
        ),
      );
    }

    // Estado volcánico
    if (metadata['volcanic_status'] != null &&
        metadata['volcanic_status'] != 'not_applicable') {
      final status = metadata['volcanic_status'] as String;
      Color avatarColor;
      String label;

      switch (status) {
        case 'active':
          avatarColor = Colors.red;
          label = 'Volcán Activo';
          break;
        case 'dormant':
          avatarColor = Colors.orange;
          label = 'Volcán Durmiente';
          break;
        case 'extinct':
          avatarColor = Colors.grey;
          label = 'Volcán Extinto';
          break;
        default:
          avatarColor = Colors.grey;
          label = status;
      }

      chips.add(
        Chip(
          avatar: Icon(Icons.volcano, size: 18, color: avatarColor),
          label: Text(label),
          backgroundColor: Theme.of(context).colorScheme.errorContainer,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onErrorContainer,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );

      // Última erupción
      if (metadata['last_eruption'] != null) {
        chips.add(
          _buildInfoChip(
            context,
            Icons.history,
            'Última erupción: ${metadata['last_eruption']}',
          ),
        );
      }
    }

    // Picos visibles
    if (metadata['visible_peaks'] != null) {
      final peaks = metadata['visible_peaks'] as List;
      if (peaks.isNotEmpty && peaks.length > 1) {
        chips.add(
          _buildInfoChip(
            context,
            Icons.visibility,
            'Picos visibles: ${peaks.length}',
          ),
        );
      }
    }

    // Método de identificación (importante para montañas)
    if (metadata['identification_method'] != null) {
      final method = metadata['identification_method'] as String;
      if (method.contains('GPS+bearing')) {
        chips.add(
          Chip(
            avatar: const Icon(
              Icons.gps_fixed,
              size: 18,
              color: Colors.blueAccent,
            ),
            label: const Text('Identificado por GPS+Brújula'),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer
                .withValues(red: 0.8, green: 0.9, blue: 1.0),
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        );
      }
    }

    if (metadata['scientific_name'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.science,
          metadata['scientific_name'] as String,
        ),
      );
    }

    if (metadata['geological_type'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.terrain,
          metadata['geological_type'] as String,
        ),
      );
    }

    if (metadata['protected_status'] != null) {
      chips.add(
        Chip(
          avatar: const Icon(Icons.shield, size: 18, color: Colors.green),
          label: Text(metadata['protected_status'] as String),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer
              .withValues(red: 0.8, green: 1.0, blue: 0.8),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );
    }

    if (metadata['ecological_importance'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.eco,
          metadata['ecological_importance'] as String,
        ),
      );
    }

    if (metadata['best_season'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.wb_sunny,
          metadata['best_season'] as String,
        ),
      );
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información Natural', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  Widget _buildLandmarkMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    if (metadata['cultural_significance'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.location_city,
          metadata['cultural_significance'] as String,
        ),
      );
    }

    if (metadata['unesco_status'] == true) {
      chips.add(
        Chip(
          avatar: const Icon(Icons.star, size: 18, color: Colors.amber),
          label: const Text('Patrimonio UNESCO'),
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      );
    }

    if (metadata['construction_year'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.calendar_today,
          'Construido: ${metadata['construction_year']}',
        ),
      );
    }

    if (metadata['famous_for'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.info_outline,
          metadata['famous_for'] as String,
        ),
      );
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información del Lugar', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  Widget _buildProductMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    if (metadata['brand'] != null) {
      chips.add(
        _buildInfoChip(context, Icons.business, metadata['brand'] as String),
      );
    }

    if (metadata['is_handmade'] == true) {
      chips.add(_buildInfoChip(context, Icons.handyman, 'Hecho a mano'));
    }

    if (metadata['sustainability_note'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.eco,
          metadata['sustainability_note'] as String,
        ),
      );
    }

    if (metadata['origin_country'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.flag,
          'Origen: ${metadata['origin_country']}',
        ),
      );
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información del Producto', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  Widget _buildGenericMetadata(
    BuildContext context,
    Map<String, dynamic> metadata,
  ) {
    final chips = <Widget>[];

    if (metadata['object_type'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.category,
          metadata['object_type'] as String,
        ),
      );
    }

    if (metadata['common_use'] != null) {
      chips.add(
        _buildInfoChip(
          context,
          Icons.info_outline,
          metadata['common_use'] as String,
        ),
      );
    }

    if (metadata['material'] != null) {
      chips.add(
        _buildInfoChip(context, Icons.texture, metadata['material'] as String),
      );
    }

    return chips.isEmpty
        ? const SizedBox.shrink()
        : Column(
          children: [
            _buildInfoSection(context, 'Información Adicional', chips),
            const SizedBox(height: 24),
          ],
        );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoy';
    } else if (diff.inDays == 1) {
      return 'Ayer';
    } else if (diff.inDays < 7) {
      return 'Hace ${diff.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('CrazyDex')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final filteredCaptures = _filteredCaptures;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              title:
                  _showSearch
                      ? TextField(
                        controller: _searchController,
                        autofocus: true,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      )
                      : const Text('CrazyDex'),
              actions: [
                if (_showSearch)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _showSearch = false;
                        _searchController.clear();
                      });
                    },
                  )
                else ...[
                  IconButton(
                    icon: const Icon(Icons.map_outlined),
                    onPressed: _showAllCapturesInMap,
                    tooltip: 'Ver todas en mapa',
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      setState(() {
                        _showSearch = true;
                      });
                    },
                    tooltip: 'Buscar',
                  ),
                  IconButton(
                    icon: Icon(
                      _showFilters
                          ? Icons.filter_alt
                          : Icons.filter_alt_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    tooltip: 'Filtros',
                  ),
                ],
              ],
            ),
            // Filtros colapsables
            if (_showFilters)
              SliverToBoxAdapter(
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Filtro por categoría
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todas'),
                          ),
                          ..._captures
                              .map((c) => c.category)
                              .toSet()
                              .map(
                                (cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                ),
                              ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      // Filtro por país
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        decoration: const InputDecoration(
                          labelText: 'País',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos'),
                          ),
                          ..._getAvailableCountries().map(
                            (country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCountry = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
          ];
        },
        body:
            filteredCaptures.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.catching_pokemon,
                        size: 80,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _captures.isEmpty
                            ? 'No hay capturas aún'
                            : 'No se encontraron resultados',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _captures.isEmpty
                            ? 'Empieza a escanear el mundo'
                            : 'Intenta con otros filtros',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
                : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: filteredCaptures.length,
                  itemBuilder: (context, index) {
                    final capture = filteredCaptures[index];
                    return _buildGridItem(capture);
                  },
                ),
      ),
    );
  }

  Widget _buildGridItem(VisionCapture capture) {
    return GestureDetector(
      onTap: () => _showCapturePreview(capture),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Imagen
              Image.file(
                File(capture.imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  );
                },
              ),
              // Overlay con gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Text(
                    capture.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar imagen en pantalla completa con zoom
class _FullScreenImage extends StatefulWidget {
  final File imageFile;
  final String heroTag;
  final String captureName;

  const _FullScreenImage({
    required this.imageFile,
    required this.heroTag,
    required this.captureName,
  });

  @override
  State<_FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<_FullScreenImage> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Imagen con zoom interactivo
          Center(
            child: Hero(
              tag: widget.heroTag,
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(widget.imageFile, fit: BoxFit.contain),
              ),
            ),
          ),
          // Header con nombre y botón cerrar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        widget.captureName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.6),
                    ),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
            ),
          ),
          // Indicador de zoom en la parte inferior
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Pellizca para hacer zoom',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
