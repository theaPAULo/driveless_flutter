// lib/widgets/haptic_settings_widget.dart
//
// Haptic Feedback Settings Widget - Add to your Settings screen
// ✅ Toggle to enable/disable haptics
// ✅ Matches iOS settings design
// ✅ Provides haptic feedback when toggling

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/haptic_feedback_service.dart';

class HapticSettingsWidget extends StatelessWidget {
  const HapticSettingsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HapticFeedbackService>(
      builder: (context, hapticService, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.vibration,
                  color: Color(0xFF34C759),
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Haptic Feedback',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Feel vibrations for button taps and events',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Toggle Switch
              Switch(
                value: hapticService.isEnabled,
                onChanged: (value) async {
                  // Set the new haptic state
                  await hapticService.setEnabled(value);
                },
                activeColor: const Color(0xFF34C759),
                activeTrackColor: const Color(0xFF34C759).withOpacity(0.3),
              ),
            ],
          ),
        );
      },
    );
  }
}

// MARK: - Quick Integration Example
// Add this to your existing settings screen:
/*

// In your settings screen build method, add:
Column(
  children: [
    // Your existing settings...
    
    // Add haptic settings
    HapticSettingsWidget(),
    
    // Your other settings...
  ],
)

*/