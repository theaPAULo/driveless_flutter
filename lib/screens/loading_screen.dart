import 'package:flutter/material.dart';

/// LoadingScreenView - Recreates the iOS breathing logo animation with gradient
/// 
/// Features matching iOS app:
/// - Animated gradient background (forest green to brown)
/// - Breathing logo animation 
/// - "Drive Less, Save Time" subtitle
/// - Smooth completion callback
class LoadingScreenView extends StatefulWidget {
  final VoidCallback onAnimationComplete;
  
  const LoadingScreenView({
    super.key,
    required this.onAnimationComplete,
  });

  @override
  State<LoadingScreenView> createState() => _LoadingScreenViewState();
}

class _LoadingScreenViewState extends State<LoadingScreenView>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _gradientController;
  late AnimationController _logoController;
  late AnimationController _contentController;
  
  // Animations
  late Animation<double> _gradientAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _contentOpacityAnimation;
  
  // Colors matching iOS theme - forest green to brown gradient
  static const Color _forestGreen = Color(0xFF224B22); // Deep forest
  static const Color _primaryGreen = Color(0xFF2E7D32); // Primary green
  static const Color _oliveGreen = Color(0xFF4A6741); // Olive green  
  static const Color _brownAccent = Color(0xFF66523D); // Rich brown
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }
  
  void _initializeAnimations() {
    // Gradient animation (continuous)
    _gradientController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));
    
    // Logo breathing animation (continuous)
    _logoController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _logoScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOut,
    ));
    
    // Content fade-in animation
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    ));
  }
  
  void _startAnimationSequence() async {
    // Start continuous animations
    _gradientController.repeat(reverse: true);
    _logoController.repeat(reverse: true);
    
    // Fade in content
    await _contentController.forward();
    
    // Show loading screen for 3 seconds (matching iOS timing)
    await Future.delayed(const Duration(seconds: 3));
    
    // Complete the loading
    widget.onAnimationComplete();
  }
  
  @override
  void dispose() {
    _gradientController.dispose();
    _logoController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _gradientAnimation,
          _logoScaleAnimation,
          _contentOpacityAnimation,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              // Animated gradient background matching iOS theme
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(_forestGreen, _primaryGreen, _gradientAnimation.value)!,
                  Color.lerp(_primaryGreen, _oliveGreen, _gradientAnimation.value)!,
                  Color.lerp(_oliveGreen, _brownAccent, _gradientAnimation.value)!,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: _contentOpacityAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Breathing logo section (matching iOS)
                    Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Column(
                        children: [
                          // Main DriveLess logo text
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Colors.white,
                                Color(0xFFE0E0E0),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'DriveLess',
                              style: TextStyle(
                                fontSize: 52,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Subtitle matching iOS
                          const Text(
                            'Drive Less, Save Time',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE0E0E0),
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Subtle loading indicator (matching iOS style)
                    Container(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}