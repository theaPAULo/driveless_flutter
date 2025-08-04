// lib/screens/settings_screen.dart
//
// Settings screen with theme management and app preferences
// Matches iOS SettingsView functionality

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

enum AppThemeMode { system, light, dark }

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  AppThemeMode _currentTheme = AppThemeMode.dark;
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

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        // Theme preference
        final themeString = prefs.getString('theme_mode') ?? 'dark';
        _currentTheme = AppThemeMode.values.firstWhere(
          (e) => e.name == themeString,
          orElse: () => AppThemeMode.dark,
        );
        
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

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString('theme_mode', _currentTheme.name);
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
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
                color: Color(0xFF2E7D32),
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingState() : _buildSettingsContent(),
    );
  }

  // MARK: - Loading State
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2E7D32),
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
  Widget _buildSettingsContent() {
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
              _buildThemeSelector(),
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
              _buildSwitchSetting(
                'Consider Traffic by Default',
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

          // Units & Measurements Section
          _buildSettingsSection(
            title: 'Units & Measurements',
            icon: Icons.straighten_outlined,
            children: [
              _buildDistanceUnitSelector(),
            ],
          ),

          const SizedBox(height: 24),

          // User Experience Section
          _buildSettingsSection(
            title: 'User Experience',
            icon: Icons.tune_outlined,
            children: [
              _buildSwitchSetting(
                'Haptic Feedback',
                'Vibration feedback for interactions',
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
            icon: Icons.info_outlined,
            children: [
              _buildInfoItem('App Version', '1.0.0 (Flutter)'),
              _buildInfoItem('Platform', 'Android'),
              _buildInfoItem('Build', 'Development'),
            ],
          ),

          const SizedBox(height: 24),

          // Reset Section
          _buildSettingsSection(
            title: 'Reset',
            icon: Icons.restore_outlined,
            children: [
              _buildActionItem(
                'Reset to Defaults',
                'Restore all settings to default values',
                Icons.restart_alt,
                _resetToDefaults,
                Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // MARK: - Settings Section
  Widget _buildSettingsSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2E7D32)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
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

  // MARK: - Theme Selector
  Widget _buildThemeSelector() {
    return Column(
      children: [
        _buildThemeOption(
          'System',
          'Use device theme setting',
          AppThemeMode.system,
          Icons.brightness_auto,
        ),
        _buildThemeOption(
          'Light',
          'Light theme',
          AppThemeMode.light,
          Icons.brightness_7,
        ),
        _buildThemeOption(
          'Dark',
          'Dark theme',
          AppThemeMode.dark,
          Icons.brightness_2,
        ),
      ],
    );
  }

  Widget _buildThemeOption(String title, String subtitle, AppThemeMode mode, IconData icon) {
    final isSelected = _currentTheme == mode;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _currentTheme = mode;
          });
          _saveSettings();
          _showThemeChangeNote();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[300],
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Distance Unit Selector
  Widget _buildDistanceUnitSelector() {
    return Column(
      children: [
        _buildUnitOption('Miles', 'miles'),
        _buildUnitOption('Kilometers', 'kilometers'),
      ],
    );
  }

  Widget _buildUnitOption(String title, String unit) {
    final isSelected = _defaultDistanceUnit == unit;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() {
            _defaultDistanceUnit = unit;
          });
          _saveSettings();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.straighten,
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 20,
                ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF2E7D32),
            activeTrackColor: const Color(0xFF2E7D32).withOpacity(0.3),
            inactiveThumbColor: Colors.grey[600],
            inactiveTrackColor: Colors.grey[800],
          ),
        ],
      ),
    );
  }

  // MARK: - Info Item
  Widget _buildInfoItem(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Action Item
  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Helper Methods

  void _showThemeChangeNote() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Theme will change on next app restart'),
        backgroundColor: Color(0xFF2E7D32),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Reset Settings',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to reset all settings to their default values?',
            style: TextStyle(color: Colors.grey[400]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF007AFF)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _performReset();
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performReset() async {
    setState(() {
      _currentTheme = AppThemeMode.dark;
      _defaultRoundTrip = false;
      _defaultTrafficConsideration = true;
      _hapticFeedback = true;
      _defaultDistanceUnit = 'miles';
    });

    await _saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings reset to defaults'),
          backgroundColor: Color(0xFF2E7D32),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}