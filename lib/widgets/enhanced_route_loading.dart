// lib/widgets/enhanced_route_loading.dart
//
// ✨ NEW: Premium Route Optimization Loading Screen
// Features: Progressive loading states, smooth animations, engaging messaging
// Usage: Replace basic loading during route calculation

import 'package:flutter/material.dart';
import 'dart:async';

/// Enhanced loading screen for route optimization with progressive states
class EnhancedRouteLoadingScreen extends StatefulWidget {
  final VoidCallback? onCancel;
  
  const EnhancedRouteLoadingScreen({
    super.key,
    this.onCancel,
  });

  @override
  State<EnhancedRouteLoadingScreen> createState() => _EnhancedRouteLoadingScreenState();
}

class _EnhancedRouteLoadingScreenState extends State<EnhancedRouteLoadingScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;
  
  // Progress animations
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _shimmerAnimation;
  
  // Loading state management
  int _currentStage = 0;
  Timer? _stageTimer;
  
  // Loading stages with messages
  final List<LoadingStage> _loadingStages = [
    LoadingStage(
      title: "Analyzing Your Route",
      subtitle: "Calculating optimal waypoint order...",
      icon: Icons.route,
      duration: 2000,
    ),
    LoadingStage(
      title: "Checking Traffic Conditions",
      subtitle: "Finding the fastest paths...",
      icon: Icons.traffic,
      duration: 1800,
    ),
    LoadingStage(
      title: "Optimizing Travel Time",
      subtitle: "Minimizing total distance...",
      icon: Icons.speed,
      duration: 1500,
    ),
    LoadingStage(
      title: "Finalizing Your Route",
      subtitle: "Almost ready to save you time!",
      icon: Icons.check_circle,
      duration: 1200,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Progress bar animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Pulse animation for current step
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Shimmer effect animation
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _shimmerAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));

    // Start continuous animations
    _pulseController.repeat(reverse: true);
    _shimmerController.repeat();
  }

  void _startLoadingSequence() {
    _advanceToNextStage();
  }

  void _advanceToNextStage() {
    if (_currentStage < _loadingStages.length) {
      setState(() {
        // Update progress
        _progressController.animateTo((_currentStage + 1) / _loadingStages.length);
      });

      // Set timer for next stage
      final currentStageDuration = _loadingStages[_currentStage].duration;
      _stageTimer = Timer(Duration(milliseconds: currentStageDuration), () {
        setState(() {
          _currentStage++;
        });
        _advanceToNextStage();
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    _stageTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Match your app's gradient
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF34C759),
              Color(0xFF8B7355),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header with cancel button
                _buildHeader(),
                
                const SizedBox(height: 60),
                
                // Main loading content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated progress circle
                      _buildProgressCircle(),
                      
                      const SizedBox(height: 40),
                      
                      // Current stage info
                      _buildCurrentStageInfo(),
                      
                      const SizedBox(height: 60),
                      
                      // Progress steps
                      _buildProgressSteps(),
                    ],
                  ),
                ),
                
                // Bottom progress bar
                _buildBottomProgressBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Optimizing Route',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (widget.onCancel != null)
          TextButton(
            onPressed: widget.onCancel,
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildProgressCircle() {
    if (_currentStage >= _loadingStages.length) {
      // Show completion checkmark
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: Color(0xFF34C759),
          size: 60,
        ),
      );
    }

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Progress ring
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34C759)),
                    strokeWidth: 4,
                  ),
                ),
                // Center icon
                Icon(
                  _loadingStages[_currentStage].icon,
                  color: const Color(0xFF34C759),
                  size: 40,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentStageInfo() {
    if (_currentStage >= _loadingStages.length) {
      return const Column(
        children: [
          Text(
            'Route Optimized!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your optimized route is ready',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      );
    }

    final stage = _loadingStages[_currentStage];
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            stage.title,
            key: ValueKey(stage.title),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            stage.subtitle,
            key: ValueKey(stage.subtitle),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_loadingStages.length, (index) {
        final isCompleted = index < _currentStage;
        final isCurrent = index == _currentStage;
        
        return Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? Colors.white 
                    : isCurrent 
                        ? Colors.white.withOpacity(0.8)
                        : Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : _loadingStages[index].icon,
                color: isCompleted 
                    ? const Color(0xFF34C759)
                    : isCurrent 
                        ? const Color(0xFF34C759)
                        : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Step ${index + 1}',
              style: TextStyle(
                color: isCompleted || isCurrent 
                    ? Colors.white 
                    : Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildBottomProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AnimatedBuilder(
          animation: _shimmerAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: _progressAnimation.value,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                // Shimmer effect
                Positioned.fill(
                  child: Transform.translate(
                    offset: Offset(
                      _shimmerAnimation.value.dx * MediaQuery.of(context).size.width,
                      0,
                    ),
                    child: Container(
                      width: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      builder: (context, child) => child!,
    );
  }
}

/// Data class for loading stages
class LoadingStage {
  final String title;
  final String subtitle;
  final IconData icon;
  final int duration;

  LoadingStage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.duration,
  });
}