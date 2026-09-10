import 'package:cgpa_calculator/screens/main_navigation.dart';
import 'package:flutter/material.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const CGPACalculatorApp());
}

class CGPACalculatorApp extends StatelessWidget {
  const CGPACalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CGPA Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system, //
      theme: AppTheme.lightTheme, //
      darkTheme: AppTheme.darkTheme, //
      home: const MainNavigation(),
    );
  }
}