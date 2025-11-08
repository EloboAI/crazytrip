import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/promotion.dart';
import '../models/user_profile.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    final profile = UserProfile.getMockProfile();
    final allPromotions = getMockPromotions();

    // Filtrar promociones por estado
    final activePromotions = allPromotions
        .where((p) =>
            p.isActive && (p.isParticipating || p.type == PromotionType.discount))
        .toList();

    final wonPromotions =
        allPromotions.where((p) => p.hasWon && !p.isClaimed).toList();

    final historyPromotions =
        allPromotions.where((p) => p.isClaimed || (p.isExpired && p.isParticipating)).toList();

    // Estadísticas
    final totalWon = allPromotions.where((p) => p.hasWon).length;
    final activeDiscounts =
        activePromotions.where((p) => p.type == PromotionType.discount).length;
    final unclaimedPrizes = wonPromotions.length;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header con estadísticas
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.discoveryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mis Premios',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (unclaimedPrizes > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.m,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.goldColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '$unclaimedPrizes nuevo${unclaimedPrizes != 1 ? 's' : ''}',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.m),
                  // Cards de estadísticas
                  Row(
                    children: [
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.emoji_events,
                          value: totalWon.toString(),
                          label: 'Ganados',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.local_offer,
                          value: activeDiscounts.toString(),
                          label: 'Descuentos',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Expanded(
                        child: _QuickStatCard(
                          icon: Icons.stars,
                          value: profile.currentXP.toString(),
                          label: 'Total XP',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(
                      0.2,
                    ),
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primaryColor,
                unselectedLabelColor: Theme.of(context).colorScheme.outline,
                indicatorColor: AppColors.primaryColor,
                labelStyle: AppTextStyles.labelLarge,
                tabs: [
                  Tab(
                    text:
                        'Activos${activePromotions.isNotEmpty ? ' (${activePromotions.length})' : ''}',
                  ),
                  Tab(
                    text:
                        'Ganados${unclaimedPrizes > 0 ? ' ($unclaimedPrizes)' : ''}',
                  ),
                  const Tab(text: 'Historial'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab Activos
                  _ActivePromotionsTab(promotions: activePromotions),

                  // Tab Ganados
                  _WonPromotionsTab(promotions: wonPromotions),

                  // Tab Historial
                  _HistoryTab(promotions: historyPromotions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tab de promociones activas
class _ActivePromotionsTab extends StatelessWidget {
  final List<Promotion> promotions;

  const _ActivePromotionsTab({required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return _EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Sin promociones activas',
        message: 'Explora el mapa para encontrar descuentos y concursos',
        actionLabel: 'Explorar Mapa',
        onAction: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        return _PromotionCard(promotion: promotions[index]);
      },
    );
  }
}

// Tab de premios ganados
class _WonPromotionsTab extends StatelessWidget {
  final List<Promotion> promotions;

  const _WonPromotionsTab({required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return const _EmptyState(
        icon: Icons.card_giftcard,
        title: 'No tienes premios pendientes',
        message: 'Participa en concursos para ganar premios increíbles',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        return _PrizeCard(promotion: promotions[index]);
      },
    );
  }
}

// Tab de historial
class _HistoryTab extends StatelessWidget {
  final List<Promotion> promotions;

  const _HistoryTab({required this.promotions});

  @override
  Widget build(BuildContext context) {
    if (promotions.isEmpty) {
      return const _EmptyState(
        icon: Icons.history,
        title: 'Sin historial',
        message: 'Tu historial de premios aparecerá aquí',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.m),
      itemCount: promotions.length,
      itemBuilder: (context, index) {
        return _HistoryCard(promotion: promotions[index]);
      },
    );
  }
}

// Widget para estadísticas rápidas
class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _QuickStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: AppSpacing.iconMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: AppTextStyles.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Card de promoción activa
class _PromotionCard extends StatelessWidget {
  final Promotion promotion;

  const _PromotionCard({required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono de tipo
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSmall,
                      ),
                    ),
                    child: Text(
                      promotion.type.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  // Información
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promotion.title,
                          style: AppTextStyles.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          promotion.location,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Badge de estado
                  _StatusBadge(promotion: promotion),
                ],
              ),
              const SizedBox(height: AppSpacing.m),
              Text(
                promotion.description,
                style: AppTextStyles.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (promotion.userProgress > 0) ...[
                const SizedBox(height: AppSpacing.m),
                _ProgressIndicator(promotion: promotion),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Card de premio ganado
class _PrizeCard extends StatelessWidget {
  final Promotion promotion;

  const _PrizeCard({required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      elevation: 4,
      color: AppColors.goldColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        side: BorderSide(color: AppColors.goldColor.withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        onTap: () => _showClaimDialog(context, promotion),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.m),
          child: Column(
            children: [
              Row(
                children: [
                  // Icono de trofeo
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.goldColor, Colors.amber.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  // Información del premio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¡Felicidades!',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.goldColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          promotion.title,
                          style: AppTextStyles.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Row(
                          children: [
                            const Icon(
                              Icons.card_giftcard,
                              size: 16,
                              color: AppColors.goldColor,
                            ),
                            const SizedBox(width: AppSpacing.xxs),
                            Expanded(
                              child: Text(
                                promotion.prize,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.goldColor,
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
              const SizedBox(height: AppSpacing.m),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showClaimDialog(context, promotion),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldColor,
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
                    'Reclamar Premio',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClaimDialog(BuildContext context, Promotion promotion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 ¡Reclamar Premio!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              promotion.title,
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.s),
            Text('Premio: ${promotion.prize}'),
            const SizedBox(height: AppSpacing.m),
            const Text(
              'Visita el lugar indicado y muestra este código:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: AppSpacing.s),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                'CRAZY-${promotion.id.toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Marcar como Usado'),
          ),
        ],
      ),
    );
  }
}

// Card de historial
class _HistoryCard extends StatelessWidget {
  final Promotion promotion;

  const _HistoryCard({required this.promotion});

  @override
  Widget build(BuildContext context) {
    final isClaimed = promotion.isClaimed;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.s),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(AppSpacing.s),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
              ),
              child: Text(
                promotion.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promotion.title,
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    isClaimed
                        ? 'Usado: ${_formatDate(promotion.claimedAt ?? promotion.endDate)}'
                        : 'Expirado: ${_formatDate(promotion.endDate)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            // Estado
            Icon(
              isClaimed ? Icons.check_circle : Icons.cancel,
              color: isClaimed ? AppColors.successColor : Colors.grey,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Badge de estado
class _StatusBadge extends StatelessWidget {
  final Promotion promotion;

  const _StatusBadge({required this.promotion});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;

    if (promotion.daysRemaining <= 1) {
      color = AppColors.errorColor;
      text = '${promotion.hoursRemaining}h';
    } else if (promotion.daysRemaining <= 3) {
      color = AppColors.warningColor;
      text = '${promotion.daysRemaining}d';
    } else {
      color = AppColors.successColor;
      text = '${promotion.daysRemaining}d';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Indicador de progreso
class _ProgressIndicator extends StatelessWidget {
  final Promotion promotion;

  const _ProgressIndicator({required this.promotion});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progreso',
              style: AppTextStyles.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            Text(
              '${promotion.userProgress}/${promotion.requirements.length}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
          child: LinearProgressIndicator(
            value: promotion.userProgress / promotion.requirements.length,
            minHeight: 6,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

// Estado vacío
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.m),
            Text(
              title,
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.l),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.l,
                    vertical: AppSpacing.m,
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
