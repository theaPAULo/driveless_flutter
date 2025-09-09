// lib/main.dart
//
// UPDATED: Main.dart with iOS-Style Page Transitions + Haptic Feedback
// ✅ ADDED: Custom iOS-style slide transitions for all navigation
// ✅ ADDED: Smooth, premium page animation experience
// ✅ PRESERVES: All existing functionality and theme setup

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Import providers and services  
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'services/usage_tracking_service.dart';
import 'services/haptic_feedback_service.dart';
import 'services/biometric_auth_service.dart';
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
  await hapticFeedback.initialize();
  
  // Run the app
  runApp(const DriveLessApp());
}

/// ✨ NEW: Custom iOS-Style Page Transition Builder
/// Creates smooth right-to-left slide animations that match iOS native feel
class IOSStylePageTransitionsBuilder extends PageTransitionsBuilder {
  const IOSStylePageTransitionsBuilder();

  @override
  Widget buildTransitions<T extends Object?>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Create smooth slide transition from right to left (iOS style)
    const begin = Offset(1.0, 0.0);  // Start from right edge
    const end = Offset.zero;         // End at center
    const curve = Curves.easeOutCubic; // Smooth, natural curve
    
    // Primary animation (new page sliding in)
    final slideAnimation = Tween(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));
    
    // Secondary animation (previous page sliding out)
    final slideOutAnimation = Tween(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0), // Slight parallax effect
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve,
    ));
    
    // Combine both animations for smooth transition
    return SlideTransition(
      position: slideAnimation,
      child: SlideTransition(
        position: slideOutAnimation,
        child: child,
      ),
    );
  }
}

/// ✨ NEW: Enhanced Theme Data with Custom Page Transitions
/// Extends existing themes with premium page transition animations
class AppThemes {
  // PRESERVED: Original color definitions
  static const primaryGreen = Color(0xFF34C759);
  static const secondaryGreen = Color(0xFF30D158);
  static const darkBackgroundPrimary = Color(0xFF1C1C1E);
  static const darkBackgroundSecondary = Color(0xFF2C2C2E);
  
  // PRESERVED: Original gradient
  static const iOSGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF34C759),
      Color(0xFF8B7355),
    ],
    stops: [0.0, 1.0],
  );

  /// ✨ NEW: Custom Page Transitions Theme
  /// Applies iOS-style transitions across all platforms
  static const pageTransitionsTheme = PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      // Apply iOS-style transitions to all platforms for consistency
      TargetPlatform.android: IOSStylePageTransitionsBuilder(),
      TargetPlatform.iOS: IOSStylePageTransitionsBuilder(),
      TargetPlatform.macOS: IOSStylePageTransitionsBuilder(),
      TargetPlatform.windows: IOSStylePageTransitionsBuilder(),
      TargetPlatform.linux: IOSStylePageTransitionsBuilder(),
    },
  );

  // ENHANCED: Light Theme with Premium Transitions
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // PRESERVED: Original color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
    ),
    
    // PRESERVED: Original scaffold background
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    
    // PRESERVED: Original app bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.black,
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // PRESERVED: Original card theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // ✨ NEW: Add smooth page transitions
    pageTransitionsTheme: pageTransitionsTheme,
  );

  // ENHANCED: Dark Theme with Premium Transitions  
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // PRESERVED: Original color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.dark,
    ),
    
    // PRESERVED: Original scaffold background
    scaffoldBackgroundColor: darkBackgroundPrimary,
    
    // PRESERVED: Original app bar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // PRESERVED: Original card theme
    cardTheme: CardThemeData(
      color: darkBackgroundSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // ✨ NEW: Add smooth page transitions
    pageTransitionsTheme: pageTransitionsTheme,
  );
}

class DriveLessApp extends StatefulWidget {
  const DriveLessApp({super.key});

  @override
  State<DriveLessApp> createState() => _DriveLessAppState();
}

class _DriveLessAppState extends State<DriveLessApp> with TickerProviderStateMixin {
  bool _showInitialLoading = true;
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Keep scale at 1.0 (no scaling)
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.0,
    ).animate(_transitionController);
    
    // Simple fade out effect
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _onInitialLoadingComplete() async {
    // Start scale + fade out animation
    await _transitionController.forward();
    
    // Switch to main app content after animation completes
    if (mounted) {
      setState(() {
        _showInitialLoading = false;
      });
    }
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
        
        // Haptic Feedback Provider
        ChangeNotifierProvider<HapticFeedbackService>.value(
          value: hapticFeedback,
        ),
        
        // Biometric Authentication Provider
        ChangeNotifierProvider<BiometricAuthService>.value(
          value: biometricAuth,
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
            
            // ✨ ENHANCED: Premium themes with smooth page transitions
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Simple fade transition for main app
            home: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _showInitialLoading
                  ? AnimatedBuilder(
                      key: const ValueKey('loading'),
                      animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                      builder: (context, child) {
                        return InitialLoadingScreen(
                          onLoadingComplete: _onInitialLoadingComplete,
                          contentOpacity: _fadeAnimation.value,
                        );
                      },
                    )
                  : Selector<AuthProvider, ({bool isLoading, bool isSignedIn})>(
                      key: const ValueKey('main'),
                      selector: (context, authProvider) => (
                        isLoading: authProvider.isLoading,
                        isSignedIn: authProvider.isSignedIn,
                      ),
                      builder: (context, authState, child) {
                        // Show splash screen while checking auth state
                        if (authState.isLoading) {
                          return const SplashScreen();
                        }
                        
                        // Show main app if authenticated, login screen if not
                        return authState.isSignedIn 
                          ? const MainTabView()
                          : const LoginScreen();
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}