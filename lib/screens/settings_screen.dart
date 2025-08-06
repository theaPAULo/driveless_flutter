// lib/screens/settings_screen.dart
//
// Settings screen with functional theme management and app preferences
// Now connected to ThemeProvider for immediate theme switching

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state (theme is now managed by ThemeProvider)
  bool _defaultRoundTrip = false;
  bool _defaultTrafficConsideration = true;
  bool _hapticFeedback = true;
  String _defaultDistanceUnit = 'miles';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load settings from SharedPreferences (excluding theme)
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
                    color: Color(0xFF34C759), // Always green
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

  // MARK: - Settings Content
  Widget _buildSettingsContent(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appearance Section
          _buildSettingsSection(
            title: 'Appearance',
            icon: Icons.palette_outlined,
            children: [
              _buildThemeSelector(themeProvider),
            ],
          ),

          const SizedBox(height: 24),

          // Route Defaults Section
          _buildSettingsSection(
            title: 'Route Defaults',
            icon: Icons.route_outlined,
            children: [
              _buildSwitchSetting(
                'Round Trip by Default',
                'New routes will be round trip',
                _defaultRoundTrip,
                (value) {
                  setState(() {
                    _defaultRoundTrip = value;
                  });
                  _saveSettings();
                },
              ),
              const Divider(color: Colors.grey, height: 1),
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
            ],
          ),

          const SizedBox(height: 24),

          // Distance Unit Section
          _buildSettingsSection(
            title: 'Units',
            icon: Icons.straighten_outlined,
            children: [
              _buildDistanceUnitSelector(),
            ],
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSettingsSection(
            title: 'Preferences',
            icon: Icons.tune_outlined,
            children: [
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
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _buildSettingsSection(
            title: 'About',
            icon: Icons.info_outline,
            children: [
              _buildInfoItem('Version', '1.0.0'),
              const Divider(color: Colors.grey, height: 1),
              _buildInfoItem('Build', '1'),
            ],
          ),

          const SizedBox(height: 40),

          // Reset Button
          _buildResetButton(),
        ],
      ),
    );
  }

  // MARK: - Settings Section Builder
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon, 
                  color: const Color(0xFF34C759),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          ...children.map((child) => child).toList(),
        ],
      ),
    );
  }

  // MARK: - Theme Selector (Now functional!)
  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Theme',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Theme options as iOS-style capsule buttons
          Row(
            children: AppThemeMode.values.map((theme) {
              final isSelected = themeProvider.currentTheme == theme;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () async {
                      await themeProvider.setTheme(theme);
                      // Show success message
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Theme changed to ${theme.displayName}'),
                            backgroundColor: const Color(0xFF34C759),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? const Color(0xFF34C759)
                          : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            theme.icon,
                            color: isSelected 
                              ? Colors.white 
                              : Theme.of(context).textTheme.bodyMedium?.color,
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.displayName,
                            style: TextStyle(
                              color: isSelected 
                                ? Colors.white 
                                : Theme.of(context).textTheme.bodyMedium?.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // MARK: - Distance Unit Selector
  Widget _buildDistanceUnitSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Distance Unit',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
            ),
          ),
          DropdownButton<String>(
            value: _defaultDistanceUnit,
            dropdownColor: Theme.of(context).cardTheme.color,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
            items: const [
              DropdownMenuItem(value: 'miles', child: Text('Miles')),
              DropdownMenuItem(value: 'kilometers', child: Text('Kilometers')),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _defaultDistanceUnit = value;
                });
                _saveSettings();
              }
            },
          ),
        ],
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
      padding: const EdgeInsets.all(16),
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34C759),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  // MARK: - Info Item
  Widget _buildInfoItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.all(16),
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
          backgroundColor: Theme.of(context).cardTheme.color,
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
              onPressed: () => Navigator.of(context).pop(),
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
}