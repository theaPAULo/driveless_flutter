// lib/utils/responsive_utils.dart
//
// 📱 Responsive Layout Utilities - Handle Different Screen Sizes
// ✅ Prevent UI overflow and off-screen content issues
// ✅ Adaptive layouts for phones, tablets, and different orientations

import 'package:flutter/material.dart';

/// Screen size categories for responsive layouts
enum ScreenSize { 
  small,   // < 360dp width
  medium,  // 360-600dp width  
  large,   // 600-1024dp width
  xlarge   // > 1024dp width
}

/// Device type based on screen characteristics
enum DeviceType {
  phone,
  tablet,
  desktop
}

/// Responsive layout utilities
class ResponsiveUtils {
  
  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < 360) return ScreenSize.small;
    if (width < 600) return ScreenSize.medium;
    if (width < 1024) return ScreenSize.large;
    return ScreenSize.xlarge;
  }
  
  /// Get device type
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final diagonal = (width * width + height * height) / 100;
    
    if (width < 600) return DeviceType.phone;
    if (diagonal < 1100) return DeviceType.tablet;
    return DeviceType.desktop;
  }
  
  /// Check if screen is small and needs compact layout
  static bool isSmallScreen(BuildContext context) {
    return getScreenSize(context) == ScreenSize.small;
  }
  
  /// Check if screen is landscape
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  /// Get safe horizontal padding based on screen size
  static double getHorizontalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return 16.0;
      case ScreenSize.medium:
        return 20.0;
      case ScreenSize.large:
        return 32.0;
      case ScreenSize.xlarge:
        return 48.0;
    }
  }
  
  /// Get safe vertical padding
  static double getVerticalPadding(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return 12.0;
      case ScreenSize.medium:
        return 16.0;
      case ScreenSize.large:
        return 24.0;
      case ScreenSize.xlarge:
        return 32.0;
    }
  }
  
  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return baseSize * 0.9;
      case ScreenSize.medium:
        return baseSize;
      case ScreenSize.large:
        return baseSize * 1.1;
      case ScreenSize.xlarge:
        return baseSize * 1.2;
    }
  }
  
  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return baseSize * 0.9;
      case ScreenSize.medium:
        return baseSize;
      case ScreenSize.large:
        return baseSize * 1.1;
      case ScreenSize.xlarge:
        return baseSize * 1.2;
    }
  }
  
  /// Get maximum content width (prevents excessive width on large screens)
  static double getMaxContentWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return double.infinity;
      case DeviceType.tablet:
        return 600;
      case DeviceType.desktop:
        return 800;
    }
  }
  
  /// Get responsive button height
  static double getButtonHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return 44.0; // Minimum touch target
      case ScreenSize.medium:
        return 48.0;
      case ScreenSize.large:
        return 52.0;
      case ScreenSize.xlarge:
        return 56.0;
    }
  }
  
  /// Check if we should use compact layout (small screens in portrait)
  static bool shouldUseCompactLayout(BuildContext context) {
    return isSmallScreen(context) && !isLandscape(context);
  }
  
  /// Get responsive spacing
  static double getSpacing(BuildContext context, double baseSpacing) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return baseSpacing * 0.75;
      case ScreenSize.medium:
        return baseSpacing;
      case ScreenSize.large:
        return baseSpacing * 1.25;
      case ScreenSize.xlarge:
        return baseSpacing * 1.5;
    }
  }
}

/// Widget for responsive layouts
class ResponsiveLayout extends StatelessWidget {
  final Widget? phone;
  final Widget? tablet;
  final Widget? desktop;
  final Widget child;
  
  const ResponsiveLayout({
    Key? key,
    this.phone,
    this.tablet,
    this.desktop,
    required this.child,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.phone:
        return phone ?? child;
      case DeviceType.tablet:
        return tablet ?? child;
      case DeviceType.desktop:
        return desktop ?? child;
    }
  }
}

/// Responsive container that centers content on large screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  
  const ResponsiveContainer({
    Key? key,
    required this.child,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtils.getMaxContentWidth(context);
    final horizontalPadding = ResponsiveUtils.getHorizontalPadding(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: maxWidth == double.infinity
          ? child
          : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: child,
              ),
            ),
    );
  }
}