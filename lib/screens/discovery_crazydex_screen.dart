import 'package:flutter/material.dart';
import '../models/crazydex_item.dart';
import '../models/discovery.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Screen showing CrazyDex items available at a specific Discovery
class DiscoveryCrazyDexScreen extends StatelessWidget {
  final Discovery discovery;

  const DiscoveryCrazyDexScreen({super.key, required this.discovery});

  @override
  Widget build(BuildContext context) {
    // Get items for this discovery
    final items = getCrazyDexItemsForDiscovery(discovery.id);
    final discovered = items.where((item) => item.isDiscovered).toList();
    final locked = items.where((item) => !item.isDiscovered).toList();

    return Scaffold(
      appBar: AppBar(title: Text('CrazyDex - ${discovery.name}')),
      body:
          items.isEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.l),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: AppSpacing.m),
                      Text(
                        'No hay items CrazyDex en este lugar',
                        style: AppTextStyles.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.s),
                      Text(
                        'Otros usuarios aún no han identificado nada aquí',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : ListView(
                padding: EdgeInsets.all(AppSpacing.m),
                children: [
                  // Header with stats
                  _buildStatsCard(items.length, discovered.length),
                  SizedBox(height: AppSpacing.l),

                  // Discovered items
                  if (discovered.isNotEmpty) ...[
                    _buildSectionHeader('Descubiertos', discovered.length),
                    SizedBox(height: AppSpacing.m),
                    ...discovered.map(
                      (item) => _buildDiscoveredItemCard(context, item),
                    ),
                    SizedBox(height: AppSpacing.l),
                  ],

                  // Locked items
                  if (locked.isNotEmpty) ...[
                    _buildSectionHeader('Por descubrir', locked.length),
                    SizedBox(height: AppSpacing.m),
                    ...locked.map(
                      (item) => _buildLockedItemCard(context, item),
                    ),
                  ],

                  SizedBox(height: AppSpacing.xl),

                  // Call to action
                  _buildCallToAction(context),
                ],
              ),
    );
  }

  Widget _buildStatsCard(int total, int discovered) {
    final percentage = total > 0 ? (discovered / total * 100).round() : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', total.toString(), Icons.list),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatItem(
                  'Descubiertos',
                  discovered.toString(),
                  Icons.check_circle,
                ),
                Container(width: 1, height: 40, color: Colors.grey.shade300),
                _buildStatItem('Progreso', '$percentage%', Icons.emoji_events),
              ],
            ),
            SizedBox(height: AppSpacing.m),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total > 0 ? discovered / total : 0,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.secondaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 28),
        SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
        ),
      ],
    );
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

  Widget _buildDiscoveredItemCard(BuildContext context, CrazyDexItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.m),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to item detail
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.m),
          child: Row(
            children: [
              // Image/Emoji
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(item.imageUrl, style: TextStyle(fontSize: 32)),
                ),
              ),
              SizedBox(width: AppSpacing.m),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.check_circle, color: Colors.green, size: 20),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xxs),
                    Text(item.rarityStars, style: TextStyle(fontSize: 12)),
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
                                item.category.displayName == 'Fauna'
                                    ? Colors.green.withOpacity(0.1)
                                    : item.category.displayName == 'Flora'
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.category.displayName,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.s),
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        SizedBox(width: 2),
                        Text(
                          '+${item.xpReward} XP',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockedItemCard(BuildContext context, CrazyDexItem item) {
    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.m),
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.m),
        child: Row(
          children: [
            // Locked icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.lock, size: 32, color: Colors.grey),
            ),
            SizedBox(width: AppSpacing.m),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '???',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  Text(item.rarityStars, style: TextStyle(fontSize: 12)),
                  SizedBox(height: AppSpacing.xxs),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.category.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.s),
                      Icon(Icons.star, size: 12, color: Colors.grey),
                      SizedBox(width: 2),
                      Text(
                        '+${item.xpReward} XP',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Icon(Icons.help_outline, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    return Card(
      color: AppColors.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.m),
        child: Column(
          children: [
            Icon(Icons.camera_alt, size: 48, color: AppColors.primaryColor),
            SizedBox(height: AppSpacing.m),
            Text(
              '¡Usa tu cámara para identificar!',
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s),
            Text(
              'Toma fotos de lo que encuentres en este lugar y nuestra IA los identificará para desbloquearlos en tu CrazyDex.',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.m),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Open camera in SCAN mode
                Navigator.pop(context);
              },
              icon: Icon(Icons.camera_alt),
              label: Text('Abrir Cámara'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.l,
                  vertical: AppSpacing.m,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
