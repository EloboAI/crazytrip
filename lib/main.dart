import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('⚠️ No se pudo cargar .env: $e');
  }

  // Validaciones mínimas (solo logging, no detiene arranque)
  final mapsKey = dotenv.maybeGet('GOOGLE_MAPS_API_KEY');
  final visionKey = dotenv.maybeGet('GOOGLE_VISION_API_KEY');
  if (mapsKey == null || mapsKey.isEmpty) {
    debugPrint('⚠️ GOOGLE_MAPS_API_KEY ausente o vacío.');
  }
  if (visionKey == null || visionKey.isEmpty) {
    debugPrint('⚠️ GOOGLE_VISION_API_KEY ausente o vacío.');
  }

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.loadThemePreference();

  runApp(CrazyTripApp(themeProvider: themeProvider));
}

class CrazyTripApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const CrazyTripApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Crazy Trip',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: theme.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, auth, _) {
                // Show loading only during initial auth check
                if (auth.isInitializing) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // Show login if not authenticated
                if (!auth.isAuthenticated) {
                  return const LoginScreen();
                }

                // Show main app if authenticated
                return const MainScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
