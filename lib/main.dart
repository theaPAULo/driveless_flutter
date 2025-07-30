import 'package:flutter/material.dart';

void main() {
  runApp(const DriveLessApp());
}



class DriveLessApp extends StatelessWidget {
  const DriveLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DriveLess',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // DriveLess brand colors - matching your iOS app
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF2E7D32), // Dark green
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        
        // App bar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        
        // Elevated button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // DriveLess logo/title
            const Text(
              'DriveLess',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Flutter Version',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Show a snackbar when pressed
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Route planning coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Start Planning Routes'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Flutter cross-platform version',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}