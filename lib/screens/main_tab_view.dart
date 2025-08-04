// lib/screens/main_tab_view.dart
//
// Main tab navigation matching iOS app exactly
// Contains Search (Route Input) and Profile tabs

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // MARK: - Bottom Navigation Bar (matching iOS design exactly)
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 90,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        border: Border(
          top: BorderSide(
            color: Color(0xFF38383A),
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

  // MARK: - Tab Item
  Widget _buildTabItem({
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
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
              color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[600],
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