// lib/screens/settings_screen.dart
//
// Settings screen with original design + Terms/Privacy/Rate links added
// Reverted to original clean layout as requested

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  
  // Route defaults
  bool _defaultRoundTrip = false;
  bool _defaultTrafficConsideration = true;
  
  // UI preferences
  bool _hapticFeedback = true;
  
  // Distance unit
  String _defaultDistanceUnit = 'miles';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Route defaults
        _defaultRoundTrip = prefs.getBool('default_round_trip') ?? false;
        _defaultTrafficConsideration = prefs.getBool('default_traffic_consideration') ?? true;
        
        // UI preferences
        _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
        
        // Distance unit
        _defaultDistanceUnit = prefs.getString('distance_unit') ?? 'miles';
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading settings: $e');
      }
    }
  }

  /// Save settings to SharedPreferences (excluding theme)
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('default_round_trip', _defaultRoundTrip);
      await prefs.setBool('default_traffic_consideration', _defaultTrafficConsideration);
      await prefs.setBool('haptic_feedback', _hapticFeedback);
      await prefs.setString('distance_unit', _defaultDistanceUnit);
      
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back, 
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Settings',
              style: TextStyle(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: false,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          body: _isLoading ? _buildLoadingState() : _buildSettingsContent(themeProvider),
        );
      },
    );
  }

  // MARK: - Loading State
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF34C759),
          ),
          SizedBox(height: 16),
          Text(
            'Loading settings...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Settings Content (Original Design)
  Widget _buildSettingsContent(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // APPEARANCE Section
          _buildSectionHeader('APPEARANCE'),
          _buildSettingsCard([
            _buildThemeSelector(themeProvider),
          ]),

          // HAPTIC FEEDBACK Section  
          _buildSectionHeader('HAPTIC FEEDBACK'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Haptic Feedback',
              'Feel vibrations for button taps and events',
              _hapticFeedback,
              (value) {
                setState(() {
                  _hapticFeedback = value;
                });
                _saveSettings();
              },
            ),
          ]),

          // ROUTE DEFAULTS Section
          _buildSectionHeader('ROUTE DEFAULTS'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Default Round Trip',
              'Return to starting location by default',
              _defaultRoundTrip,
              (value) {
                setState(() {
                  _defaultRoundTrip = value;
                });
                _saveSettings();
              },
            ),
            const Divider(height: 1, color: Colors.grey),
            _buildSwitchSetting(
              'Consider Traffic',
              'Include current traffic in route calculations',
              _defaultTrafficConsideration,
              (value) {
                setState(() {
                  _defaultTrafficConsideration = value;
                });
                _saveSettings();
              },
            ),
          ]),

          // PRIVACY & DATA Section
          _buildSectionHeader('PRIVACY & DATA'),
          _buildSettingsCard([
            _buildSwitchSetting(
              'Auto-Save Routes',
              'Automatically save completed routes to history',
              true, // This could be a setting if needed
              (value) {
                // Handle auto-save setting
              },
            ),
            const Divider(height: 1, color: Colors.grey),
            _buildNavigationSetting(
              'Location Permissions',
              'Manage location access settings',
              Icons.location_on,
              () {
                // Could open app settings or location permissions
              },
            ),
          ]),

          // ABOUT Section
          _buildSectionHeader('ABOUT'),
          _buildSettingsCard([
            _buildInfoItem('Version', '1.0.0'),
            const Divider(height: 1, color: Colors.grey),
            _buildInfoItem('DriveLess for iOS', ''),
            const Divider(height: 1, color: Colors.grey),
            _buildNavigationSetting(
              'Terms & Conditions',
              'View terms of service',
              Icons.description,
              _openTermsAndConditions,
            ),
            const Divider(height: 1, color: Colors.grey),
            _buildNavigationSetting(
              'Privacy Policy',
              'How we handle your data',
              Icons.privacy_tip,
              _openPrivacyPolicy,
            ),
            const Divider(height: 1, color: Colors.grey),
            _buildNavigationSetting(
              'Rate DriveLess',
              'Rate us on the App Store',
              Icons.star,
              _openAppStoreRating,
            ),
          ]),

          const SizedBox(height: 40),

          // Reset Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: _buildResetButton(),
          ),
        ],
      ),
    );
  }

  // MARK: - Section Header (Original Style)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // MARK: - Settings Card (Original Style)
  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // MARK: - Theme Selector (Original Design)
  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your preferred appearance',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Theme buttons in a row
          Row(
            children: [
              Expanded(
                child: _buildThemeButton(
                  icon: Icons.wb_sunny,
                  label: 'Light',
                  isSelected: themeProvider.currentTheme == AppThemeMode.light,
                  onTap: () => themeProvider.setTheme(AppThemeMode.light),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeButton(
                  icon: Icons.nightlight_round,
                  label: 'Dark',
                  isSelected: themeProvider.currentTheme == AppThemeMode.dark,
                  onTap: () => themeProvider.setTheme(AppThemeMode.dark),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildThemeButton(
                  icon: Icons.settings_brightness,
                  label: 'System',
                  isSelected: themeProvider.currentTheme == AppThemeMode.system,
                  onTap: () => themeProvider.setTheme(AppThemeMode.system),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Theme Button
  Widget _buildThemeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF34C759) : Colors.transparent,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected ? const Color(0xFF34C759) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Switch Setting
  Widget _buildSwitchSetting(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
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
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34C759),
          ),
        ],
      ),
    );
  }

  // MARK: - Navigation Setting (NEW - for Terms, Privacy, etc.)
  Widget _buildNavigationSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF34C759),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
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
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Info Item
  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
          ),
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  // MARK: - Reset Button
  Widget _buildResetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _resetToDefaults,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Reset to Defaults',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // MARK: - Helper Methods
  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text(
            'Reset Settings',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          content: Text(
            'Are you sure you want to reset all settings to their default values?',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Reset theme to dark
                final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
                await themeProvider.setTheme(AppThemeMode.dark);
                
                // Reset other settings
                setState(() {
                  _defaultRoundTrip = false;
                  _defaultTrafficConsideration = true;
                  _hapticFeedback = true;
                  _defaultDistanceUnit = 'miles';
                });
                
                await _saveSettings();
                
                if (mounted) {
                  Navigator.of(context).pop();
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

  // MARK: - Navigation Methods
  
  /// Open Terms & Conditions
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

  /// Open Privacy Policy
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

  /// Open App Store Rating
  Future<void> _openAppStoreRating() async {
    // You can update these URLs with your actual app store links
    const appStoreUrl = 'https://apps.apple.com/app/driveless/id123456789'; 
    const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.driveless.app';
    
    try {
      const url = appStoreUrl; // Use appropriate URL based on platform
      final uri = Uri.parse(url);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showUrlError('App Store');
      }
    } catch (e) {
      _showUrlError('App Store');
    }
  }

  /// Show error when URL can't be opened
  void _showUrlError(String linkType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Unable to open $linkType. Please try again later.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}