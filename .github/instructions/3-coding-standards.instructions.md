```instructions
---
applyTo: "**"
---

# Coding Standards and Best Practices

> **Related Instructions**: §1-github-api-reference for GitHub operations | §2-development-workflow for development workflow

## Language Standards

### 1. Code Language: English ONLY

**CRITICAL RULE**: All code must be written in English.

✅ **ALWAYS use English for:**
- Class names
- Method names
- Variable names
- Function names
- Property names
- Parameter names
- Constants
- Enum values
- File names
- Documentation comments (///, //)
- Code comments

❌ **NEVER use Spanish or any other language for:**
- Any code identifiers
- Technical implementation details
- Class/method/variable names

**Examples from the codebase:**

✅ **CORRECT:**
```dart
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _autoModeEnabled = false;
  
  Future<void> loadThemePreference() async { }
  Future<void> toggleTheme() async { }
}
```

❌ **WRONG:**
```dart
class ProveedorDeTema extends ChangeNotifier {
  ThemeMode _modoTema = ThemeMode.system;
  bool _modoAutoActivado = false;
  
  Future<void> cargarPreferenciaDeTema() async { }
  Future<void> alternarTema() async { }
}
```

### 2. User-Facing Text: Spanish

**User-visible text** should be in Spanish (for now, until i18n is implemented):

✅ **Spanish for:**
- UI labels
- Button text
- Screen titles
- Error messages shown to users
- Placeholder text
- Tooltips
- BottomSheet titles
- Dialog messages

**Examples:**

✅ **CORRECT:**
```dart
MenuItemCard(
  icon: Icons.catching_pokemon,
  title: 'Mi CrazyDex',  // User-facing: Spanish OK
  subtitle: 'Tu colección completa de descubrimientos',
  onTap: () { },
)
```

## Naming Conventions

### 1. Classes: UpperCamelCase (PascalCase)

✅ **CORRECT:**
```dart
class ThemeProvider extends ChangeNotifier { }
class UserProfile { }
class StatCard extends StatelessWidget { }
class CrazyDexCollectionScreen extends StatefulWidget { }
class AppColors { }
class AppTextStyles { }
class AppSpacing { }
```

❌ **WRONG:**
```dart
class themeProvider { }
class user_profile { }
class statCard { }
```

### 2. Variables & Methods: lowerCamelCase

✅ **CORRECT:**
```dart
// Variables
String username;
int currentXP;
bool isDarkMode;
ThemeMode themeMode;
List<String> favoriteCategories;
PageController pageController;

// Methods
Future<void> loadThemePreference() async { }
void toggleTheme() { }
String formatCount(int count) { }
Widget buildActionButtons(Reel reel) { }
```

❌ **WRONG:**
```dart
String UserName;  // Wrong: Should be lowerCamelCase
int current_xp;   // Wrong: Don't use snake_case
bool IsDarkMode;  // Wrong: Should start lowercase
```

### 3. Private Members: Prefix with underscore

✅ **CORRECT:**
```dart
class ThemeProvider extends ChangeNotifier {
  // Private constants
  static const String _themeModeKey = 'theme_mode';
  static const String _autoModeKey = 'auto_mode_enabled';
  
  // Private fields
  ThemeMode _themeMode = ThemeMode.system;
  bool _autoModeEnabled = false;
  int _scheduleStartHour = 20;
  
  // Private methods
  void _applyAutoMode() { }
  String _formatHour(int hour) { }
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedFilter = 'Todos';
  List<String> _filters = ['Todos', 'Seguidos', 'Tendencias'];
  PageController _pageController = PageController();
  
  Widget _buildTopBar() { }
  Widget _buildReelItem(Reel reel) { }
  String _formatCount(int count) { }
}
```

### 4. Constants: lowerCamelCase (Dart convention)

✅ **CORRECT:**
```dart
class AppSpacing {
  static const double xxxs = 2.0;
  static const double xs = 8.0;
  static const double m = 16.0;
  static const double minTouchTarget = 48.0;
  static const double radiusSmall = 8.0;
  static const double iconMedium = 24.0;
}

class AppColors {
  static const Color primaryColor = Color(0xFF5E35B1);
  static const Color secondaryColor = Color(0xFFD84315);
  static const Color lightBackground = Color(0xFFFFFBFE);
}
```

❌ **WRONG:**
```dart
static const double MIN_TOUCH_TARGET = 48.0;  // Wrong: Don't use UPPER_SNAKE_CASE
static const Color PRIMARY_COLOR = Color(0xFF5E35B1);  // Wrong format
```

### 5. Private Widget Classes: Prefix with underscore

✅ **CORRECT:**
```dart
class _CustomBottomNavigationBar extends StatelessWidget { }
class _NavBarItem extends StatelessWidget { }
class _ThemeModeOption extends StatelessWidget { }
class _HomeScreenState extends State<HomeScreen> { }
```

### 6. File Names: snake_case

✅ **CORRECT:**
```
theme_provider.dart
user_profile.dart
stat_card.dart
app_colors.dart
app_text_styles.dart
app_spacing.dart
theme_settings_bottom_sheet.dart
crazydex_collection_screen.dart
```

❌ **WRONG:**
```
ThemeProvider.dart
UserProfile.dart
StatCard.dart
AppColors.dart
```

## Code Organization

### 1. File Structure

Every Dart file should follow this order:

```dart
// 1. Imports (grouped)
import 'package:flutter/material.dart';  // Flutter framework
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';  // Third-party packages

import '../models/user_profile.dart';  // Project imports
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/stat_card.dart';

// 2. Class documentation (if needed)
/// Theme Provider - Manages dark mode state and preferences
/// Supports manual, automatic (system), and scheduled theme modes

// 3. Class definition
class ThemeProvider extends ChangeNotifier {
  // 3.1. Constants (static const)
  static const String _themeModeKey = 'theme_mode';
  
  // 3.2. Fields (private first, then public)
  ThemeMode _themeMode = ThemeMode.system;
  bool _autoModeEnabled = false;
  
  // 3.3. Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode { ... }
  
  // 3.4. Public methods
  Future<void> loadThemePreference() async { }
  Future<void> toggleTheme() async { }
  
  // 3.5. Private methods
  void _applyAutoMode() { }
  String _formatHour(int hour) { }
}
```

### 2. Widget Structure

For StatelessWidget/StatefulWidget:

```dart
class ProfileScreen extends StatelessWidget {
  // 1. Constructor with key
  const ProfileScreen({super.key});
  
  // 2. Build method
  @override
  Widget build(BuildContext context) {
    // 2.1. Get data/dependencies
    final profile = UserProfile.getMockProfile();
    
    // 2.2. Return widget tree
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ...
          ],
        ),
      ),
    );
  }
}
```

For StatefulWidget:

```dart
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. State variables
  String _selectedFilter = 'Todos';
  final PageController _pageController = PageController();
  
  // 2. Lifecycle methods
  @override
  void initState() {
    super.initState();
    // Initialize state
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  // 3. Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...
    );
  }
  
  // 4. Helper methods (build methods)
  Widget _buildTopBar() { }
  Widget _buildReelItem(Reel reel) { }
  
  // 5. Event handlers
  void _onTabTapped(int index) { }
  
  // 6. Utility methods
  String _formatCount(int count) { }
}
```

## Theme System Standards

### 1. NEVER Hardcode Colors

❌ **WRONG:**
```dart
Container(
  color: Colors.grey,  // NEVER do this
  child: Text(
    'Hello',
    style: TextStyle(color: Colors.black),  // NEVER do this
  ),
)
```

✅ **CORRECT:**
```dart
Container(
  color: Theme.of(context).colorScheme.surface,
  child: Text(
    'Hello',
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurface,
    ),
  ),
)
```

### 2. Use Theme-Aware Colors from ColorScheme

✅ **ALWAYS use:**
```dart
// From Theme.of(context).colorScheme
colorScheme.primary
colorScheme.secondary
colorScheme.tertiary
colorScheme.surface
colorScheme.surfaceContainerHighest
colorScheme.background
colorScheme.error
colorScheme.onPrimary
colorScheme.onSecondary
colorScheme.onSurface
colorScheme.onBackground
colorScheme.outline
```

✅ **For brand/gamification colors, use AppColors:**
```dart
AppColors.primaryColor
AppColors.secondaryColor
AppColors.goldColor
AppColors.xpColor
AppColors.successColor
AppColors.errorColor
```

### 3. Use Predefined Text Styles

❌ **WRONG:**
```dart
Text(
  'Title',
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  // Don't do this
)
```

✅ **CORRECT:**
```dart
// Use Material Design 3 text styles
Text(
  'Title',
  style: Theme.of(context).textTheme.headlineSmall,
)

// Or use AppTextStyles for consistency
Text(
  'Title',
  style: AppTextStyles.headlineSmall,
)

// Adapt color for theme
Text(
  'Title',
  style: AppTextStyles.headlineSmall.copyWith(
    color: Theme.of(context).colorScheme.onSurface,
  ),
)
```

**Available text styles:**
- `displayLarge`, `displayMedium`, `displaySmall` - Hero sections
- `headlineLarge`, `headlineMedium`, `headlineSmall` - Page titles
- `titleLarge`, `titleMedium`, `titleSmall` - Cards and prominent text
- `bodyLarge`, `bodyMedium`, `bodySmall` - Main content
- `labelLarge`, `labelMedium`, `labelSmall` - Buttons and small labels

### 4. Use AppSpacing Constants

❌ **WRONG:**
```dart
Padding(
  padding: EdgeInsets.all(16.0),  // Don't hardcode spacing
  child: Container(
    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
    // ...
  ),
)
```

✅ **CORRECT:**
```dart
Padding(
  padding: EdgeInsets.all(AppSpacing.m),
  child: Container(
    margin: EdgeInsets.symmetric(
      horizontal: AppSpacing.xs,
      vertical: AppSpacing.s,
    ),
    // ...
  ),
)
```

**Spacing scale (8pt grid):**
- `xxxs = 2.0`
- `xxs = 4.0`
- `xs = 8.0`
- `s = 12.0`
- `m = 16.0` ← Most common
- `l = 24.0`
- `xl = 32.0`
- `xxl = 48.0`
- `xxxl = 64.0`

**Special constants:**
- `AppSpacing.radiusSmall`, `radiusMedium`, `radiusLarge`, `radiusPill`
- `AppSpacing.iconSmall`, `iconMedium`, `iconLarge`
- `AppSpacing.minTouchTarget` (48.0) - For accessibility
- `AppSpacing.cardPadding`, `screenPadding`, `sectionSpacing`

## Code Reusability

### 1. ALWAYS Check for Existing Widgets

Before creating a new widget, **ALWAYS search** if it already exists:

```bash
# Search for existing widget
grep -r "class.*Card extends" lib/widgets/
grep -r "class.*Button extends" lib/widgets/
```

**Existing reusable widgets:**
- `StatCard` - For displaying statistics
- `QuickStatCard` - Compact stat display
- `MenuItemCard` - For menu/settings items
- `ThemeSettingsBottomSheet` - Theme configuration

✅ **ALWAYS ask before creating:**
```
"¿Ya existe un widget similar a lo que necesito? Déjame buscar primero en lib/widgets/"
```

### 2. ALWAYS Check for Existing Utilities

Before implementing utility functions:

**Existing utilities in models:**
- `UserProfile.getMockProfile()` - Mock user data
- `LeaderboardEntry.getMockLeaderboard()` - Mock leaderboard
- Number formatting functions

✅ **Check existing implementations:**
```dart
// Example: Formatting numbers
String _formatCount(int count) {
  if (count >= 1000000) {
    return '${(count / 1000000).toStringAsFixed(1)}M';
  } else if (count >= 1000) {
    return '${(count / 1000).toStringAsFixed(1)}K';
  }
  return count.toString();
}
// If this exists, DON'T create a duplicate
```

### 3. Centralize Common Patterns

✅ **If you implement something useful, make it reusable:**

```dart
// Instead of repeating this pattern:
Container(
  padding: EdgeInsets.all(AppSpacing.m),
  decoration: BoxDecoration(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
  ),
  child: child,
)

// Create a reusable widget:
class RoundedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  
  const RoundedCard({super.key, required this.child, this.padding});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      child: child,
    );
  }
}
```

## Validation Workflow

### Before Writing Any Code

1. ✅ **Search for existing implementations:**
   ```dart
   // Search for similar widgets
   // Search for similar methods
   // Search for similar utilities
   ```

2. ✅ **Check theme system:**
   ```dart
   // Is there a color constant for this?
   // Is there a spacing constant for this?
   // Is there a text style for this?
   ```

3. ✅ **Verify naming follows standards:**
   ```dart
   // Is my class name UpperCamelCase?
   // Are my methods lowerCamelCase?
   // Are my private members prefixed with _?
   // Is everything in ENGLISH?
   ```

4. ✅ **Check if it's reusable:**
   ```dart
   // Will this be used in multiple places?
   // Should this be a separate widget/utility?
   // Can I extract common patterns?
   ```

## Material Design 3 Standards

### 1. Use Material 3 Components

✅ **Prefer Material 3 widgets:**
```dart
// Buttons
FilledButton(onPressed: () {}, child: Text('Primary'))
OutlinedButton(onPressed: () {}, child: Text('Secondary'))
TextButton(onPressed: () {}, child: Text('Tertiary'))

// Cards
Card(
  elevation: AppSpacing.elevationLow,
  child: Padding(
    padding: EdgeInsets.all(AppSpacing.m),
    child: content,
  ),
)

// Bottom sheets
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => YourBottomSheet(),
)
```

### 2. Follow Touch Target Guidelines

✅ **Minimum touch target: 48x48 dp**
```dart
// For buttons
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(64, AppSpacing.minTouchTarget),  // 48dp
  ),
  child: Text('Button'),
)

// For icon buttons
IconButton(
  iconSize: AppSpacing.iconMedium,  // 24dp icon
  // Button itself is 48x48 by default
  onPressed: () {},
  icon: Icon(Icons.settings),
)
```

### 3. Use Proper Elevation

```dart
// Low elevation for cards
elevation: AppSpacing.elevationLow  // 1.0

// Medium elevation for sheets
elevation: AppSpacing.elevationMedium  // 4.0

// High elevation for dialogs
elevation: AppSpacing.elevationHigh  // 8.0

// FAB elevation
elevation: AppSpacing.elevationFAB  // 6.0
```

## Documentation Standards

### 1. Class Documentation

✅ **Document public classes:**
```dart
/// Theme Provider - Manages dark mode state and preferences
/// Supports manual, automatic (system), and scheduled theme modes
class ThemeProvider extends ChangeNotifier {
  // ...
}

/// Reusable stat card for displaying statistics
class StatCard extends StatelessWidget {
  // ...
}
```

### 2. Complex Method Documentation

✅ **Document complex logic:**
```dart
/// Check if dark mode is currently active
/// Returns true for dark mode, false for light mode
/// For system mode, checks platform brightness
bool get isDarkMode {
  if (_themeMode == ThemeMode.dark) return true;
  if (_themeMode == ThemeMode.light) return false;
  
  final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark;
}
```

### 3. Comment Inline When Needed

✅ **Explain non-obvious code:**
```dart
// Handle center FAB (Scan) separately
if (index == 2) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const ARScannerScreen()),
  );
  return;
}

// Overnight schedule (e.g., 20:00 to 07:00)
if (_scheduleStartHour > _scheduleEndHour) {
  shouldBeDark = currentHour >= _scheduleStartHour || currentHour < _scheduleEndHour;
}
```

## Testing Standards

### 1. Test in Both Light and Dark Modes

✅ **ALWAYS verify:**
```dart
// When implementing UI:
// 1. Test in light mode
// 2. Test in dark mode
// 3. Ensure proper contrast
// 4. Verify all colors adapt correctly
```

### 2. Verify Accessibility

✅ **Check:**
- Touch targets are at least 48x48 dp
- Text has sufficient contrast (WCAG AA)
- Interactive elements are clearly visible
- Icons have proper sizes

## Error Handling

### 1. Use try-catch for Async Operations

✅ **CORRECT:**
```dart
Future<void> loadThemePreference() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];
    notifyListeners();
  } catch (e) {
    debugPrint('Error loading theme preference: $e');
  }
}
```

### 2. Provide Fallbacks

✅ **CORRECT:**
```dart
// Network image with error fallback
Image.network(
  reel.thumbnailUrl,
  fit: BoxFit.cover,
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: Colors.grey[800],
      child: const Center(
        child: Icon(Icons.play_circle_outline, size: 80),
      ),
    );
  },
)
```

## Common Patterns in This Codebase

### 1. Screen Structure with SafeArea

```dart
class YourScreen extends StatelessWidget {
  const YourScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Content
          ],
        ),
      ),
    );
  }
}
```

### 2. Using Provider for State

```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    return Widget(
      // Use themeProvider data
    );
  },
)
```

### 3. Gradient Containers

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: AppColors.primaryGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ),
  child: content,
)
```

## Critical Rules Summary

1. ✅ **ALL code identifiers MUST be in ENGLISH**
2. ✅ **User-facing text can be in Spanish**
3. ✅ **NEVER hardcode colors - use Theme.of(context).colorScheme**
4. ✅ **NEVER hardcode spacing - use AppSpacing constants**
5. ✅ **NEVER hardcode text styles - use AppTextStyles or Theme textTheme**
6. ✅ **ALWAYS search for existing widgets/utilities before creating new ones**
7. ✅ **ALWAYS use UpperCamelCase for classes**
8. ✅ **ALWAYS use lowerCamelCase for methods/variables**
9. ✅ **ALWAYS use _ prefix for private members**
10. ✅ **ALWAYS test in both light and dark modes**
11. ✅ **ALWAYS follow Material Design 3 guidelines**
12. ✅ **ALWAYS ensure touch targets are at least 48x48 dp**
13. ✅ **ALWAYS dispose controllers in dispose() method**
14. ✅ **ALWAYS use const constructors when possible**

## Before Every Implementation

Ask yourself:
1. Does this widget/utility already exist?
2. Am I using theme-aware colors?
3. Am I using AppSpacing constants?
4. Are all my identifiers in English?
5. Does this follow Material Design 3?
6. Will this work in both light and dark modes?
7. Is this reusable? Should I make it reusable?
8. Am I following the naming conventions?

If any answer is "no" or "unsure", **STOP** and fix it before proceeding.
