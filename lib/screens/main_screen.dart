import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'explore_screen.dart';
import 'map_screen.dart';
import 'ar_scanner_screen.dart';
import 'achievements_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    // Handle center FAB separately
    if (index == 2) {
      // Navigate to AR Scanner as full screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ARScannerScreen()),
      );
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index:
            _currentIndex == 2
                ? 0
                : _currentIndex > 2
                ? _currentIndex - 1
                : _currentIndex,
        children: const [
          ExploreScreen(),
          MapScreen(),
          AchievementsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton:
          _currentIndex != 2
              ? FloatingActionButton(
                onPressed: () => _onTabTapped(2),
                backgroundColor: AppColors.primaryColor,
                elevation: AppSpacing.elevationFAB,
                child: const Icon(Icons.camera_alt, size: AppSpacing.iconLarge),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        height: AppSpacing.bottomNavHeight,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavBarItem(
              icon: Icons.explore_outlined,
              activeIcon: Icons.explore,
              label: 'Explore',
              isActive: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            _NavBarItem(
              icon: Icons.map_outlined,
              activeIcon: Icons.map,
              label: 'Map',
              isActive: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Spacer for FAB
            const SizedBox(width: AppSpacing.minTouchTarget),
            _NavBarItem(
              icon: Icons.emoji_events_outlined,
              activeIcon: Icons.emoji_events,
              label: 'Achievements',
              isActive: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            _NavBarItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person,
              label: 'Profile',
              isActive: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.outline;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: AppSpacing.iconMedium,
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
