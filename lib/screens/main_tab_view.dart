// lib/screens/main_tab_view.dart
//
// FIXED: Main tab navigation with THEME-AWARE bottom navigation bar
// Now properly switches between light and dark themes

import 'package:flutter/material.dart';

import 'route_input_screen.dart';
import 'profile_screen.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({Key? key}) : super(key: key);

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0;

  // Tab screens
  final List<Widget> _screens = [
    const RouteInputScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // 🎨 THEME-AWARE: Use Theme.of(context) for proper theme switching
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    
    return Scaffold(
      backgroundColor: backgroundColor, // 🎨 THEME-AWARE
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // MARK: - Bottom Navigation Bar - NOW THEME-AWARE
  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: 90,
      decoration: BoxDecoration(
        // 🎨 FIXED: Theme-aware colors
        color: isDark 
            ? const Color(0xFF1C1C1E) // Dark theme
            : Colors.white, // Light theme
        border: Border(
          top: BorderSide(
            // 🎨 FIXED: Theme-aware border color
            color: isDark 
                ? const Color(0xFF38383A) // Dark theme border
                : const Color(0xFFD1D1D6), // Light theme border
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Search Tab
            _buildTabItem(
              index: 0,
              icon: Icons.map,
              label: 'Search',
              isSelected: _selectedIndex == 0,
            ),
            
            // Profile Tab  
            _buildTabItem(
              index: 1,
              icon: Icons.person_outline,
              label: 'Profile',
              isSelected: _selectedIndex == 1,
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Tab Item - NOW THEME-AWARE
  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              // 🎨 FIXED: Theme-aware icon colors
              color: isSelected 
                  ? const Color(0xFF34C759) // Always green when selected (both themes)
                  : (isDark 
                      ? Colors.grey[600] // Dark theme inactive
                      : Colors.grey[500]), // Light theme inactive
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                // 🎨 FIXED: Theme-aware text colors
                color: isSelected 
                    ? const Color(0xFF34C759) // Always green when selected (both themes)
                    : (isDark 
                        ? Colors.grey[600] // Dark theme inactive
                        : Colors.grey[500]), // Light theme inactive
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}