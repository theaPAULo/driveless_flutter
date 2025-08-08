// lib/screens/profile_screen.dart
//
// ENHANCED: Profile screen with usage analytics integration
// Preserves ALL existing functionality: stats, menu sections, theme switching, etc.
// Only adds minimal usage analytics enhancements

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Added for haptic feedback
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/usage_tracking_service.dart'; // ✅ Added
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
    // ✅ Initialize usage tracking
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats when returning to this screen (preserved)
    if (!_isLoadingStats) {
      _loadRouteStatistics();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack( // ✅ Wrapped in Stack for usage indicator
        children: [
          // Main content (all preserved)
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Header Section (preserved)
                    _buildHeaderSection(),
                    
                    const SizedBox(height: 32),
                    
                    // ✅ Usage Analytics Section (new, but non-intrusive)
                    _buildUsageAnalyticsSection(),
                    
                    const SizedBox(height: 24),
                    
                    // Your Stats Card (preserved)
                    _buildStatsCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Menu Sections (preserved)
                    _buildMenuSections(),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
          
          // ✅ Usage indicator in top right corner
          _buildUsageIndicator(),
        ],
      ),
    );
  }

  // ✅ NEW: Usage indicator in top right corner
  Widget _buildUsageIndicator() {
    return Consumer<UsageTrackingService>(
      builder: (context, usageService, child) {
        final todayUsage = usageService.todayUsage;
        final isAdmin = usageService.remainingRoutes == 999;
        final usagePercentage = usageService.usagePercentage;
        
        // Color based on usage level
        Color indicatorColor;
        String usageText;
        
        if (isAdmin) {
          indicatorColor = Colors.purple[400]!;
          usageText = '∞';
        } else if (usagePercentage >= 1.0) {
          indicatorColor = Colors.red[400]!;
          usageText = '$todayUsage/10';
        } else if (usagePercentage >= 0.8) {
          indicatorColor = Colors.orange[400]!;
          usageText = '$todayUsage/10';
        } else {
          indicatorColor = const Color(0xFF34C759);
          usageText = '$todayUsage/10';
        }
        
        return Positioned(
          top: 60,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: indicatorColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: indicatorColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              usageText,
              style: TextStyle(
                color: indicatorColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ NEW: Usage Analytics Section
  Widget _buildUsageAnalyticsSection() {
    return Consumer<UsageTrackingService>(
      builder: (context, usageService, child) {
        // Don't show detailed analytics for admin users (they see simplified version)
        if (usageService.remainingRoutes == 999) {
          return _buildAdminUsageSection(usageService);
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section header
              Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: const Color(0xFF34C759),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Usage Analytics',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Daily usage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daily Route Calculations',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${usageService.todayUsage}/10',
                    style: const TextStyle(
                      color: Color(0xFF34C759),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Remaining routes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining Today',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${usageService.remainingRoutes}',
                    style: TextStyle(
                      color: Colors.blue[400],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Progress bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daily Usage',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${(usageService.usagePercentage * 100).toInt()}%',
                        style: TextStyle(
                          color: usageService.usagePercentage >= 0.8 
                            ? Colors.orange[400] 
                            : const Color(0xFF34C759),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: usageService.usagePercentage.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: usageService.usagePercentage >= 0.8 
                            ? Colors.orange[400] 
                            : const Color(0xFF34C759),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Admin usage section (simplified for admin users)
  Widget _buildAdminUsageSection(UsageTrackingService usageService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.purple[400],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Admin Controls',
                style: TextStyle(
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Admin status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route Calculations',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Unlimited',
                style: TextStyle(
                  color: Colors.purple[400],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Reset button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                HapticFeedback.lightImpact();
                await usageService.resetUsageForToday();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Usage reset for today'),
                      backgroundColor: const Color(0xFF34C759),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Daily Usage'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Preserved Methods (all existing functionality)

  Widget _buildHeaderSection() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        return Column(
          children: [
            // Profile Avatar (preserved)
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
            
            // Welcome message (preserved)
            Text(
              'Hello, ${user?.displayName?.split(' ').first ?? user?.email?.split('@').first ?? 'User'}!',
              style: TextStyle(
                color: Theme.of(context).textTheme.headlineLarge?.color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // User email (preserved)
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

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
            blurRadius: 8,
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
              fontWeight: FontWeight.w600,
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
            Column(
              children: [
                // Top row stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.map,
                      iconColor: const Color(0xFF34C759),
                      value: '${_routeStats['totalRoutes'] ?? 0}',
                      label: 'Total Routes',
                    ),
                    _buildStatItem(
                      icon: Icons.favorite,
                      iconColor: Colors.red,
                      value: '${_routeStats['favoriteRoutes'] ?? 0}',
                      label: 'Favorites',
                    ),
                    _buildStatItem(
                      icon: Icons.access_time,
                      iconColor: Colors.blue,
                      value: '${(_routeStats['timeSaved'] ?? 0).toStringAsFixed(1)}h',
                      label: 'Time Saved',
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Bottom row stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      icon: Icons.eco,
                      iconColor: Colors.green,
                      value: '${(_routeStats['co2Saved'] ?? 0).toStringAsFixed(1)}',
                      label: 'CO₂ Saved',
                      subLabel: 'lbs',
                    ),
                    _buildStatItem(
                      icon: Icons.straighten,
                      iconColor: Colors.orange,
                      value: '${(_routeStats['milesSaved'] ?? 0).toStringAsFixed(1)}',
                      label: 'Miles Saved',
                      subLabel: 'miles',
                    ),
                    _buildStatItem(
                      icon: Icons.local_gas_station,
                      iconColor: Colors.purple,
                      value: '${(_routeStats['fuelSaved'] ?? 0).toStringAsFixed(1)}',
                      label: 'Fuel Saved',
                      subLabel: 'gallons',
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

        // Your Addresses Section (preserved)
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
                  MaterialPageRoute(builder: (context) => const SavedAddressesScreen()),
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

  Widget _buildMenuSection({
    required String title,
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
          ...children,
          const SizedBox(height: 10),
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
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
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
                        fontSize: 14,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.1),
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: const Text(
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