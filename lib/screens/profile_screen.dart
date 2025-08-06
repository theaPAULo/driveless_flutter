// lib/screens/profile_screen.dart
//
// Enhanced user profile screen with THEME-AWARE COLORS
// Now properly switches between light and dark themes
// Real statistics integration with RouteStorageService

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/user_model.dart';
import '../services/saved_address_service.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import 'saved_addresses_screen.dart';
import 'route_history_screen.dart';
import 'favorite_routes_screen.dart';
import 'admin_dashboard_screen.dart';
import 'settings_screen.dart';
import 'feedback_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SavedAddressService _addressService = SavedAddressService();
  
  // State for real stats
  Map<String, dynamic> _routeStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    // Initialize saved address service
    _addressService.initialize();
    // Load real route statistics
    _loadRouteStatistics();
  }

  /// Load real route statistics from RouteStorageService
  Future<void> _loadRouteStatistics() async {
    try {
      final stats = await RouteStorageService.getRouteStatistics();
      if (mounted) {
        setState(() {
          _routeStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading route statistics: $e');
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats when returning to this screen
    if (!_isLoadingStats) {
      _loadRouteStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME-AWARE: Use theme colors instead of hardcoded black
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // MARK: - Header Section (theme-aware)
                _buildHeaderSection(),
                
                const SizedBox(height: 32),
                
                // MARK: - Your Stats Card (theme-aware)
                _buildStatsCard(),
                
                const SizedBox(height: 24),
                
                // MARK: - Menu Sections (theme-aware)
                _buildMenuSections(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Header Section (Theme-Aware)
  Widget _buildHeaderSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        return Column(
          children: [
            // Profile Avatar (matching iOS gradient and shadow)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: user?.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        user!.photoURL!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 50,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // 🎨 THEME-AWARE: Welcome message and user name
            Text(
              'Hello, ${user?.displayName?.split(' ').first ?? user?.email?.split('@').first ?? 'User'}!',
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineLarge?.color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // 🎨 THEME-AWARE: User email
            Text(
              user?.email ?? 'No email available',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        );
      },
    );
  }

  // MARK: - Stats Card (Theme-Aware)
  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // 🎨 THEME-AWARE: Card background color
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎨 THEME-AWARE: Stats title
          Text(
            'Your Stats',
            style: TextStyle(
              color: Theme.of(context).textTheme.headlineMedium?.color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (_isLoadingStats)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF34C759),
              ),
            )
          else
            _buildStatsGrid(),
        ],
      ),
    );
  }

  // MARK: - Stats Grid (Theme-Aware)
  Widget _buildStatsGrid() {
    // Extract stats with fallbacks
    final totalRoutes = _routeStats['totalRoutes'] ?? 0;
    final favoriteRoutes = _routeStats['favoriteRoutes'] ?? 0;
    final timeSaved = (_routeStats['timeSavedMinutes'] ?? 0.0).toDouble();
    final co2Saved = (_routeStats['co2SavedPounds'] ?? 0.0).toDouble();
    final distanceSaved = (_routeStats['distanceSavedMiles'] ?? 0.0).toDouble();
    final fuelSaved = (_routeStats['fuelSavedGallons'] ?? 0.0).toDouble();

    return Column(
      children: [
        // Top Row
        Row(
          children: [
            Expanded(child: _buildStatItem(
              icon: Icons.route,
              iconColor: const Color(0xFF34C759),
              value: totalRoutes.toString(),
              label: 'Total Routes',
            )),
            Expanded(child: _buildStatItem(
              icon: Icons.favorite,
              iconColor: Colors.red,
              value: favoriteRoutes.toString(),
              label: 'Favorites',
            )),
            Expanded(child: _buildStatItem(
              icon: Icons.access_time,
              iconColor: Colors.blue,
              value: _formatTimeSaved(timeSaved),
              label: 'Time Saved',
            )),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Bottom Row
        Row(
          children: [
            Expanded(child: _buildStatItem(
              icon: Icons.eco,
              iconColor: Colors.green,
              value: _formatCO2Saved(co2Saved),
              label: 'CO₂ Saved',
              subLabel: 'lbs',
            )),
            Expanded(child: _buildStatItem(
              icon: Icons.straighten,
              iconColor: Colors.orange,
              value: _formatDistanceSaved(distanceSaved),
              label: 'Miles Saved',
              subLabel: 'miles',
            )),
            Expanded(child: _buildStatItem(
              icon: Icons.local_gas_station,
              iconColor: Colors.purple,
              value: _formatFuelSaved(fuelSaved),
              label: 'Fuel Saved',
              subLabel: 'gallons',
            )),
          ],
        ),
      ],
    );
  }

  // MARK: - Stat Item (Theme-Aware)
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    String? subLabel,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 32,
        ),
        const SizedBox(height: 8),
        // 🎨 THEME-AWARE: Stat value text
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineMedium?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        // 🎨 THEME-AWARE: Stat label text
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        if (subLabel != null)
          Text(
            subLabel,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
      ],
    );
  }

  // MARK: - Menu Sections (Theme-Aware)
  Widget _buildMenuSections() {
    return Column(
      children: [
        // Your Routes Section
        _buildMenuSection(
          title: 'Your Routes',
          children: [
            _buildMenuItem(
              icon: Icons.history,
              iconColor: const Color(0xFF34C759),
              title: 'Route History',
              subtitle: 'View and reload past routes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RouteHistoryScreen()),
                );
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.favorite,
              iconColor: Colors.red,
              title: 'Favorite Routes',
              subtitle: 'Quick access to saved routes',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteRoutesScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Your Addresses Section
        _buildMenuSection(
          title: 'Your Addresses',
          children: [
            _buildMenuItem(
              icon: Icons.home,
              iconColor: const Color(0xFF34C759),
              title: 'Saved Addresses',
              subtitle: 'Manage home, work & custom locations',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SavedAddressesScreen(
                      addressService: _addressService,
                    ),
                  ),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // App Settings Section
        _buildMenuSection(
          title: 'App Settings',
          children: [
            _buildMenuItem(
              icon: Icons.settings,
              iconColor: const Color(0xFF34C759),
              title: 'Settings',
              subtitle: 'Preferences, themes & defaults',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.feedback,
              iconColor: Colors.blue,
              title: 'Send Feedback',
              subtitle: 'Help us improve DriveLess',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.shield,
              iconColor: Colors.purple,
              title: 'Admin Dashboard',
              subtitle: 'App statistics & management',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Account Section
        _buildMenuSection(
          title: 'Account',
          children: [
            _buildMenuItem(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              onTap: _showSignOutConfirmation,
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.delete_forever,
              iconColor: Colors.red,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and all data',
              onTap: _showDeleteAccountConfirmation,
            ),
          ],
        ),
      ],
    );
  }

  // MARK: - Menu Section (Theme-Aware)
  Widget _buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        // 🎨 THEME-AWARE: Section background color
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineMedium?.color,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Menu Items
          ...children,
          
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // MARK: - Menu Item (Theme-Aware)
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🎨 THEME-AWARE: Menu title
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 🎨 THEME-AWARE: Menu subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Menu Divider (Theme-Aware)
  Widget _buildMenuDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Theme.of(context).brightness == Brightness.dark
        ? Colors.grey.withOpacity(0.2)
        : Colors.grey.withOpacity(0.3),
    );
  }

  // MARK: - Helper Methods for Formatting Stats
  
  /// Format time saved for display
  String _formatTimeSaved(double totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes.toInt()}m';
    } else {
      double hours = totalMinutes / 60;
      if (hours < 10) {
        return '${hours.toStringAsFixed(1)}h';
      } else {
        return '${hours.toInt()}h';
      }
    }
  }

  /// Format CO2 saved for display
  String _formatCO2Saved(double co2Pounds) {
    if (co2Pounds < 10) {
      return co2Pounds.toStringAsFixed(1);
    } else if (co2Pounds < 1000) {
      return co2Pounds.toInt().toString();
    } else {
      return '${(co2Pounds / 1000).toStringAsFixed(1)}k';
    }
  }

  /// Format distance saved for display
  String _formatDistanceSaved(double miles) {
    if (miles < 10) {
      return miles.toStringAsFixed(1);
    } else if (miles < 1000) {
      return miles.toInt().toString();
    } else {
      return '${(miles / 1000).toStringAsFixed(1)}k';
    }
  }

  /// Format fuel saved for display
  String _formatFuelSaved(double gallons) {
    if (gallons < 10) {
      return gallons.toStringAsFixed(1);
    } else if (gallons < 100) {
      return gallons.toInt().toString();
    } else {
      return '${(gallons / 100).toStringAsFixed(1)}H'; // H for hundreds
    }
  }

  // MARK: - Account Actions

  /// Show sign out confirmation
  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // 🎨 THEME-AWARE: Dialog background
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            'Sign Out',
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          content: Text(
            'Are you sure you want to sign out? You can sign back in anytime.',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show delete account confirmation
  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // 🎨 THEME-AWARE: Dialog background
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
            style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.deleteAccount();
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}