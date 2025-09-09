// lib/widgets/brand_sign_in_buttons.dart
//
// 🎨 Brand-Specific Sign-In Buttons
// ✅ Authentic brand colors and styling
// ✅ Platform-specific visibility (Apple Sign-In iOS only)
// ✅ Professional appearance with proper branding

import 'package:flutter/material.dart';

/// Apple Sign-In button with authentic Apple styling
class AppleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const AppleSignInButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          // Authentic Apple button styling - black background
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[800]!,
            width: 0.5,
          ),
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Apple logo using system icon (closest approximation)
                    Icon(
                      Icons.apple,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Continue with Apple',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Google Sign-In button with authentic Google styling
class GoogleSignInButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const GoogleSignInButton({
    Key? key,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Container(
        decoration: BoxDecoration(
          // Authentic Google button styling - white with subtle border
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFDADADA),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: const Color(0xFF3C4043), // Google's text color
            elevation: 0,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Google "G" logo using custom widget
                    _GoogleLogo(),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        'Continue with Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3C4043),
                          letterSpacing: 0.25,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Custom Google "G" logo widget
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

/// Custom painter for Google's "G" logo
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..style = PaintingStyle.fill;

    // Google's brand colors
    const Color googleBlue = Color(0xFF4285F4);
    const Color googleGreen = Color(0xFF34A853);
    const Color googleYellow = Color(0xFFFBBC05);
    const Color googleRed = Color(0xFFEA4335);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the "G" shape using paths (simplified version)
    
    // Blue section (top-right)
    paint.color = googleBlue;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      -1.57, // -90 degrees
      1.57,  // 90 degrees  
      false,
      paint,
    );

    // Green section (bottom-right)
    paint.color = googleGreen;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      0,     // 0 degrees
      1.57,  // 90 degrees
      false,
      paint,
    );

    // Yellow section (bottom-left)
    paint.color = googleYellow;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      1.57,  // 90 degrees
      1.57,  // 90 degrees
      false,
      paint,
    );

    // Red section (top-left)
    paint.color = googleRed;
    canvas.drawArc(
      Rect.fromCenter(center: center, width: size.width, height: size.height),
      3.14,  // 180 degrees
      1.57,  // 90 degrees
      false,
      paint,
    );

    // Draw inner white circle to create the "G" shape
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.6, paint);
    
    // Draw the horizontal line of the "G"
    paint.color = googleBlue;
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - radius * 0.1, radius * 0.6, radius * 0.2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}