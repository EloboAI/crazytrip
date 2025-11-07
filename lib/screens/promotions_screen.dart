import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/promotion.dart';
import '../widgets/promotion_card.dart';
import '../widgets/section_header.dart';
import '../widgets/empty_state.dart';

/// Screen displaying promotions and contests from tourist locations
class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Promotion> _allPromotions = getMockPromotions();
  PromotionType? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Promotion> _getFilteredPromotions(int tabIndex) {
    List<Promotion> filtered;

    // Filter by tab
    switch (tabIndex) {
      case 0: // Active
        filtered = PromotionFilters.getActive(_allPromotions);
        break;
      case 1: // Upcoming
        filtered = PromotionFilters.getUpcoming(_allPromotions);
        break;
      case 2: // Expired
        filtered = PromotionFilters.getExpired(_allPromotions);
        break;
      default:
        filtered = _allPromotions;
    }

    // Filter by type if selected
    if (_selectedTypeFilter != null) {
      filtered = filtered
          .where((promo) => promo.type == _selectedTypeFilter)
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promociones y Concursos'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '🔥 Activas', height: 48),
            Tab(text: '⏰ Próximas', height: 48),
            Tab(text: '✓ Finalizadas', height: 48),
          ],
          labelStyle: AppTextStyles.labelLarge,
          indicatorColor: AppColors.primaryColor,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: Column(
        children: [
          // Type Filters
          _buildTypeFilters(),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPromotionsList(0), // Active
                _buildPromotionsList(1), // Upcoming
                _buildPromotionsList(2), // Expired
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(null, 'Todas', Icons.grid_view),
            const SizedBox(width: AppSpacing.xs),
            _buildFilterChip(
              PromotionType.contest,
              'Concursos',
              Icons.emoji_events,
            ),
            const SizedBox(width: AppSpacing.xs),
            _buildFilterChip(
              PromotionType.discount,
              'Descuentos',
              Icons.local_offer,
            ),
            const SizedBox(width: AppSpacing.xs),
            _buildFilterChip(
              PromotionType.event,
              'Eventos',
              Icons.celebration,
            ),
            const SizedBox(width: AppSpacing.xs),
            _buildFilterChip(
              PromotionType.challenge,
              'Desafíos',
              Icons.flash_on,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(PromotionType? type, String label, IconData icon) {
    final isSelected = _selectedTypeFilter == type;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTypeFilter = selected ? type : null;
        });
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: AppColors.primaryColor.withOpacity(0.2),
      checkmarkColor: AppColors.primaryColor,
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: isSelected ? AppColors.primaryColor : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget _buildPromotionsList(int tabIndex) {
    final promotions = _getFilteredPromotions(tabIndex);

    if (promotions.isEmpty) {
      String emptyMessage;
      IconData emptyIcon;

      switch (tabIndex) {
        case 0:
          emptyMessage = 'No hay promociones activas en este momento';
          emptyIcon = Icons.hourglass_empty;
          break;
        case 1:
          emptyMessage = 'No hay promociones próximas';
          emptyIcon = Icons.upcoming;
          break;
        case 2:
          emptyMessage = 'No hay promociones finalizadas';
          emptyIcon = Icons.history;
          break;
        default:
          emptyMessage = 'No hay promociones';
          emptyIcon = Icons.info_outline;
      }

      return EmptyState(
        icon: emptyIcon,
        title: emptyMessage,
        message: _selectedTypeFilter != null
            ? 'Intenta cambiar los filtros para ver más resultados'
            : 'Vuelve pronto para nuevas oportunidades',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          setState(() {});
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.m),
        children: [
          // Header Section
          if (tabIndex == 0) ...[
            SectionHeader(
              title: 'Promociones Activas',
              icon: Icons.local_fire_department,
              iconColor: AppColors.streakColor,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Participa ahora y gana increíbles premios',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ] else if (tabIndex == 1) ...[
            SectionHeader(
              title: 'Próximas Promociones',
              icon: Icons.calendar_today,
              iconColor: AppColors.tertiaryColor,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Prepárate para las siguientes oportunidades',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ] else ...[
            SectionHeader(
              title: 'Promociones Finalizadas',
              icon: Icons.history,
              iconColor: Colors.grey,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Revisa las promociones pasadas',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
          ],

          // Stats Card (only for active tab)
          if (tabIndex == 0 && promotions.isNotEmpty) ...[
            _buildStatsCard(promotions),
            const SizedBox(height: AppSpacing.m),
          ],

          // Promotions List
          ...promotions.map((promotion) {
            return PromotionCard(
              promotion: promotion,
              onTap: () => _showPromotionDetails(promotion),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatsCard(List<Promotion> activePromotions) {
    final totalPrizes = activePromotions.length;
    final totalXP = activePromotions.fold<int>(
      0,
      (sum, promo) => sum + promo.xpReward,
    );
    final totalParticipants = activePromotions.fold<int>(
      0,
      (sum, promo) => sum + promo.participantCount,
    );

    return Card(
      elevation: AppSpacing.elevationMedium,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor.withOpacity(0.08),
              AppColors.tertiaryColor.withOpacity(0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: AppColors.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Oportunidades Disponibles',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.emoji_events,
                      label: 'Premios',
                      value: totalPrizes.toString(),
                      color: AppColors.goldColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[300]!.withOpacity(0.3),
                          Colors.grey[300]!,
                          Colors.grey[300]!.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.stars,
                      label: 'XP Total',
                      value: totalXP.toString(),
                      color: AppColors.xpColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[300]!.withOpacity(0.3),
                          Colors.grey[300]!,
                          Colors.grey[300]!.withOpacity(0.3),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      icon: Icons.people,
                      label: 'Usuarios',
                      value: totalParticipants.toString(),
                      color: AppColors.tertiaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _showPromotionDetails(Promotion promotion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppSpacing.radiusLarge),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                // Drag Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.m),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Text(
                      promotion.imageUrl,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            promotion.title,
                            style: AppTextStyles.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Chip(
                            label: Text(promotion.type.displayName),
                            avatar: Text(promotion.type.emoji),
                            backgroundColor:
                                AppColors.primaryColor.withOpacity(0.1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                // Status & Time
                _buildDetailRow(
                  icon: Icons.access_time,
                  label: 'Estado',
                  value: promotion.statusText,
                  color: promotion.isExpired
                      ? Colors.grey
                      : AppColors.tertiaryColor,
                ),
                const SizedBox(height: AppSpacing.m),
                // Location
                _buildDetailRow(
                  icon: Icons.location_on,
                  label: 'Ubicación',
                  value: promotion.location,
                ),
                const SizedBox(height: AppSpacing.m),
                // Prize
                _buildDetailRow(
                  icon: Icons.emoji_events,
                  label: 'Premio',
                  value: promotion.prize,
                  color: AppColors.goldColor,
                ),
                if (promotion.xpReward > 0) ...[
                  const SizedBox(height: AppSpacing.m),
                  _buildDetailRow(
                    icon: Icons.star,
                    label: 'XP Reward',
                    value: '+${promotion.xpReward} XP',
                    color: AppColors.xpColor,
                  ),
                ],
                if (!promotion.isUpcoming) ...[
                  const SizedBox(height: AppSpacing.m),
                  _buildDetailRow(
                    icon: Icons.people,
                    label: 'Participantes',
                    value: '${promotion.participantCount} personas',
                  ),
                ],
                const SizedBox(height: AppSpacing.l),
                // Description
                Text(
                  'Descripción',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  promotion.description,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.l),
                // Requirements
                Text(
                  'Requisitos',
                  style: AppTextStyles.titleMedium,
                ),
                const SizedBox(height: AppSpacing.s),
                ...promotion.requirements.map((req) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 20,
                          color: AppColors.tertiaryColor,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            req,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.xl),
                // Action Button
                if (!promotion.isExpired)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '¡Te has unido a "${promotion.title}"!',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.m,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_circle),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Participar Ahora',
                          style: AppTextStyles.labelLarge.copyWith(
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
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: color ?? Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          '$label: ',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
