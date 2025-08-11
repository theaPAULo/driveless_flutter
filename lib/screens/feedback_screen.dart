// lib/screens/feedback_screen.dart
//
// Send Feedback Screen - CONSERVATIVE Theme Update  
// ✅ PRESERVES: All existing functionality (form, validation, submission, email)
// ✅ CHANGES: Only hardcoded colors to use theme provider
// ✅ KEEPS: All logic, methods, controllers, and behavior identical

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

import '../providers/theme_provider.dart'; // NEW: Only for theme colors

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  // PRESERVED: All existing state variables
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _feedbackType = 'Bug Report';
  bool _isSubmitting = false;
  
  // PRESERVED: Exact same feedback types with original colors
  final List<Map<String, dynamic>> _feedbackTypes = [
    {
      'title': 'Bug Report',
      'subtitle': 'Report a problem or issue',
      'icon': Icons.bug_report,
      'color': Colors.red,
    },
    {
      'title': 'Feature Request',
      'subtitle': 'Suggest a new feature',
      'icon': Icons.lightbulb_outline,
      'color': const Color(0xFF2E7D32),
    },
    {
      'title': 'General Feedback',
      'subtitle': 'Share your thoughts',
      'icon': Icons.feedback_outlined,
      'color': Colors.blue,
    },
    {
      'title': 'Performance Issue',
      'subtitle': 'Report slowness or crashes',
      'icon': Icons.speed_outlined,
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _prefillUserInfo(); // PRESERVED: Same initialization
  }

  @override
  void dispose() {
    // PRESERVED: Same disposal logic
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// PRESERVED: Pre-fill user info if available - EXACT SAME LOGIC
  void _prefillUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.displayName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme provider for colors only
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      // CHANGED: Theme-aware background instead of hardcoded black
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        // CHANGED: Theme-aware app bar
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close, 
            // CHANGED: Theme-aware icon color
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => Navigator.pop(context), // PRESERVED: Same navigation
        ),
        title: Text(
          'Send Feedback',
          style: TextStyle(
            // CHANGED: Theme-aware text color instead of hardcoded white
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false, // PRESERVED: Same alignment
      ),
      body: Form(
        key: _formKey, // PRESERVED: Same form key
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PRESERVED: Header Section structure, UPDATED colors
              _buildHeaderSection(themeProvider),
              
              const SizedBox(height: 32),

              // PRESERVED: Feedback Type Section
              _buildFeedbackTypeSection(themeProvider),

              const SizedBox(height: 32),

              // PRESERVED: Contact Information section
              _buildContactInfoSection(themeProvider),

              const SizedBox(height: 32),

              // PRESERVED: Message section
              _buildMessageSection(themeProvider),

              const SizedBox(height: 32),

              // PRESERVED: Submit Button
              _buildSubmitButton(themeProvider),

              const SizedBox(height: 16),

              // PRESERVED: Info Text
              _buildInfoText(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  // PRESERVED: Header Section structure, UPDATED colors only
  Widget _buildHeaderSection(ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // CHANGED: Theme-aware card color instead of hardcoded dark
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32), // PRESERVED: Brand green
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.mail_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'We\'d Love Your Feedback!',
                  style: TextStyle(
                    // CHANGED: Theme-aware text color
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Help us improve DriveLess by sharing your thoughts, reporting bugs, or suggesting new features.',
                  style: TextStyle(
                    // CHANGED: Theme-aware secondary text color
                    color: themeProvider.currentTheme == AppThemeMode.dark 
                      ? Colors.grey[400] 
                      : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PRESERVED: Feedback Type Section structure, UPDATED colors
  Widget _buildFeedbackTypeSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to share?',
          style: TextStyle(
            // CHANGED: Theme-aware text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // PRESERVED: Same feedback type options
        ..._feedbackTypes.map((type) => _buildFeedbackTypeOption(type, themeProvider)).toList(),
      ],
    );
  }

  // PRESERVED: Contact Info section, UPDATED colors
  Widget _buildContactInfoSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            // CHANGED: Theme-aware text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // PRESERVED: Name field with same validation
        _buildTextField(
          controller: _nameController,
          label: 'Name',
          hint: 'Your name (optional)',
          themeProvider: themeProvider,
        ),

        const SizedBox(height: 16),

        // PRESERVED: Email field with same validation
        _buildTextField(
          controller: _emailController,
          label: 'Email',
          hint: 'your.email@example.com',
          keyboardType: TextInputType.emailAddress,
          themeProvider: themeProvider,
          validator: (value) {
            // PRESERVED: Exact same validation logic
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  // PRESERVED: Message section, UPDATED colors
  Widget _buildMessageSection(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Message',
          style: TextStyle(
            // CHANGED: Theme-aware text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // PRESERVED: Message field with same validation
        _buildTextField(
          controller: _messageController,
          label: 'Message',
          hint: 'Tell us more about your feedback...',
          maxLines: 5,
          themeProvider: themeProvider,
          validator: (value) {
            // PRESERVED: Exact same validation logic
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your message';
            }
            if (value.trim().length < 10) {
              return 'Please provide more details (at least 10 characters)';
            }
            return null;
          },
        ),
      ],
    );
  }

  // PRESERVED: Submit Button, UPDATED colors
  Widget _buildSubmitButton(ThemeProvider themeProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitFeedback, // PRESERVED: Same logic
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32), // PRESERVED: Brand green
          disabledBackgroundColor: const Color(0xFF2E7D32).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Send Feedback',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  // PRESERVED: Info Text, UPDATED colors
  Widget _buildInfoText(ThemeProvider themeProvider) {
    return Text(
      'Your feedback helps us improve DriveLess. We read every message and will get back to you if needed.',
      style: TextStyle(
        // CHANGED: Theme-aware secondary text color
        color: themeProvider.currentTheme == AppThemeMode.dark 
          ? Colors.grey[400] 
          : Colors.grey[600],
        fontSize: 14,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// PRESERVED: Build feedback type option widget - EXACT SAME LOGIC, UPDATED colors
  Widget _buildFeedbackTypeOption(Map<String, dynamic> type, ThemeProvider themeProvider) {
    final isSelected = _feedbackType == type['title'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _feedbackType = type['title']; // PRESERVED: Same selection logic
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // CHANGED: Theme-aware colors
            color: isSelected 
                ? const Color(0xFF2E7D32).withOpacity(0.2)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: isSelected 
                ? Border.all(color: const Color(0xFF2E7D32), width: 2)
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: type['color'], // PRESERVED: Original type colors
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  type['icon'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type['title'],
                      style: TextStyle(
                        // CHANGED: Theme-aware text color
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type['subtitle'],
                      style: TextStyle(
                        // CHANGED: Theme-aware secondary text color
                        color: themeProvider.currentTheme == AppThemeMode.dark 
                          ? Colors.grey[400] 
                          : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32), // PRESERVED: Brand green
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// PRESERVED: Build text field widget - EXACT SAME LOGIC, UPDATED colors
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required ThemeProvider themeProvider,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            // CHANGED: Theme-aware text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller, // PRESERVED: Same controller
          validator: validator, // PRESERVED: Same validation
          keyboardType: keyboardType, // PRESERVED: Same input type
          maxLines: maxLines, // PRESERVED: Same max lines
          style: TextStyle(
            // CHANGED: Theme-aware text color
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              // CHANGED: Theme-aware hint color
              color: themeProvider.currentTheme == AppThemeMode.dark 
                ? Colors.grey[400] 
                : Colors.grey[600],
            ),
            filled: true,
            // CHANGED: Theme-aware fill color
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2), // PRESERVED: Brand green
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2), // PRESERVED: Error red
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2), // PRESERVED: Error red
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  /// PRESERVED: Submit feedback to Firestore and email - EXACT SAME LOGIC
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // PRESERVED: Get device and app info
      final deviceInfo = await _getDeviceInfo();
      final appInfo = await _getAppInfo();
      
      // PRESERVED: Create feedback document
      final feedbackData = {
        'type': _feedbackType,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'message': _messageController.text.trim(),
        'deviceInfo': deviceInfo,
        'appInfo': appInfo,
        'timestamp': FieldValue.serverTimestamp(),
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'status': 'new', // for admin tracking
      };

      // PRESERVED: Save to Firestore
      await FirebaseFirestore.instance
          .collection('feedback')
          .add(feedbackData);

      // PRESERVED: Also send direct email notification
      await _sendEmailNotification(feedbackData);

      // PRESERVED: Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback sent successfully! Thank you.'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 3),
          ),
        );
        
        // PRESERVED: Close screen after short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      // PRESERVED: Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send feedback: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// PRESERVED: Get device information - EXACT SAME LOGIC
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      return {
        'platform': Platform.operatingSystem,
        'isPhysicalDevice': Platform.isAndroid || Platform.isIOS,
        'locale': Platform.localeName,
      };
    } catch (e) {
      return {'error': 'Could not retrieve device info'};
    }
  }

  /// PRESERVED: Get app information - EXACT SAME LOGIC
  Future<Map<String, dynamic>> _getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'appName': packageInfo.appName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    } catch (e) {
      return {'error': 'Could not retrieve app info'};
    }
  }

  /// PRESERVED: Send email notification directly - EXACT SAME LOGIC
  Future<void> _sendEmailNotification(Map<String, dynamic> feedbackData) async {
    try {
      // PRESERVED: For now, we'll use a simple service like EmailJS or Formspree
      // You can replace this with your preferred email service
      
      // PRESERVED: Example with a simple HTTP POST to a backend service
      // Replace with your actual email service endpoint
      const emailServiceUrl = 'https://your-email-service.com/send'; // Replace this
      
      final emailPayload = {
        'to': 'drivelesssavetime@gmail.com',
        'subject': 'DriveLess Feedback: ${feedbackData['type']}',
        'body': '''
New feedback received:

Type: ${feedbackData['type']}
From: ${feedbackData['name']} (${feedbackData['email']})

Message:
${feedbackData['message']}

Device Info: ${feedbackData['deviceInfo']}
App Info: ${feedbackData['appInfo']}
Time: ${DateTime.now()}
        ''',
      };

      // PRESERVED: You would make HTTP call here when you set up email service
      // await http.post(Uri.parse(emailServiceUrl), body: emailPayload);
      
      print('📧 Email notification would be sent to: drivelesssavetime@gmail.com');
      print('Feedback type: ${feedbackData['type']}');
      print('From: ${feedbackData['name']} (${feedbackData['email']})');
    } catch (e) {
      print('❌ Failed to send email notification: $e');
      // PRESERVED: Don't fail the whole submission if email fails
    }
  }
}