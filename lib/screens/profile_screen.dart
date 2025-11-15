import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../models/user_profile.dart';
import '../widgets/stat_card.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/theme_settings_bottom_sheet.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import 'crazydex_collection_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = UserProfile.getMockProfile();
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.l),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: AppColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: AppSpacing.avatarXLarge,
                      height: AppSpacing.avatarXLarge,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: Center(
                        child: Text(
                          profile.avatarEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Username (use real username from auth)
                    Text(
                      user?.username ?? profile.username,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Email (show authenticated user's email)
                    if (user != null)
                      Text(
                        user.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xs),

                    // Bio
                    Text(
                      profile.bio,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.m),

                    // Level Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.m,
                        vertical: AppSpacing.s,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'Level ${profile.level} Explorer',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Quick Stats
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.m),
                child: Row(
                  children: [
                    Expanded(
                      child: QuickStatCard(
                        value: profile.totalDiscoveries.toString(),
                        label: 'Discoveries',
                        icon: Icons.explore,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: QuickStatCard(
                        value: '${profile.currentXP}',
                        label: 'Total XP',
                        icon: Icons.stars,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.s),
                    Expanded(
                      child: QuickStatCard(
                        value: '${profile.streak}',
                        label: 'Day Streak',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Menu Items
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: AppSpacing.s),
                  MenuItemCard(
                    icon: Icons.catching_pokemon,
                    title: 'Mi CrazyDex',
                    subtitle: 'Tu colección completa de descubrimientos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const CrazyDexCollectionScreen(),
                        ),
                      );
                    },
                  ),
                  MenuItemCard(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    subtitle: 'Update your information',
                    onTap: () {},
                  ),
                  MenuItemCard(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'App preferences and privacy',
                    onTap: () {},
                  ),
                  MenuItemCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage notifications',
                    onTap: () {},
                  ),
                  MenuItemCard(
                    icon: Icons.favorite_outline,
                    title: 'Saved Discoveries',
                    subtitle: 'Your bookmarked places',
                    onTap: () {},
                  ),
                  MenuItemCard(
                    icon: Icons.share_outlined,
                    title: 'Invite Friends',
                    subtitle: 'Share Crazy Trip with others',
                    onTap: () {},
                  ),
                  MenuItemCard(
                    icon: Icons.info_outline,
                    title: 'About',
                    subtitle: 'Learn more about Crazy Trip',
                    onTap: () {},
                  ),
                  MenuItemCard(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'Get assistance',
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.l),

                  // Theme Settings Card
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return MenuItemCard(
                        icon:
                            themeProvider.isDarkMode
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                        title: 'Appearance',
                        subtitle:
                            'Theme: ${themeProvider.themeModeDescription}',
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        onTap: () {
                          ThemeSettingsBottomSheet.show(context);
                        },
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.m),

                  // Logout Button
                  Consumer<AuthProvider>(
                    builder: (context, auth, _) {
                      return OutlinedButton.icon(
                        onPressed:
                            auth.isLoading
                                ? null
                                : () async {
                                  final shouldLogout = await showDialog<bool>(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text('Cerrar sesión'),
                                          content: const Text(
                                            '¿Estás seguro de que quieres cerrar sesión?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: const Text(
                                                'Cerrar sesión',
                                              ),
                                            ),
                                          ],
                                        ),
                                  );

                                  if (shouldLogout == true && context.mounted) {
                                    await auth.logout();
                                  }
                                },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorColor,
                          side: const BorderSide(color: AppColors.errorColor),
                        ),
                        icon:
                            auth.isLoading
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.logout),
                        label: const Text('Cerrar Sesión'),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.l),

                  // Version Info
                  Center(
                    child: Text(
                      'Crazy Trip v1.0.0',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.m),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
