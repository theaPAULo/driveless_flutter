// lib/main.dart
//
// Main app entry point for DriveLess Flutter app
// Now with Firebase initialization, AuthProvider, and iOS-matching green gradient UI

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import our providers and main navigation
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab_view.dart';

/// Main app entry point
void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Run the app
  runApp(const DriveLessApp());
}

class DriveLessApp extends StatelessWidget {
  const DriveLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'DriveLess',
        debugShowCheckedModeBanner: false,
        
        // Light theme with green branding
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          
          // DriveLess green color scheme
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          
          // App bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
          
          // Elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25), // More rounded like iOS
              ),
              elevation: 2,
            ),
          ),
          
          // Card theme
          cardTheme: CardThemeData(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
        ),
        
        // Dark theme to match iOS app design
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          
          // Dark color scheme with green accents
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            brightness: Brightness.dark,
          ),
          
          // Dark app bar
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: false,
          ),
          
          // Dark elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
          
          // Dark card theme
          cardTheme: const CardThemeData(
            color: Color(0xFF2C2C2E),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
          
          // Dark background
          scaffoldBackgroundColor: Colors.black,
        ),
        
        // Use dark theme by default to match iOS app
        themeMode: ThemeMode.dark,
        
        // Set up routing with authentication check
        home: const AuthenticationWrapper(),
      ),
    );
  }
}

/// Authentication wrapper - determines which screen to show based on auth state
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Show loading screen during authentication check
        if (authProvider.isLoading) {
          return const SplashScreen();
        }
        
        // Show main app if signed in, login screen if not
        if (authProvider.isSignedIn) {
          return const MainTabView();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}