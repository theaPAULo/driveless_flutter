// lib/screens/admin_dashboard_screen.dart
//
// Admin Dashboard screen with analytics and user management
// Requires admin authentication via Firebase UID verification

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/route_storage_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  bool _isAuthorized = false;
  String _errorMessage = '';
  
  // Dashboard data
  Map<String, dynamic> _dashboardData = {};
  
  @override
  void initState() {
    super.initState();
    _checkAdminAccess();
  }

  /// Check if current user is authorized as admin
  Future<void> _checkAdminAccess() async {
    try {
      final AuthService authService = AuthService();
      final bool isAdmin = await authService.isUserAdmin();
      
      if (isAdmin && mounted) {
        setState(() {
          _isAuthorized = true;
        });
        await _loadDashboardData();
      } else {
        setState(() {
          _isAuthorized = false;
          _errorMessage = 'Access denied. Admin privileges required.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAuthorized = false;
          _errorMessage = 'Error checking admin access: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  /// Load dashboard analytics data
  Future<void> _loadDashboardData() async {
    try {
      // Get route statistics
      final routeStats = await RouteStorageService.getRouteStatistics();
      
      // Get user statistics from Firestore
      final userStats = await _getUserStatistics();
      
      // Get system statistics
      final systemStats = await _getSystemStatistics();
      
      if (mounted) {
        setState(() {
          _dashboardData = {
            ...routeStats,
            ...userStats,
            ...systemStats,
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading dashboard data: ${e.toString()}';
          _isLoading = false;
        });
      }
      
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error loading dashboard data: $e');
      }
    }
  }

  /// Get user statistics from Firestore
  Future<Map<String, dynamic>> _getUserStatistics() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Get total registered users
      final usersSnapshot = await firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      
      // Get new users this week
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final newUsersSnapshot = await firestore
          .collection('users')
          .where('updatedAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .get();
      final newUsersThisWeek = newUsersSnapshot.docs.length;
      
      // Get active users today (users who signed in today)
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final activeUsersSnapshot = await firestore
          .collection('users')
          .where('lastActiveAt', isGreaterThan: Timestamp.fromDate(todayStart))
          .get();
      final activeUsersToday = activeUsersSnapshot.docs.length;
      
      return {
        'totalUsers': totalUsers,
        'newUsersThisWeek': newUsersThisWeek,
        'activeUsersToday': activeUsersToday,
      };
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error getting user statistics: $e');
      }
      return {
        'totalUsers': 0,
        'newUsersThisWeek': 0,
        'activeUsersToday': 0,
      };
    }
  }

  /// Get system statistics
  Future<Map<String, dynamic>> _getSystemStatistics() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Get error count (you can implement error logging later)
      final errorCount = 0; // Placeholder
      
      // Calculate success rate
      final totalOperations = _dashboardData['totalRoutes'] ?? 1;
      final successRate = totalOperations > 0 ? 
          ((totalOperations - errorCount) / totalOperations * 100) : 100.0;
      
      // Get analytics events count
      final analyticsSnapshot = await firestore.collection('analytics').get();
      final totalEvents = analyticsSnapshot.docs.length;
      
      return {
        'errorCount': errorCount,
        'successRate': successRate,
        'totalEvents': totalEvents,
        'systemHealth': 'Healthy',
      };
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error getting system statistics: $e');
      }
      return {
        'errorCount': 0,
        'successRate': 100.0,
        'totalEvents': 0,
        'systemHealth': 'Unknown',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthorized) {
      return _buildUnauthorizedView();
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadDashboardData();
            },
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildDashboardView(),
    );
  }

  // MARK: - Unauthorized View
  Widget _buildUnauthorizedView() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Access Denied',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.admin_panel_settings,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Admin Access Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage.isNotEmpty ? _errorMessage : 
                'You need admin privileges to access this dashboard.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Loading View
  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF2E7D32),
          ),
          SizedBox(height: 16),
          Text(
            'Loading dashboard...',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Dashboard View
  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Stats Overview
          _buildQuickStatsCard(),
          
          const SizedBox(height: 24),
          
          // User Analytics
          _buildUserAnalyticsCard(),
          
          const SizedBox(height: 24),
          
          // Route Analytics
          _buildRouteAnalyticsCard(),
          
          const SizedBox(height: 24),
          
          // System Health
          _buildSystemHealthCard(),
          
          const SizedBox(height: 24),
          
          // Admin Actions
          _buildAdminActionsCard(),
        ],
      ),
    );
  }

  // MARK: - Quick Stats Card
  Widget _buildQuickStatsCard() {
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
          const Text(
            'Quick Overview',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              _buildQuickStat(
                'Total Users',
                '${_dashboardData['totalUsers'] ?? 0}',
                Icons.people,
                const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 20),
              _buildQuickStat(
                'Total Routes',
                '${_dashboardData['totalRoutes'] ?? 0}',
                Icons.route,
                const Color(0xFF007AFF),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildQuickStat(
                'Active Today',
                '${_dashboardData['activeUsersToday'] ?? 0}',
                Icons.trending_up,
                const Color(0xFF34C759),
              ),
              const SizedBox(width: 20),
              _buildQuickStat(
                'Success Rate',
                '${(_dashboardData['successRate'] ?? 100.0).toStringAsFixed(1)}%',
                Icons.check_circle,
                const Color(0xFFFF9500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
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
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - User Analytics Card
  Widget _buildUserAnalyticsCard() {
    return _buildAnalyticsCard(
      title: 'User Analytics',
      icon: Icons.people_outline,
      children: [
        _buildAnalyticRow('Total Registered Users', '${_dashboardData['totalUsers'] ?? 0}'),
        _buildAnalyticRow('New Users This Week', '${_dashboardData['newUsersThisWeek'] ?? 0}'),
        _buildAnalyticRow('Active Users Today', '${_dashboardData['activeUsersToday'] ?? 0}'),
      ],
    );
  }

  // MARK: - Route Analytics Card
  Widget _buildRouteAnalyticsCard() {
    return _buildAnalyticsCard(
      title: 'Route Analytics',
      icon: Icons.analytics_outlined,
      children: [
        _buildAnalyticRow('Total Routes Calculated', '${_dashboardData['totalRoutes'] ?? 0}'),
        _buildAnalyticRow('Favorite Routes', '${_dashboardData['favoriteRoutes'] ?? 0}'),
        _buildAnalyticRow('Total Time Saved', '${(_dashboardData['totalTimeSaved'] ?? 0.0).toStringAsFixed(1)} hours'),
        _buildAnalyticRow('CO₂ Saved', '${(_dashboardData['co2Saved'] ?? 0.0).toStringAsFixed(1)} lbs'),
      ],
    );
  }

  // MARK: - System Health Card
  Widget _buildSystemHealthCard() {
    return _buildAnalyticsCard(
      title: 'System Health',
      icon: Icons.health_and_safety_outlined,
      children: [
        _buildAnalyticRow('System Status', _dashboardData['systemHealth'] ?? 'Unknown'),
        _buildAnalyticRow('Success Rate', '${(_dashboardData['successRate'] ?? 100.0).toStringAsFixed(1)}%'),
        _buildAnalyticRow('Total Errors', '${_dashboardData['errorCount'] ?? 0}'),
        _buildAnalyticRow('Analytics Events', '${_dashboardData['totalEvents'] ?? 0}'),
      ],
    );
  }

  // MARK: - Admin Actions Card
  Widget _buildAdminActionsCard() {
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
          const Row(
            children: [
              Icon(Icons.admin_panel_settings, color: Color(0xFF2E7D32)),
              SizedBox(width: 12),
              Text(
                'Admin Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildActionButton(
            'Export Analytics',
            Icons.download,
            () => _exportAnalytics(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionButton(
            'View Error Logs',
            Icons.error_outline,
            () => _viewErrorLogs(),
          ),
          
          const SizedBox(height: 12),
          
          _buildActionButton(
            'Manage Users',
            Icons.people_alt,
            () => _manageUsers(),
          ),
        ],
      ),
    );
  }

  // MARK: - Helper Widgets
  Widget _buildAnalyticsCard({
    required String title,
    required IconData icon,
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAnalyticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF2E7D32), size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Admin Action Methods
  void _exportAnalytics() {
    // TODO: Implement analytics export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Analytics export feature coming soon'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _viewErrorLogs() {
    // TODO: Implement error logs view
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error logs feature coming soon'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _manageUsers() {
    // TODO: Implement user management
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User management feature coming soon'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }
}