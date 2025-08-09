// lib/screens/feedback_screen.dart
//
// Simple form-based feedback system
// Users fill out name, email, and message - gets sent directly to backend

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  String _feedbackType = 'Bug Report';
  bool _isSubmitting = false;
  
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
    _prefillUserInfo();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Pre-fill user info if available
  void _prefillUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
      _nameController.text = user.displayName ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Send Feedback',
          style: TextStyle(
            color: Colors.white,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.mail_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'We\'d Love Your Feedback!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Help us improve DriveLess by sharing your thoughts, reporting bugs, or suggesting new features.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Feedback Type Selection
              const Text(
                'What would you like to share?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),

              // Feedback Type Options
              ..._feedbackTypes.map((type) => _buildFeedbackTypeOption(type)),

              const SizedBox(height: 32),

              // Contact Information
              const Text(
                'Your Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),

              // Name Field
              _buildTextField(
                controller: _nameController,
                label: 'Name',
                hint: 'Your name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Email Field
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'your.email@example.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Message
              const Text(
                'Your Message',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),

              // Message Field
              _buildTextField(
                controller: _messageController,
                label: 'Message',
                hint: 'Tell us more about your feedback...',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your message';
                  }
                  if (value.trim().length < 10) {
                    return 'Please provide more details (at least 10 characters)';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
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
              ),

              const SizedBox(height: 16),

              // Info Text
              const Text(
                'Your feedback helps us improve DriveLess. We read every message and will get back to you if needed.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build feedback type option widget
  Widget _buildFeedbackTypeOption(Map<String, dynamic> type) {
    final isSelected = _feedbackType == type['title'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _feedbackType = type['title'];
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFF2E7D32).withOpacity(0.2)
                : const Color(0xFF2C2C2E),
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
                  color: type['color'],
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      type['subtitle'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF2E7D32),
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2C2C2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  /// Submit feedback to Firestore and email
  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get device and app info
      final deviceInfo = await _getDeviceInfo();
      final appInfo = await _getAppInfo();
      
      // Create feedback document
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

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('feedback')
          .add(feedbackData);

      // Also send direct email notification
      await _sendEmailNotification(feedbackData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Feedback sent successfully! Thank you.'),
            backgroundColor: Color(0xFF2E7D32),
            duration: Duration(seconds: 3),
          ),
        );
        
        // Close screen after short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      // Show error message
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

  /// Get device information
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

  /// Get app information
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

  /// Send email notification directly (fallback method)
  Future<void> _sendEmailNotification(Map<String, dynamic> feedbackData) async {
    try {
      // For now, we'll use a simple service like EmailJS or Formspree
      // You can replace this with your preferred email service
      
      // Example with a simple HTTP POST to a backend service
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

      // You would make HTTP call here when you set up email service
      // await http.post(Uri.parse(emailServiceUrl), body: emailPayload);
      
      print('📧 Email notification would be sent to: drivelesssavetime@gmail.com');
      print('Feedback type: ${feedbackData['type']}');
      print('From: ${feedbackData['name']} (${feedbackData['email']})');
    } catch (e) {
      print('❌ Failed to send email notification: $e');
      // Don't fail the whole submission if email fails
    }
  }
}