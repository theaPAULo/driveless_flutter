// lib/services/haptic_feedback_service.dart
//
// Comprehensive Haptic Feedback Service - Matches iOS HapticManager
// ✅ Multiple haptic types with iOS-style feedback
// ✅ User preference toggle (can be disabled in settings)
// ✅ Convenience methods for common actions
// ✅ Special celebration haptics for route completion

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Haptic feedback types matching iOS implementation
enum HapticType {
  light,        // Light impact - button taps, toggles
  medium,       // Medium impact - important actions
  heavy,        // Heavy impact - major actions
  success,      // Success notification - route complete
  warning,      // Warning notification - alerts
  error,        // Error notification - failures
  selection,    // Selection change - menu navigation
  routeComplete,// Special celebration - double success
  buttonTap,    // Convenience for button presses
}

/// Comprehensive haptic feedback service
class HapticFeedbackService extends ChangeNotifier {
  static final HapticFeedbackService _instance = HapticFeedbackService._internal();
  factory HapticFeedbackService() => _instance;
  HapticFeedbackService._internal();

  bool _isEnabled = true;
  bool get isEnabled => _isEnabled;

  /// Initialize the service and load user preferences
  Future<void> initialize() async {
    await _loadHapticPreference();
  }

  /// Enable or disable haptic feedback
  Future<void> setEnabled(bool enabled) async {
    if (_isEnabled != enabled) {
      _isEnabled = enabled;
      await _saveHapticPreference();
      notifyListeners();
      
      // Give feedback when enabling haptics
      if (enabled) {
        _performHaptic(HapticType.light);
      }
    }
  }

  /// Main method to trigger haptic feedback
  Future<void> impact(HapticType type) async {
    if (!_isEnabled) return;
    await _performHaptic(type);
  }

  // MARK: - Convenience Methods (matching iOS)

  /// Light haptic for button taps
  Future<void> buttonTap() async => await impact(HapticType.buttonTap);

  /// Success haptic for completed actions
  Future<void> success() async => await impact(HapticType.success);

  /// Error haptic for failed operations
  Future<void> error() async => await impact(HapticType.error);

  /// Warning haptic for alerts
  Future<void> warning() async => await impact(HapticType.warning);

  /// Selection haptic for menu navigation
  Future<void> menuNavigation() async => await impact(HapticType.selection);

  /// Light haptic for toggle switches
  Future<void> toggle() async => await impact(HapticType.light);

  /// Special celebration haptic for route completion
  Future<void> routeComplete() async => await impact(HapticType.routeComplete);

  /// Medium haptic for important actions
  Future<void> importantAction() async => await impact(HapticType.medium);

  /// Heavy haptic for major actions (like deleting)
  Future<void> majorAction() async => await impact(HapticType.heavy);

  // MARK: - Private Methods

/// Perform the actual haptic feedback
  Future<void> _performHaptic(HapticType type) async {
    try {
      switch (type) {
        case HapticType.light:
        case HapticType.buttonTap:
          await HapticFeedback.lightImpact();
          break;

        case HapticType.medium:
          await HapticFeedback.mediumImpact();
          break;

        case HapticType.heavy:
          await HapticFeedback.heavyImpact();
          break;

        case HapticType.success:
          // iOS-style: Use selection for success (closest equivalent)
          await HapticFeedback.selectionClick();
          break;

        case HapticType.warning:
          // Medium impact for warnings
          await HapticFeedback.mediumImpact();
          break;

        case HapticType.error:
          // Heavy impact for errors
          await HapticFeedback.heavyImpact();
          break;

        case HapticType.selection:
          await HapticFeedback.selectionClick();
          break;

        case HapticType.routeComplete:
          // Special celebration: double success haptic
          await HapticFeedback.selectionClick();
          await Future.delayed(const Duration(milliseconds: 100));
          await HapticFeedback.selectionClick();
          break;
      }
    } catch (e) {
      // Haptic feedback might not be available on all devices
      if (kDebugMode) {
        print('❌ Haptic feedback error: $e');
      }
    }
  }

  /// Load haptic preference from SharedPreferences
  Future<void> _loadHapticPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool('haptics_enabled') ?? true; // Default to enabled
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading haptic preference: $e');
      }
      _isEnabled = true; // Fallback to enabled
    }
  }

  /// Save haptic preference to SharedPreferences
  Future<void> _saveHapticPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('haptics_enabled', _isEnabled);
      if (kDebugMode) {
        print('✅ Haptic preference saved: $_isEnabled');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error saving haptic preference: $e');
      }
    } 
  }
}

/// Global instance for easy access throughout the app
final hapticFeedback = HapticFeedbackService();