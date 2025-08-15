// lib/screens/main_tab_view.dart
//
// FIXED: Main tab navigation with NO OVERFLOW issues
// ✅ IMPROVED: Proper SafeArea handling for bottom navigation
// ✅ IMPROVED: Responsive height that adapts to device

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // MARK: - Flutter Built-in BottomNavigationBar (handles safe areas automatically)
  Widget _buildBottomNavigationBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onTabTapped,
      type: BottomNavigationBarType.fixed,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      selectedItemColor: const Color(0xFF34C759),
      unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.map_outlined),
          activeIcon: Icon(Icons.map),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  // MARK: - Tab Selection Handler
  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}