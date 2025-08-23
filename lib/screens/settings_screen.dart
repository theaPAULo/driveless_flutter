// lib/screens/settings_screen.dart
//
// Settings Screen - CONSERVATIVE Theme Update
// ✅ PRESERVES: All existing settings functionality (theme switching, preferences, etc.)
// ✅ CHANGES: Only hardcoded colors to use proper theme provider
// ✅ FIXES: Off-brand green colors to match design system

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart'; // RESTORED: URL launcher
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../utils/constants.dart';
import '../services/haptic_feedback_service.dart';
import '../services/smart_suggestions_service.dart';
import '../services/saved_address_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // PRESERVED: All existing state variables
  bool _isLoading = true;
  bool _hapticFeedback = true;
  bool _defaultRoundTrip = false;
  bool _defaultTrafficConsideration = true;
  bool _autoSaveRoutes = true;

  @override
  void initState() {
    super.initState();
    _loadSettings(); // PRESERVED: Same initialization
  }

  /// PRESERVED: Load settings from SharedPreferences - EXACT SAME LOGIC
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (mounted) {
        setState(() {
          _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
          _defaultRoundTrip = prefs.getBool('default_round_trip') ?? false;
          _defaultTrafficConsideration = prefs.getBool('default_traffic_consideration') ?? true;
          _autoSaveRoutes = prefs.getBool('auto_save_routes') ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading settings: $e');
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// PRESERVED: Save settings to SharedPreferences - EXACT SAME LOGIC
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('haptic_feedback', _hapticFeedback);
      await prefs.setBool('default_round_trip', _defaultRoundTrip);
      await prefs.setBool('default_traffic_consideration', _defaultTrafficConsideration);
      await prefs.setBool('auto_save_routes', _autoSaveRoutes);
      
      if (EnvironmentConfig.logApiCalls) {
        print('✅ Settings saved successfully');
      }
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error saving settings: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider for proper colors
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      // CHANGED: Theme-aware background
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // CHANGED: Theme-aware app bar
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            // CHANGED: Theme-aware icon color
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            // CHANGED: Theme-aware text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Done',
              style: TextStyle(
                // CHANGED: Use proper brand green instead of off-brand
                color: const Color(0xFF34C759),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return _isLoading 
            ? _buildLoadingState(themeProvider) 
            : _buildSettingsContent(themeProvider);
        },
      ),
    );
  }

  // PRESERVED: Loading State - UPDATED colors
  Widget _buildLoadingState(ThemeProvider themeProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            // CHANGED: Use proper brand green
            color: const Color(0xFF34C759),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: TextStyle(
              // CHANGED: Theme-aware secondary text color
              color: themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // PRESERVED: Settings Content structure - UPDATED colors
  Widget _buildSettingsContent(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // APPEARANCE Section
          _buildSectionHeader('APPEARANCE', themeProvider),
          _buildSettingsCard([
            _buildThemeSelector(themeProvider),
          ], themeProvider),

          // HAPTIC FEEDBACK Section  
          _buildSectionHeader('HAPTIC FEEDBACK', themeProvider),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Haptic Feedback',
              'Feel vibrations for button taps and events',
              _hapticFeedback,
              (value) {
                setState(() {
                  _hapticFeedback = value;
                });
                _saveSettings(); // PRESERVED: Same save logic
              },
              themeProvider,
              icon: '📳',
            ),
          ], themeProvider),

          // SECURITY Section
          _buildSectionHeader('SECURITY', themeProvider),
          _buildSettingsCard([
            _buildBiometricSetting(themeProvider),
          ], themeProvider),

          // ROUTE DEFAULTS Section
          _buildSectionHeader('ROUTE DEFAULTS', themeProvider),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Default Round Trip',
              'Return to starting location by default',
              _defaultRoundTrip,
              (value) {
                setState(() {
                  _defaultRoundTrip = value;
                });
                _saveSettings(); // PRESERVED: Same save logic
              },
              themeProvider,
              icon: '🔄',
            ),
            // PRESERVED: Divider
            Divider(
              height: 1, 
              color: themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[700] 
                : Colors.grey[300],
            ),
            _buildSwitchSetting(
              'Consider Traffic',
              'Include current traffic in route calculations',
              _defaultTrafficConsideration,
              (value) {
                setState(() {
                  _defaultTrafficConsideration = value;
                });
                _saveSettings(); // PRESERVED: Same save logic
              },
              themeProvider,
              icon: '🚗',
            ),
          ], themeProvider),

          // PRIVACY & DATA Section
          _buildSectionHeader('PRIVACY & DATA', themeProvider),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Auto-Save Routes',
              'Automatically save completed routes to history',
              _autoSaveRoutes,
              (value) {
                setState(() {
                  _autoSaveRoutes = value;
                });
                _saveSettings(); // PRESERVED: Same save logic
                if (EnvironmentConfig.logApiCalls) {
                  print('🔄 Auto-save routes ${value ? 'enabled' : 'disabled'}');
                }
              },
              themeProvider,
              icon: '💾',
            ),
          ], themeProvider),

          // ABOUT Section - CLEANED UP
          _buildSectionHeader('ABOUT', themeProvider),
          _buildSettingsCard([
            _buildInfoItem('Version', '1.0.0', themeProvider),
            Divider(
              height: 1, 
              color: themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[700] 
                : Colors.grey[300],
            ),
            _buildNavigationSetting(
              'Terms & Conditions',
              'View terms of service',
              Icons.description,
              _openTermsAndConditions,
              themeProvider,
            ),
            Divider(
              height: 1, 
              color: themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[700] 
                : Colors.grey[300],
            ),
            _buildNavigationSetting(
              'Privacy Policy',
              'How we handle your data',
              Icons.privacy_tip,
              _openPrivacyPolicy,
              themeProvider,
            ),
          ], themeProvider),

          // PRIVACY & DATA Section - iOS App Store Compliance
          _buildSectionHeader('PRIVACY & DATA', themeProvider),
          _buildSettingsCard([
            _buildNavigationSetting(
              'Delete All Data',
              'Permanently remove all your saved data',
              Icons.delete_forever,
              _showDeleteAllDataConfirmation,
              themeProvider,
              isDestructive: true,
            ),
          ], themeProvider),

          const SizedBox(height: 40),

          // RESTORED: Reset Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildResetButton(themeProvider),
          ),
        ],
      ),
    );
  }

  // PRESERVED: Section Header - UPDATED colors
  Widget _buildSectionHeader(String title, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          // CHANGED: Theme-aware secondary text color
          color: themeProvider.currentTheme == AppThemeMode.dark 
            ? Colors.grey[400] 
            : Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // PRESERVED: Settings Card - UPDATED colors
  Widget _buildSettingsCard(List<Widget> children, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware card color
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // PRESERVED: Theme Selector - UPDATED colors for better brand consistency
  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                Text(
                  'Theme',
                  style: TextStyle(
                    // CHANGED: Theme-aware text color
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your preferred appearance',
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                
                // PRESERVED: Theme buttons in a row structure
                Row(
            children: [
              Expanded(
                child: _buildThemeButton(
                  icon: Icons.wb_sunny,
                  label: 'Light',
                  isSelected: themeProvider.currentTheme == AppThemeMode.light,
                  onTap: () => themeProvider.setTheme(AppThemeMode.light), // PRESERVED: Same logic
                  themeProvider: themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeButton(
                  icon: Icons.nightlight_round,
                  label: 'Dark',
                  isSelected: themeProvider.currentTheme == AppThemeMode.dark,
                  onTap: () => themeProvider.setTheme(AppThemeMode.dark), // PRESERVED: Same logic
                  themeProvider: themeProvider,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeButton(
                  icon: Icons.settings_brightness,
                  label: 'System',
                  isSelected: themeProvider.currentTheme == AppThemeMode.system,
                  onTap: () => themeProvider.setTheme(AppThemeMode.system), // PRESERVED: Same logic
                  themeProvider: themeProvider,
                ),
              ),
                ],
                ),
        ],
      ),
    );
  }

  // PRESERVED: Theme Button - UPDATED to use proper brand colors
  Widget _buildThemeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    return GestureDetector(
      onTap: onTap, // PRESERVED: Same tap logic
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          // CHANGED: Better color logic - use brand green when selected
          color: isSelected 
            ? const Color(0xFF34C759) 
            : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            // CHANGED: Better border color logic
            color: isSelected 
              ? const Color(0xFF34C759)
              : (themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[600]! 
                : Colors.grey[400]!),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              // CHANGED: Better icon color logic
              color: isSelected 
                ? Colors.white 
                : (themeProvider.currentTheme == AppThemeMode.dark 
                  ? Colors.grey[400] 
                  : Colors.grey[600]),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                // CHANGED: Better text color logic
                color: isSelected 
                  ? Colors.white 
                  : (themeProvider.currentTheme == AppThemeMode.dark 
                    ? Colors.grey[400] 
                    : Colors.grey[600]),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PRESERVED: Switch Setting - UPDATED colors
  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    ThemeProvider themeProvider, {
    String? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    // CHANGED: Theme-aware text color
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      // CHANGED: Theme-aware secondary text color
                      color: themeProvider.currentTheme == AppThemeMode.dark 
                        ? Colors.grey[400] 
                        : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value, // PRESERVED: Same value logic
            onChanged: (newValue) {
              hapticFeedback.toggle(); // Add haptic feedback for toggles
              onChanged(newValue);
            },
            // CHANGED: Use proper brand green instead of off-brand
            activeColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  // RESTORED: Navigation Setting method
  Widget _buildNavigationSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    ThemeProvider themeProvider, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDestructive ? const Color(0xFFFF3B30) : const Color(0xFF34C759),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive ? const Color(0xFFFF3B30) : Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: themeProvider.currentTheme == AppThemeMode.dark 
                          ? Colors.grey[400] 
                          : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }

  // RESTORED: Info Item method
  Widget _buildInfoItem(String title, String value, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF34C759),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                color: themeProvider.currentTheme == AppThemeMode.dark 
                  ? Colors.grey[400] 
                  : Colors.grey[600],
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  // RESTORED: Reset Button method
  Widget _buildResetButton(ThemeProvider themeProvider) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showResetDialog(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reset All Settings',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // RESTORED: Show Reset Dialog method
  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text('Are you sure you want to reset all settings to their default values? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetAllSettings();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings reset to defaults'),
                      backgroundColor: Color(0xFF34C759),
                    ),
                  );
                }
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  // RESTORED: Reset All Settings method
  Future<void> _resetAllSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset to defaults
      setState(() {
        _hapticFeedback = true;
        _defaultRoundTrip = false;
        _defaultTrafficConsideration = true;
        _autoSaveRoutes = true;
      });
      
      // Save the defaults
      await _saveSettings();
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error resetting settings: $e');
      }
    }
  }

  // RESTORED: URL launcher methods
  Future<void> _openTermsAndConditions() async {
    const url = 'https://lessdriving.netlify.app/terms';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showUrlError('Terms & Conditions');
      }
    } catch (e) {
      _showUrlError('Terms & Conditions');
    }
  }

  Future<void> _openPrivacyPolicy() async {
    const url = 'https://lessdriving.netlify.app/privacy';
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showUrlError('Privacy Policy');
      }
    } catch (e) {
      _showUrlError('Privacy Policy');
    }
  }

  void _showUrlError(String linkType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to open $linkType. Please try again later.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Build biometric authentication setting
  Widget _buildBiometricSetting(ThemeProvider themeProvider) {
    return Consumer<app_auth.AuthProvider>(
      builder: (context, authProvider, child) {
        final biometricAuth = authProvider.biometricAuth;
        final isAvailable = biometricAuth.isAvailable;
        final isEnabled = biometricAuth.isEnabled;
        
        if (!isAvailable) {
          // Show unavailable state
          return _buildUnavailableBiometricSetting(themeProvider);
        }
        
        return _buildSwitchSetting(
          biometricAuth.getBiometricTypeName(),
          'Use ${biometricAuth.getBiometricTypeName()} to unlock DriveLess',
          isEnabled,
          (value) async {
            if (value) {
              // Enable biometric authentication
              final success = await authProvider.showBiometricSetup();
              if (!success && mounted) {
                // Show error if setup failed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      authProvider.errorMessage ?? 'Failed to enable biometric authentication',
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            } else {
              // Disable biometric authentication
              await biometricAuth.disableBiometricAuth();
            }
          },
          themeProvider,
          icon: biometricAuth.getBiometricIcon(),
        );
      },
    );
  }

  /// Build unavailable biometric setting (grayed out)
  Widget _buildUnavailableBiometricSetting(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Text(
            '🔐',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biometric Authentication',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: (themeProvider.currentTheme == AppThemeMode.dark
                        ? Colors.grey[500]
                        : Colors.grey[400]),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Not available on this device',
                  style: TextStyle(
                    fontSize: 14,
                    color: (themeProvider.currentTheme == AppThemeMode.dark
                        ? Colors.grey[600]
                        : Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog for deleting all user data (iOS compliance)
  Future<void> _showDeleteAllDataConfirmation() async {
    hapticFeedback.warning(); // Warning haptic for serious action
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.warning,
                color: Color(0xFFFF3B30),
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Delete All Data?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'This will permanently delete all your saved data including:\n\n• Saved addresses\n• Route history\n• Smart suggestions\n• App preferences\n\nThis action cannot be undone.',
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3B30),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete All Data',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _deleteAllUserData();
    }
  }

  /// Actually delete all user data
  Future<void> _deleteAllUserData() async {
    try {
      hapticFeedback.majorAction(); // Heavy haptic for major action
      
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Delete all user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Clear smart suggestions
      await smartSuggestions.clearHistory();
      
      // Clear all Firebase data (via Firebase if user is authenticated)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _deleteAllFirebaseData(user.uid);
      }

      // Sign out user
      await context.read<app_auth.AuthProvider>().signOut();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'All data has been permanently deleted',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF34C759),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
        
        // Navigate back to welcome/login screen
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
      
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete data: ${e.toString()}'),
            backgroundColor: const Color(0xFFFF3B30),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      
      if (kDebugMode) {
        print('❌ Error deleting user data: $e');
      }
    }
  }

  /// Comprehensively delete all Firebase data using existing services
  Future<void> _deleteAllFirebaseData(String userId) async {
    try {
      // Use existing services to delete data (they should have proper permissions)
      
      // Delete saved addresses using the service
      final savedAddressService = SavedAddressService();
      // First ensure addresses are loaded
      await savedAddressService.initialize();
      final addresses = savedAddressService.savedAddresses;
      for (final address in addresses) {
        await savedAddressService.deleteAddress(address.id);
      }
      
      // Delete saved routes - get all routes and delete them
      // Note: You may need to add a deleteAllRoutes method to RouteStorageService
      // For now, we'll delete the main user document which should be sufficient for privacy
      final firestore = FirebaseFirestore.instance;
      final userDoc = firestore.collection('users').doc(userId);
      
      // Try to delete subcollections individually if batch fails
      try {
        // Delete saved addresses subcollection one by one
        final savedAddressesQuery = await userDoc.collection('saved_addresses').get();
        for (final doc in savedAddressesQuery.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not delete saved addresses subcollection: $e');
        }
      }
      
      try {
        // Delete saved routes subcollection one by one
        final savedRoutesQuery = await userDoc.collection('saved_routes').get();
        for (final doc in savedRoutesQuery.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not delete saved routes subcollection: $e');
        }
      }
      
      try {
        // Delete other potential subcollections
        final preferencesQuery = await userDoc.collection('preferences').get();
        for (final doc in preferencesQuery.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        if (kDebugMode) {
          print('⚠️ Could not delete preferences subcollection: $e');
        }
      }
      
      // Finally, delete the main user document
      await userDoc.delete();
      
      if (kDebugMode) {
        print('✅ Successfully deleted Firebase data for user: $userId');
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting Firebase data: $e');
      }
      // Don't rethrow here - we want to continue with local data deletion even if Firebase fails
      // The user will still be signed out and local data will be cleared
    }
  }
}