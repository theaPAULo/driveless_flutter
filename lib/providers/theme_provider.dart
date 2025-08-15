// lib/providers/theme_provider.dart
//
// UPDATED: Theme management provider with EXACT iOS gradient colors
// ✅ IMPROVED: Perfect color matching from iOS app
// ✅ IMPROVED: Added gradient utility methods for easy reuse
// ✅ IMPROVED: Enhanced color constants for consistency

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
  // EXACT iOS DriveLess gradient colors (converted from SwiftUI RGB values)
  static const Color deepForestGreen = Color.fromRGBO(33, 69, 33, 1.0);   // iOS: 0.13, 0.27, 0.13
  static const Color primaryGreen = Color.fromRGBO(51, 102, 51, 1.0);     // iOS: 0.2, 0.4, 0.2
  static const Color oliveGreen = Color.fromRGBO(128, 153, 102, 1.0);     // iOS: 0.5, 0.6, 0.4
  static const Color richBrown = Color.fromRGBO(102, 77, 51, 1.0);        // iOS: 0.4, 0.3, 0.2
  
  // Additional brand colors for UI elements
  static const Color systemGreen = Color(0xFF34C759);      // iOS system green for buttons
  static const Color secondaryGreen = Color(0xFF2E7D32);   // Secondary actions
  static const Color trafficOrange = Color(0xFFFF9500);    // iOS system orange
  static const Color errorRed = Color(0xFFFF3B30);         // iOS system red
  
  /// EXACT iOS gradient for splash/welcome screens
  static const LinearGradient iOSGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      deepForestGreen,    // Deep forest green
      primaryGreen,       // Primary green  
      oliveGreen,         // Olive green
      richBrown,          // Rich brown
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
  );
  
  /// Alternative gradient for different screens (to add visual variety)
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      deepForestGreen,
      primaryGreen,
      oliveGreen,
      richBrown,
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
  );
  
  /// Light gradient for light theme
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF66BB6A),  // Light green
      Color(0xFF81C784),  // Lighter green
      Color(0xFFA5D6A7),  // Very light green
      Color(0xFFD7CCC8),  // Light brown
    ],
    stops: [0.0, 0.33, 0.66, 1.0],
  );

  /// Light theme matching iOS app
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: systemGreen,
        brightness: Brightness.light,
        primary: systemGreen,
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
        backgroundColor: systemGreen,
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
          backgroundColor: systemGreen,
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
        seedColor: systemGreen,
        brightness: Brightness.dark,
        primary: systemGreen,
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
          backgroundColor: systemGreen,
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