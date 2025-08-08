// lib/screens/profile_screen.dart
//
// CORRECTED: Profile screen with fixed nullable email issue
// ✅ Fixed: user.email nullable handling
// ✅ Fixed: addressService parameter passing

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/usage_tracking_service.dart';
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
  
  // State for real stats (preserved)
  Map<String, dynamic> _routeStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _addressService.initialize();
    _loadRouteStatistics();
    // Initialize usage tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<UsageTrackingService>().initialize();
      }
    });
  }

  /// Load real route statistics (preserved)
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header Section (preserved)
                _buildHeaderSection(),
                
                const SizedBox(height: 24),
                
                // Stats Section (preserved)
                _buildStatsSection(),
                
                const SizedBox(height: 24),
                
                // Menu Sections (preserved)
                _buildMenuSections(),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Header Section (preserved)
  Widget _buildHeaderSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // Profile picture or placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2E7D32).withOpacity(0.8),
                    const Color(0xFF4CAF50).withOpacity(0.6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: user.photoURL != null
                  ? ClipOval(
                      child: Image.network(
                        user.photoURL!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Hello, ${user.displayName ?? user.email ?? 'User'}!',
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineMedium?.color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            // ✅ FIXED: Handle nullable email properly
            Text(
              user.email ?? 'No email provided',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }

  // MARK: - Stats Section (preserved)
  Widget _buildStatsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Stats',
            style: TextStyle(
              color: Theme.of(context).textTheme.headlineMedium?.color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 20),
          
          if (_isLoadingStats)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2E7D32),
              ),
            )
          else
            Column(
              children: [
                // First row of stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.map,
                        iconColor: const Color(0xFF2E7D32),
                        value: '${_routeStats['totalRoutes'] ?? 0}',
                        label: 'Total Routes',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.favorite,
                        iconColor: Colors.red,
                        value: '${_routeStats['favoriteRoutes'] ?? 0}',
                        label: 'Favorites',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.access_time,
                        iconColor: Colors.blue,
                        value: '${(_routeStats['timeSavedMinutes'] ?? 0).toStringAsFixed(0)}m',
                        label: 'Time Saved',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Second row of stats
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.eco,
                        iconColor: Colors.green,
                        value: '${(_routeStats['co2Saved'] ?? 0).toStringAsFixed(1)}',
                        label: 'CO₂ Saved',
                        subLabel: 'lbs',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.straighten,
                        iconColor: Colors.orange,
                        value: '${(_routeStats['milesSaved'] ?? 0).toStringAsFixed(1)}',
                        label: 'Miles Saved',
                        subLabel: 'miles',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatItem(
                        icon: Icons.local_gas_station,
                        iconColor: Colors.purple,
                        value: '${(_routeStats['fuelSaved'] ?? 0).toStringAsFixed(1)}',
                        label: 'Fuel Saved',
                        subLabel: 'gallons',
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

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
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineMedium?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
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

  Widget _buildMenuSections() {
    return Column(
      children: [
        // Your Routes Section (preserved)
        _buildMenuSection(
          title: 'Your Routes',
          children: [
            _buildMenuItem(
              icon: Icons.history,
              iconColor: const Color(0xFF34C759),
              title: 'Route History',
              subtitle: 'View and reload past routes',
              onTap: () {
                HapticFeedback.lightImpact();
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
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FavoriteRoutesScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Your Addresses Section (preserved but FIXED to pass addressService)
        _buildMenuSection(
          title: 'Your Addresses',
          children: [
            _buildMenuItem(
              icon: Icons.home,
              iconColor: Colors.blue,
              title: 'Saved Addresses',
              subtitle: 'Manage home, work & custom locations',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  // ✅ FIXED: Pass the required addressService parameter
                  MaterialPageRoute(builder: (context) => SavedAddressesScreen(
                    addressService: _addressService,
                  )),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // App Settings Section (preserved)
        _buildMenuSection(
          title: 'App Settings',
          children: [
            _buildMenuItem(
              icon: Icons.settings,
              iconColor: Colors.grey,
              title: 'Settings',
              subtitle: 'Preferences, themes & defaults',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.feedback,
              iconColor: Colors.orange,
              title: 'Send Feedback',
              subtitle: 'Help us improve DriveLess',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FeedbackScreen()),
                );
              },
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Account Section (preserved)
        _buildMenuSection(
          title: 'Account',
          children: [
            _buildMenuItem(
              icon: Icons.admin_panel_settings,
              iconColor: Colors.purple,
              title: 'Admin Dashboard',
              subtitle: 'App analytics and management',
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
                );
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.logout,
              iconColor: Colors.red,
              title: 'Sign Out',
              subtitle: 'Log out of your account',
              onTap: () => _showSignOutConfirmation(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              title,
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineMedium?.color,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

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
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 76),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Theme.of(context).dividerColor.withOpacity(0.3),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: Theme.of(context).textTheme.headlineMedium?.color,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out of your account?',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<AuthProvider>().signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}