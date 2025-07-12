import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/task_provider.dart';
import 'models/settings.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // Initialize Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable animations
  Animate.restartOnHotReload = true;
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  final settings = AppSettings();
  await settings.loadSettings(prefs);
  
  // Run the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: const TaskMasterApp(),
    ),
  );
}

class TaskMasterApp extends StatelessWidget {
  const TaskMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        return MaterialApp(
          title: 'TaskMaster',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme.copyWith(
            useMaterial3: true,
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF64B5F6), // Light Blue 300
              secondary: Color(0xFF4FC3F7), // Light Blue 200
              surface: Color(0xFF121212),
              background: Color(0xFF121212),
              error: Color(0xFFCF6679),
              onPrimary: Colors.black,
              onSecondary: Colors.black,
              onBackground: Colors.white,
              onSurface: Colors.white,
              onError: Colors.black,
              brightness: Brightness.dark,
            ),
            dialogTheme: DialogTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              contentTextStyle: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16.0,
              ),
            ),
          ),
          themeMode: settings.themeMode,
          home: const HomeScreen(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
