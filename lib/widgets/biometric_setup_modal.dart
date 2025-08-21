// lib/widgets/biometric_setup_modal.dart
//
// 🔐 Biometric Setup Modal Widget
// ✅ iOS-style design matching app theme
// ✅ Clear setup instructions and benefits
// ✅ Smooth animations and haptic feedback

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../services/haptic_feedback_service.dart';

class BiometricSetupModal extends StatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  const BiometricSetupModal({
    Key? key,
    this.onComplete,
    this.onSkip,
  }) : super(key: key);

  @override
  State<BiometricSetupModal> createState() => _BiometricSetupModalState();
}

class _BiometricSetupModalState extends State<BiometricSetupModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  bool _isSettingUp = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: _buildContent(context, isDark),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final biometricAuth = authProvider.biometricAuth;
        
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Biometric Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    biometricAuth.getBiometricIcon(),
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Title
              Text(
                'Enable ${biometricAuth.getBiometricTypeName()}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Description
              Text(
                biometricAuth.getSetupInstructions(),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.grey[300] : Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
              
              // Benefits list
              _buildBenefitsList(isDark),
              
              const SizedBox(height: 32),
              
              // Action buttons
              _buildActionButtons(context, authProvider, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitsList(bool isDark) {
    final benefits = [
      '🚀 Quick and secure access',
      '🔒 Your data stays on your device',
      '⚡ No need to remember passwords',
    ];

    return Column(
      children: benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Text(
                benefit.split(' ').first,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  benefit.substring(benefit.indexOf(' ') + 1),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, AuthProvider authProvider, bool isDark) {
    return Column(
      children: [
        // Enable Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSettingUp ? null : () => _handleEnableBiometric(authProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34C759),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isSettingUp
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Enable ${authProvider.biometricAuth.getBiometricTypeName()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Skip Button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isSettingUp ? null : _handleSkip,
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Skip for now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleEnableBiometric(AuthProvider authProvider) async {
    setState(() {
      _isSettingUp = true;
    });

    try {
      await hapticFeedback.toggle();
      
      final success = await authProvider.showBiometricSetup();
      
      if (success) {
        await hapticFeedback.success();
        
        // Animate out
        await _animationController.reverse();
        
        if (mounted) {
          Navigator.of(context).pop();
          widget.onComplete?.call();
        }
      } else {
        await hapticFeedback.error();
        
        if (mounted) {
          setState(() {
            _isSettingUp = false;
          });
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                authProvider.errorMessage ?? 'Failed to enable biometric authentication',
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    } catch (e) {
      await hapticFeedback.error();
      
      if (mounted) {
        setState(() {
          _isSettingUp = false;
        });
      }
    }
  }

  Future<void> _handleSkip() async {
    await hapticFeedback.toggle();
    
    // Mark as shown so we don't ask again immediately
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.markBiometricPromptShown();
    
    // Animate out
    await _animationController.reverse();
    
    if (mounted) {
      Navigator.of(context).pop();
      widget.onSkip?.call();
    }
  }

  /// Show biometric setup modal
  static Future<void> show(
    BuildContext context, {
    VoidCallback? onComplete,
    VoidCallback? onSkip,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => BiometricSetupModal(
        onComplete: onComplete,
        onSkip: onSkip,
      ),
    );
  }
}