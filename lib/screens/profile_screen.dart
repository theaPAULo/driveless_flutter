// lib/screens/profile_screen.dart
//
// User profile screen matching iOS design exactly
// Now properly integrated with AuthProvider for authenticated user data

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/saved_address_service.dart';
import '../utils/constants.dart';
import 'saved_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SavedAddressService _addressService = SavedAddressService();

  @override
  void initState() {
    super.initState();
    // Initialize saved address service
    _addressService.initialize();
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
                
                // MARK: - Your Stats Card (matching iOS design)
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
                            size: 40,
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
            ),
            
            const SizedBox(height: 16),
            
            // User Greeting (matching iOS text style)
            Text(
              'Hello, ${user?.displayName ?? user?.email?.split('@').first ?? 'User'}!',
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

  // MARK: - Stats Card
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
          const Text(
            'Your Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // First row of stats
          Row(
            children: [
              _buildStatItem(
                icon: Icons.map,
                iconColor: const Color(0xFF2E7D32),
                value: '12',
                label: 'Total Routes',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.favorite,
                iconColor: const Color(0xFF2E7D32),
                value: '1',
                label: 'Favorites',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.access_time,
                iconColor: const Color(0xFF2E7D32),
                value: '85.8h',
                label: 'Time Saved',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Second row of stats
          Row(
            children: [
              _buildStatItem(
                icon: Icons.eco,
                iconColor: const Color(0xFF4CAF50),
                value: '2291.0',
                label: 'CO₂ Saved\nlbs',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.route,
                iconColor: const Color(0xFF8BC34A),
                value: '2574.2',
                label: 'Miles Saved\nmiles',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.local_gas_station,
                iconColor: const Color(0xFF9E9E9E),
                value: '103.0',
                label: 'Fuel Saved\ngallons',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Stat Item
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
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
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
                // Navigate to route history
                debugPrint('Navigate to Route History');
              },
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.favorite,
              iconColor: const Color(0xFF2E7D32),
              title: 'Favorite Routes',
              subtitle: 'Quick access to saved routes',
              onTap: () {
                // Navigate to favorite routes
                debugPrint('Navigate to Favorite Routes');
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
                // Navigate to settings
                debugPrint('Navigate to Settings');
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
              iconColor: const Color(0xFFF44336),
              title: 'Sign Out',
              subtitle: 'Sign out of your account',
              onTap: () => _showSignOutDialog(),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              icon: Icons.delete_forever,
              iconColor: const Color(0xFFF44336),
              title: 'Delete Account',
              subtitle: 'Permanently delete your account and all data',
              onTap: () => _showDeleteAccountDialog(),
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
      padding: const EdgeInsets.all(20),
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // MARK: - Menu Item Row
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        child: Row(
          children: [
            // Icon Circle (matching iOS style)
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Title and Subtitle
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
            
            // Arrow Icon (matching iOS)
            Icon(
              Icons.chevron_right,
              color: Colors.grey[500],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Menu Divider
  Widget _buildMenuDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 66),
      decoration: BoxDecoration(
        color: Colors.grey[700]?.withOpacity(0.5),
      ),
    );
  }

  // MARK: - Sign Out Dialog
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Sign Out',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Color(0xFFF44336)),
              ),
            ),
          ],
        );
      },
    );
  }

  // MARK: - Delete Account Dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text(
            'Delete Account',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will permanently delete your account and all associated data. This action cannot be undone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<AuthProvider>(context, listen: false).deleteAccount();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFF44336)),
              ),
            ),
          ],
        );
      },
    );
  }
}