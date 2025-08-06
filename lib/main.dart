// lib/main.dart
//
// CORRECTED: Main app entry point with proper import paths
// Now imports MainTabView from screens directory

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import providers and services
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab_view.dart'; // ✅ FIXED: Import MainTabView from screens/

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
        // Theme Provider (initialize first)
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        
        // Authentication Provider
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
            
            // App routing
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                // Show splash screen while checking auth state
                if (authProvider.isLoading) {
                  return const SplashScreen();
                }
                
                // Show main app if authenticated, login screen if not
                return authProvider.isSignedIn 
                  ? const MainTabView() // ✅ FIXED: Use MainTabView instead of individual screens
                  : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}