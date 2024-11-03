import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // App Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // Ensure this path matches your pubspec.yaml
                  height: 100,
                  width: 100,
                ),
              ),
              const SizedBox(height: 24),
              // Greeting Text
              const Text(
                "Hi there! I'm your emotional support assistant.",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF347dd6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Description Text
              const Text(
                "I'm here to help you track your mood, offer meditation tips, and provide personalized recommendations. Feel free to ask me anything!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                "To get started, you can share how you're feeling, ask for meditation advice, or request music and video recommendations.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Start Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to next screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF347dd6),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
