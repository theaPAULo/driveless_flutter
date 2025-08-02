// lib/screens/profile_screen.dart
//
// Enhanced user profile screen with real statistics and admin features
// Now properly integrated with real data from RouteStorageService

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/saved_address_service.dart';
import '../services/route_storage_service.dart';
import '../utils/constants.dart';
import 'saved_addresses_screen.dart';
import 'route_history_screen.dart';
import 'favorite_routes_screen.dart';
import 'admin_dashboard_screen.dart';
import 'settings_screen.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // MARK: - Header Section (matching iOS exactly)
                _buildHeaderSection(),
                
                const SizedBox(height: 32),
                
                // MARK: - Your Stats Card (enhanced with real data)
                _buildStatsCard(),
                
                const SizedBox(height: 24),
                
                // MARK: - Menu Sections (matching iOS layout)
                _buildMenuSections(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Header Section
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
            
            // Welcome message and user name (matching iOS style)
            Text(
              'Hello, ${user?.displayName?.split(' ').first ?? user?.email?.split('@').first ?? 'User'}!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // User Email (matching iOS subtitle style)
            if (user?.email != null)
              Text(
                user!.email!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
          ],
        );
      },
    );
  }

  // MARK: - Enhanced Stats Card with Real Data
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isLoadingStats)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2E7D32),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          // First row of stats (Routes, Favorites, Time Saved)
          Row(
            children: [
              _buildStatItem(
                icon: Icons.map,
                iconColor: const Color(0xFF2E7D32),
                value: _isLoadingStats ? '--' : '${_routeStats['totalRoutes'] ?? 0}',
                label: 'Total Routes',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.favorite,
                iconColor: const Color(0xFF2E7D32),
                value: _isLoadingStats ? '--' : '${_routeStats['favoriteRoutes'] ?? 0}',
                label: 'Favorites',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.access_time,
                iconColor: const Color(0xFF2E7D32),
                value: _isLoadingStats ? '--' : _formatTimeSaved(_routeStats['totalTimeSaved'] ?? 0.0),
                label: 'Time Saved',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Second row of stats (Environmental Impact)
          Row(
            children: [
              _buildStatItem(
                icon: Icons.eco,
                iconColor: const Color(0xFF4CAF50),
                value: _isLoadingStats ? '--' : _formatCO2Saved(_routeStats['co2Saved'] ?? 0.0),
                label: 'CO₂ Saved\nlbs',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.route,
                iconColor: const Color(0xFF8BC34A),
                value: _isLoadingStats ? '--' : _formatDistanceSaved(_routeStats['totalDistanceSaved'] ?? 0.0),
                label: 'Miles Saved\nmiles',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.local_gas_station,
                iconColor: const Color(0xFF9E9E9E),
                value: _isLoadingStats ? '--' : _formatFuelSaved(_routeStats['totalFuelSaved'] ?? 0.0),
                label: 'Fuel Saved\ngallons',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Enhanced Stat Item with Loading State
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Menu Sections
  Widget _buildMenuSections() {
    return Column(
      children: [
        // Your Routes Section
        _buildMenuCard(
          title: 'Your Routes',
          children: [
            _buildMenuItem(
              icon: Icons.history,
              iconColor: const Color(0xFF2E7D32),
              title: 'Route History',
              subtitle: 'View and reload past routes',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const RouteHistoryScreen(),
                  ),
                );
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.favorite,
              iconColor: const Color(0xFF2E7D32),
              title: 'Favorite Routes',
              subtitle: 'Quick access to saved routes',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoriteRoutesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Your Addresses Section
        _buildMenuCard(
          title: 'Your Addresses',
          children: [
            _buildMenuItem(
              icon: Icons.home,
              iconColor: const Color(0xFF2E7D32),
              title: 'Saved Addresses',
              subtitle: 'Manage home, work & custom locations',
              onTap: () {
                Navigator.of(context).push(
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
        
        const SizedBox(height: 16),
        
        // App Settings Section
        _buildMenuCard(
          title: 'App Settings',
          children: [
            _buildMenuItem(
              icon: Icons.settings,
              iconColor: const Color(0xFF2E7D32),
              title: 'Settings',
              subtitle: 'Preferences, themes & defaults',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Feedback Section
        _buildMenuCard(
          title: 'Feedback',
          children: [
            _buildMenuItem(
              icon: Icons.email_outlined,
              iconColor: const Color(0xFF2E7D32),
              title: 'Send Feedback',
              subtitle: 'Help us improve DriveLess',
              onTap: () {
                // TODO: Implement feedback functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feedback feature coming soon!'),
                    backgroundColor: Color(0xFF2E7D32),
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Admin Section
        _buildMenuCard(
          title: 'Admin',
          children: [
            _buildMenuItem(
              icon: Icons.admin_panel_settings,
              iconColor: const Color(0xFF2E7D32),
              title: 'Admin Dashboard',
              subtitle: 'App statistics & management',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboardScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Account Section
        _buildMenuCard(
          title: 'Account',
          children: [
            _buildMenuItem(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              onTap: () => _showSignOutConfirmation(),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.delete_forever,
              iconColor: Colors.red,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and all data',
              onTap: () => _showDeleteAccountConfirmation(),
            ),
          ],
        ),
      ],
    );
  }

  // MARK: - Menu Card Container
  Widget _buildMenuCard({
    required String title,
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
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
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

  // MARK: - Menu Item
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
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
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

  // MARK: - Menu Divider
  Widget _buildMenuDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: Colors.grey.withOpacity(0.2),
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
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Are you sure you want to sign out?',
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
                _performSignOut();
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
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'This will permanently delete your account and all associated data. This action cannot be undone.',
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
                _showFinalDeleteConfirmation();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Show final delete confirmation
  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Final Confirmation',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'Type "DELETE" to confirm account deletion:',
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
                // TODO: Implement account deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account deletion feature coming soon'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Perform sign out
  Future<void> _performSignOut() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}