// lib/screens/profile_screen.dart
//
// Enhanced user profile screen with real statistics and admin features
// Now properly integrated with real data from RouteStorageService

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
import 'feedback_screen.dart';  // ADD THIS IMPORT

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
            
            // User email with proper styling
            Text(
              user?.email ?? 'No email available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Provider badge (matching iOS)
            if (user?.provider != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      user!.provider == AuthProviderType.google ? Icons.account_circle : Icons.apple,
                      color: const Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.provider.name,
                      style: const TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  // MARK: - Stats Card (with real data)
  Widget _buildStatsCard() {
    if (_isLoadingStats) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Top row stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.map_outlined,
                  iconColor: const Color(0xFF2E7D32),
                  value: _routeStats['totalRoutes']?.toString() ?? '0',
                  label: 'Total Routes',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.favorite,
                  iconColor: const Color(0xFF2E7D32),
                  value: _routeStats['favoriteRoutes']?.toString() ?? '0',
                  label: 'Favorites',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.access_time,
                  iconColor: const Color(0xFF2E7D32),
                  value: _formatTimeSaved((_routeStats['totalTimeSaved'] ?? 0.0).toDouble()),
                  label: 'Time Saved',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Bottom row stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.eco,
                  iconColor: const Color(0xFF4CAF50),
                  value: _formatCO2Saved((_routeStats['co2Saved'] ?? 0.0).toDouble()),
                  label: 'CO₂ Saved\nlbs',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.straighten,
                  iconColor: const Color(0xFF2E7D32),
                  value: _formatDistanceSaved((_routeStats['totalDistanceSaved'] ?? 0.0).toDouble()),
                  label: 'Miles Saved\nmiles',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.local_gas_station,
                  iconColor: const Color(0xFF4CAF50),
                  value: _formatFuelSaved((_routeStats['fuelSaved'] ?? 0.0).toDouble()),
                  label: 'Fuel Saved\ngallons',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Individual Stat Item
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
              icon: Icons.feedback_outlined,
              iconColor: const Color(0xFF2E7D32),
              title: 'Send Feedback',
              subtitle: 'Help us improve DriveLess',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Admin Section (only show if user is admin)
        Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Check if user is admin (you can modify this logic as needed)
            final userEmail = authProvider.user?.email;
            final isAdmin = userEmail == 'psoni511@gmail.com'; // Replace with your admin email
            
            if (!isAdmin) return const SizedBox.shrink();
            
            return Column(
              children: [
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
              ],
            );
          },
        ),
        
        // Account Section
        _buildMenuCard(
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
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
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
            'Are you sure you want to sign out? You can sign back in anytime.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
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
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'This action cannot be undone. All your data, including saved routes and addresses, will be permanently deleted.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.deleteAccount();
              },
              child: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}