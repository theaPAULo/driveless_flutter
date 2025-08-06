// lib/providers/theme_provider.dart
//
// Theme management provider for DriveLess Flutter app
// Handles theme switching, persistence, and matches iOS app design exactly

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options matching iOS app
enum AppThemeMode { 
  system, 
  light, 
  dark 
}

/// Theme provider that manages app-wide theme state and persistence
class ThemeProvider extends ChangeNotifier {
  AppThemeMode _currentTheme = AppThemeMode.dark; // Default to dark like iOS app
  
  AppThemeMode get currentTheme => _currentTheme;
  
  /// Initialize theme provider and load saved preferences
  Future<void> initialize() async {
    await _loadThemePreference();
    notifyListeners();
  }
  
  /// Change theme and persist to SharedPreferences
  Future<void> setTheme(AppThemeMode newTheme) async {
    if (_currentTheme != newTheme) {
      _currentTheme = newTheme;
      await _saveThemePreference();
      _updateSystemUIOverlay();
      notifyListeners();
    }
  }
  
  /// Get the current ThemeMode for MaterialApp
  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('theme_mode') ?? 'dark';
      _currentTheme = AppThemeMode.values.firstWhere(
        (e) => e.name == themeString,
        orElse: () => AppThemeMode.dark,
      );
    } catch (e) {
      print('❌ Error loading theme preference: $e');
      _currentTheme = AppThemeMode.dark; // Fallback to dark
    }
  }
  
  /// Save theme preference to SharedPreferences
  Future<void> _saveThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', _currentTheme.name);
      print('✅ Theme saved: ${_currentTheme.name}');
    } catch (e) {
      print('❌ Error saving theme preference: $e');
    }
  }
  
  /// Update system UI overlay to match theme
  void _updateSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      _currentTheme == AppThemeMode.light 
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light,
    );
  }
}

/// Theme definitions that exactly match the iOS DriveLess app
class AppThemes {
  // iOS DriveLess brand colors
  static const Color primaryGreen = Color(0xFF34C759); // iOS system green
  static const Color secondaryGreen = Color(0xFF2E7D32);
  static const Color trafficOrange = Color(0xFFFF9500); // iOS system orange
  static const Color errorRed = Color(0xFFFF3B30); // iOS system red
  
  /// Light theme matching iOS app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.light,
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: Colors.white,
        background: const Color(0xFFF2F2F7), // iOS light background
        onBackground: Colors.black,
        onSurface: Colors.black,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      
      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      
      // Text themes
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.black,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.black,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Colors.black,
          fontSize: 17,
        ),
        bodyMedium: TextStyle(
          color: Colors.black,
          fontSize: 15,
        ),
      ),
    );
  }
  
  /// Dark theme exactly matching iOS app design
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Color scheme - matches iOS app exactly
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        brightness: Brightness.dark,
        primary: primaryGreen,
        secondary: secondaryGreen,
        surface: const Color(0xFF1C1C1E), // iOS dark card color
        background: Colors.black, // Pure black like iOS app
        onBackground: Colors.white,
        onSurface: Colors.white,
      ),
      
      // Pure black scaffold background (matches iOS app)
      scaffoldBackgroundColor: Colors.black,
      
      // App bar theme - pure black
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      
      // Card theme - iOS dark gray
      cardTheme: const CardThemeData(
        color: Color(0xFF1C1C1E), // iOS dark card color
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      
      // Text themes for dark mode
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Colors.white,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: Colors.white,
          fontSize: 17,
        ),
        bodyMedium: TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }
}

/// Extension methods for easy theme access
extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
    }
  }
  
  String get description {
    switch (this) {
      case AppThemeMode.system:
        return 'Use device theme setting';
      case AppThemeMode.light:
        return 'Light theme';
      case AppThemeMode.dark:
        return 'Dark theme';
    }
  }
  
  IconData get icon {
    switch (this) {
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.light:
        return Icons.brightness_7;
      case AppThemeMode.dark:
        return Icons.brightness_2;
    }
  }
}