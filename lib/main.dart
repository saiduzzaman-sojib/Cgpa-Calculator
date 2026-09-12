import 'package:cgpa_calculator/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_theme.dart';
import 'screens/main_navigation.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  runApp(CgpaCalculatorApp(isLoggedIn: isLoggedIn));
}

class CgpaCalculatorApp extends StatelessWidget {
  final bool isLoggedIn;
  const CgpaCalculatorApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'CGPA Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: isLoggedIn ? const MainNavigation() : SplashScreen(),
        );
      },
    );
  }
}