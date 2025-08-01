// lib/screens/profile_screen.dart
//
// User profile screen matching iOS design exactly
// Shows user stats, routes, addresses, and settings

import 'package:flutter/material.dart';

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
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // User Greeting (matching iOS text style)
        const Text(
          'Hello, Paul Soni!', // Mock data - will be dynamic later
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Email (matching iOS secondary text)
        Text(
          'psoni511@gmail.com', // Mock data - will be dynamic later
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // MARK: - Your Stats Card (exactly matching iOS layout)
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Title
          const Text(
            'Your Stats',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // First Row: Basic Stats (Total Routes, Favorites, Time Saved)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Icons.map,
                iconColor: const Color(0xFF2E7D32),
                value: '12',
                label: 'Total Routes',
              ),
              _buildStatItem(
                icon: Icons.favorite,
                iconColor: const Color(0xFF2E7D32),
                value: '1',
                label: 'Favorites',
              ),
              _buildStatItem(
                icon: Icons.access_time,
                iconColor: const Color(0xFF2E7D32),
                value: '85.8h',
                label: 'Time Saved',
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Divider (matching iOS style)
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[600]?.withOpacity(0.3),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Second Row: Environmental Impact (CO2, Miles, Fuel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEnvironmentalStatItem(
                icon: Icons.eco,
                iconColor: Colors.green,
                title: 'CO₂ Saved',
                value: '2291.0',
                subtitle: 'lbs',
              ),
              _buildEnvironmentalStatItem(
                icon: Icons.route,
                iconColor: const Color(0xFF2E7D32),
                title: 'Miles Saved',
                value: '2574.2',
                subtitle: 'miles',
              ),
              _buildEnvironmentalStatItem(
                icon: Icons.local_gas_station,
                iconColor: Colors.grey,
                title: 'Fuel Saved',
                value: '103.0',
                subtitle: 'gallons',
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Basic Stat Item (Top Row)
  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
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
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // MARK: - Environmental Stat Item (Bottom Row)
  Widget _buildEnvironmentalStatItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Column(
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
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // MARK: - Menu Sections (matching iOS card layout)
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
                // TODO: Navigate to route history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Route History - Coming Soon!')),
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
                // TODO: Navigate to favorite routes
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Favorite Routes - Coming Soon!')),
                );
              },
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Your Addresses Section (MAIN FEATURE)
        _buildMenuCard(
          title: 'Your Addresses', 
          children: [
            _buildMenuItem(
              icon: Icons.home,
              iconColor: const Color(0xFF2E7D32),
              title: 'Saved Addresses',
              subtitle: 'Manage home, work & custom locations',
              onTap: () {
                // Navigate to Saved Addresses Screen
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
                // TODO: Navigate to settings
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings - Coming Soon!')),
                );
              },
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
}