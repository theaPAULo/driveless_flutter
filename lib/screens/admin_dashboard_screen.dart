// lib/screens/admin_dashboard_screen.dart
//
// FIXED: Admin Dashboard with improved admin check and retry logic
// Eliminates the first-try access denial issue

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/route_storage_service.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';
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
  int _retryCount = 0;
  
  // Dashboard data
  Map<String, dynamic> _dashboardData = {};
  
  // Services
  final AnalyticsService _analyticsService = AnalyticsService();
  
  @override
  void initState() {
    super.initState();
    _checkAdminAccessWithRetry();
  }

  /// FIXED: Check admin access with retry logic to eliminate first-try failures
  Future<void> _checkAdminAccessWithRetry() async {
    const maxRetries = 3;
    const retryDelay = Duration(milliseconds: 500);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        if (EnvironmentConfig.logApiCalls) {
          print('🔐 Admin access check attempt ${attempt + 1}/$maxRetries');
        }
        
        // Add a small delay to ensure Firebase is ready
        if (attempt > 0) {
          await Future.delayed(retryDelay);
        }
        
        final AuthService authService = AuthService();
        final bool isAdmin = await authService.isUserAdmin();
        
        if (isAdmin && mounted) {
          setState(() {
            _isAuthorized = true;
            _retryCount = attempt + 1;
          });
          
          if (EnvironmentConfig.logApiCalls) {
            print('✅ Admin access granted on attempt ${attempt + 1}');
          }
          
          await _loadDashboardData();
          return; // Success, exit retry loop
        } else {
          if (EnvironmentConfig.logApiCalls) {
            print('❌ Admin access denied on attempt ${attempt + 1}');
          }
        }
        
      } catch (e) {
        if (EnvironmentConfig.logApiCalls) {
          print('❌ Admin check error on attempt ${attempt + 1}: $e');
        }
        
        // If this is the last attempt, show error
        if (attempt == maxRetries - 1) {
          if (mounted) {
            setState(() {
              _isAuthorized = false;
              _errorMessage = 'Error checking admin access: ${e.toString()}';
              _isLoading = false;
            });
          }
          return;
        }
      }
    }
    
    // If we get here, all attempts failed
    if (mounted) {
      setState(() {
        _isAuthorized = false;
        _errorMessage = 'Access denied. Admin privileges required.';
        _isLoading = false;
      });
    }
  }

  /// Load dashboard analytics data
  Future<void> _loadDashboardData() async {
    try {
      // Get route statistics
      final routeStats = await RouteStorageService.getRouteStatistics();
      
      // Get user statistics from Firestore (FIXED)
      final userStats = await _getUserStatistics();
      
      // Get analytics statistics (NEW)
      final analyticsStats = await _analyticsService.getAnalyticsStatistics();
      
      // Get system statistics
      final systemStats = await _getSystemStatistics();
      
      if (mounted) {
        setState(() {
          _dashboardData = {
            ...routeStats,
            ...userStats,
            ...analyticsStats,
            ...systemStats,
          };
          _isLoading = false;
        });
        
        if (EnvironmentConfig.logApiCalls) {
          print('✅ Dashboard data loaded successfully');
        }
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

  /// FIXED: Get user statistics from Firestore with better error handling
  Future<Map<String, dynamic>> _getUserStatistics() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final now = DateTime.now();
      
      if (EnvironmentConfig.logApiCalls) {
        print('📊 Starting user statistics collection...');
      }
      
      // Get total registered users (FIXED: Better error handling)
      final usersSnapshot = await firestore.collection('users').get();
      final totalUsers = usersSnapshot.docs.length;
      
      if (EnvironmentConfig.logApiCalls) {
        print('📊 Total users found: $totalUsers');
      }
      
      // Get new users this week (FIXED: Use createdAt field)
      final weekAgo = now.subtract(const Duration(days: 7));
      final newUsersQuery = firestore
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo));
      
      final newUsersSnapshot = await newUsersQuery.get();
      final newUsersThisWeek = newUsersSnapshot.docs.length;
      
      if (EnvironmentConfig.logApiCalls) {
        print('📊 New users this week: $newUsersThisWeek');
      }
      
      // Get active users today (FIXED: Use lastActiveAt field)
      final todayStart = DateTime(now.year, now.month, now.day);
      final activeUsersQuery = firestore
          .collection('users')
          .where('lastActiveAt', isGreaterThan: Timestamp.fromDate(todayStart));
      
      final activeUsersSnapshot = await activeUsersQuery.get();
      final activeUsersToday = activeUsersSnapshot.docs.length;
      
      if (EnvironmentConfig.logApiCalls) {
        print('📊 Active users today: $activeUsersToday');
      }
      
      // Calculate growth rate
      final lastWeekStart = weekAgo.subtract(const Duration(days: 7));
      final lastWeekUsersSnapshot = await firestore
          .collection('users')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(lastWeekStart))
          .where('createdAt', isLessThan: Timestamp.fromDate(weekAgo))
          .get();
      
      final lastWeekNewUsers = lastWeekUsersSnapshot.docs.length;
      final growthRate = lastWeekNewUsers > 0 
          ? ((newUsersThisWeek - lastWeekNewUsers) / lastWeekNewUsers * 100)
          : 0.0;
      
      return {
        'totalUsers': totalUsers,
        'newUsersThisWeek': newUsersThisWeek,
        'activeUsersToday': activeUsersToday,
        'userGrowthRate': growthRate,
      };
    } catch (e) {
      if (EnvironmentConfig.logApiCalls) {
        print('❌ Error getting user statistics: $e');
      }
      return {
        'totalUsers': 0,
        'newUsersThisWeek': 0,
        'activeUsersToday': 0,
        'userGrowthRate': 0.0,
      };
    }
  }

  /// Get system statistics with improved error tracking
  Future<Map<String, dynamic>> _getSystemStatistics() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      
      // Get error count from new errors collection
      final todayStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final errorsSnapshot = await firestore
          .collection('errors')
          .where('timestamp', isGreaterThan: Timestamp.fromDate(todayStart))
          .get();
      
      final errorCount = errorsSnapshot.docs.length;
      
      if (EnvironmentConfig.logApiCalls) {
        print('📊 Errors today: $errorCount');
      }
      
      // Get total route calculations for success rate
      final totalRoutes = _dashboardData['todayRoutes'] ?? 0;
      final successRate = (totalRoutes + errorCount) > 0 
          ? (totalRoutes / (totalRoutes + errorCount) * 100)
          : 100.0;
      
      // Get analytics events count
      final analyticsSnapshot = await firestore.collection('analytics').get();
      final totalEvents = analyticsSnapshot.docs.length;
      
      return {
        'errorCount': errorCount,
        'successRate': successRate,
        'totalEvents': totalEvents,
        'systemHealth': errorCount < 10 ? 'Healthy' : 'Warning',
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Show retry info if retries were needed
            if (_retryCount > 1)
              Text(
                'Loaded after $_retryCount attempts',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
          ],
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
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats Overview
                  _buildQuickStatsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Usage Analytics Section
                  _buildAnalyticsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // User Analytics Section
                  _buildUserAnalyticsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // System Performance Section
                  _buildSystemPerformanceSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Admin Actions Section
                  _buildAdminActionsSection(),
                ],
              ),
            ),
    );
  }

  // MARK: - Quick Stats Overview
  Widget _buildQuickStatsSection() {
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
          
          // Grid of quick stats
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Total Users',
                  '${_dashboardData['totalUsers'] ?? 0}',
                  Icons.people,
                  const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Today Routes',
                  '${_dashboardData['todayRoutes'] ?? 0}',
                  Icons.route,
                  const Color(0xFF007AFF),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildQuickStatCard(
                  'Active Today',
                  '${_dashboardData['activeUsersToday'] ?? 0}',
                  Icons.schedule,
                  const Color(0xFFFF9500),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickStatCard(
                  'Errors',
                  '${_dashboardData['errorCount'] ?? 0}',
                  Icons.error_outline,
                  _dashboardData['errorCount'] == 0 ? const Color(0xFF2E7D32) : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Usage Analytics Section
  Widget _buildAnalyticsSection() {
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
              const Icon(
                Icons.analytics,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Usage Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Route statistics
          _buildStatRow('Daily Route Calculations', '${_dashboardData['todayRoutes'] ?? 0}', const Color(0xFF2E7D32)),
          _buildStatRow('Weekly Total', '${_dashboardData['weekRoutes'] ?? 0}', const Color(0xFF007AFF)),
          _buildStatRow('Monthly Total', '${_dashboardData['monthRoutes'] ?? 0}', const Color(0xFFFF9500)),
          _buildStatRow('Average per User', '${(_dashboardData['totalUsers'] ?? 0) > 0 ? ((_dashboardData['monthRoutes'] ?? 0) / (_dashboardData['totalUsers'] ?? 1)).toStringAsFixed(1) : '0'}', const Color(0xFFAF52DE)),
        ],
      ),
    );
  }

  // MARK: - User Analytics Section
  Widget _buildUserAnalyticsSection() {
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
              const Icon(
                Icons.people,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'User Analytics',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // User statistics
          _buildStatRow('Total Registered Users', '${_dashboardData['totalUsers'] ?? 0}', const Color(0xFF2E7D32)),
          _buildStatRow('New Users This Week', '${_dashboardData['newUsersThisWeek'] ?? 0}', const Color(0xFF007AFF)),
          _buildStatRow('Active Users Today', '${_dashboardData['activeUsersToday'] ?? 0}', const Color(0xFFFF9500)),
          
          // Growth rate indicator
          const SizedBox(height: 12),
          _buildGrowthIndicator(),
        ],
      ),
    );
  }

  Widget _buildGrowthIndicator() {
    final growthRate = _dashboardData['userGrowthRate'] ?? 0.0;
    final isPositive = growthRate > 0;
    final isNegative = growthRate < 0;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPositive 
            ? const Color(0xFF2E7D32).withOpacity(0.1)
            : isNegative 
                ? Colors.red.withOpacity(0.1)
                : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isPositive 
                ? Icons.trending_up 
                : isNegative 
                    ? Icons.trending_down 
                    : Icons.trending_flat,
            color: isPositive 
                ? const Color(0xFF2E7D32)
                : isNegative 
                    ? Colors.red 
                    : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Growth Rate: ${growthRate.toStringAsFixed(1)}%',
            style: TextStyle(
              color: isPositive 
                  ? const Color(0xFF2E7D32)
                  : isNegative 
                      ? Colors.red 
                      : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - System Performance Section
  Widget _buildSystemPerformanceSection() {
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
              const Icon(
                Icons.speed,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'System Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // System statistics
          _buildStatRow('Errors Today', '${_dashboardData['errorCount'] ?? 0}', _dashboardData['errorCount'] == 0 ? const Color(0xFF2E7D32) : Colors.red),
          _buildStatRow('Success Rate', '${(_dashboardData['successRate'] ?? 100.0).toStringAsFixed(1)}%', const Color(0xFF2E7D32)),
          _buildStatRow('Total Events', '${_dashboardData['totalEvents'] ?? 0}', const Color(0xFF007AFF)),
          _buildStatRow('System Health', '${_dashboardData['systemHealth'] ?? 'Unknown'}', const Color(0xFF2E7D32)),
        ],
      ),
    );
  }

  // MARK: - Admin Actions Section
  Widget _buildAdminActionsSection() {
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
              const Icon(
                Icons.settings,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                'Admin Actions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons
          _buildActionButton('Refresh Data', Icons.refresh, () => _loadDashboardData()),
          const SizedBox(height: 12),
          _buildActionButton('Export Analytics', Icons.file_download, () => _exportAnalytics()),
          const SizedBox(height: 12),
          _buildActionButton('View Detailed Logs', Icons.list_alt, () => _viewDetailedLogs()),
          const SizedBox(height: 12),
          _buildActionButton('Manage Users', Icons.supervisor_account, () => _manageUsers()),
        ],
      ),
    );
  }

  // MARK: - Helper Widgets

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[300],
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3C3C3E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 12),
            Text(label),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
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
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.security,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage.isNotEmpty ? _errorMessage : 'Admin access required',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Go Back'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = '';
                      });
                      _checkAdminAccessWithRetry();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Action Methods (Placeholders)

  void _exportAnalytics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export analytics feature coming soon'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _viewDetailedLogs() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detailed logs feature coming soon'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  void _manageUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User management feature coming soon'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }
}