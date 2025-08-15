// lib/main.dart
//
// UPDATED: Main.dart with Haptic Feedback Service integration
// ✅ ADDED: Haptic service initialization and provider
// ✅ PRESERVES: All existing functionality

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import providers and services  
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/usage_tracking_service.dart';
import 'services/haptic_feedback_service.dart'; // NEW: Import haptic service
import 'screens/initial_loading_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab_view.dart';

/// Main app entry point
void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize haptic feedback service
  await hapticFeedback.initialize(); // NEW: Initialize haptics
  
  // Run the app
  runApp(const DriveLessApp());
}

class DriveLessApp extends StatefulWidget {
  const DriveLessApp({super.key});

  @override
  State<DriveLessApp> createState() => _DriveLessAppState();
}

class _DriveLessAppState extends State<DriveLessApp> {
  bool _showInitialLoading = true;

  void _onInitialLoadingComplete() {
    setState(() {
      _showInitialLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Theme Provider (initialize first)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        
        // Usage Tracking Provider
        ChangeNotifierProvider(create: (_) => UsageTrackingService()),
        
        // NEW: Haptic Feedback Provider
        ChangeNotifierProvider<HapticFeedbackService>.value(
          value: hapticFeedback,
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Initialize theme provider on first build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              themeProvider.initialize();
            }
          });
          
          return MaterialApp(
            title: 'DriveLess',
            debugShowCheckedModeBanner: false,
            
            // Dynamic theme switching based on provider
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // App routing with initial loading screen
            home: _showInitialLoading
                ? InitialLoadingScreen(
                    onLoadingComplete: _onInitialLoadingComplete,
                  )
                : Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      // Show splash screen while checking auth state
                      if (authProvider.isLoading) {
                        return const SplashScreen();
                      }
                      
                      // Show main app if authenticated, login screen if not
                      return authProvider.isSignedIn 
                        ? const MainTabView()
                        : const LoginScreen();
                    },
                  ),
          );
        },
      ),
    );
  }
}