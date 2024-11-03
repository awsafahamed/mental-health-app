import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // For satoshi font
import '/widgets/bottom_navbar.dart'; // Ensure this path is correct

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  _MeditationScreenState createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  int _selectedIndex = 2; // Index for the current screen

  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.pushNamed(context, '/home');
          break;
        case 1:
          Navigator.pushNamed(context, '/chatbot');
          break;
        case 2:
          Navigator.pushNamed(context, '/meditation'); // Current screen
          break;
        case 3:
          Navigator.pushNamed(context, '/profile');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          'Mediation Tips',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'satoshi',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFF7B61FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMeditationCard(
                  context,
                  title: "Feeling Stressed?",
                  description:
                  "Try a 5-minute guided meditation to relax. Would you like me to find one for you?",
                  icon: Icons.spa,
                ),
                const SizedBox(height: 20),
                _buildMeditationCard(
                  context,
                  title: "Mindfulness Reminder",
                  description:
                  "Taking a few deep breaths can help calm your mind. Would you like a reminder to practice mindfulness throughout the day?",
                  icon: Icons.notifications,
                ),
                const SizedBox(height: 20),
                Text(
                  "Meditation Tips",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Satoshi',  // Use custom font here
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTipCard(
                  context,
                  "1. Focus on your breath: Take deep, slow breaths to help calm your mind.",
                ),
                _buildTipCard(
                  context,
                  "2. Scan your body: Close your eyes and slowly focus on each part of your body, releasing any tension.",
                ),
                _buildTipCard(
                  context,
                  "3. Be present: Bring your attention to the current moment without judgment. Let go of thoughts about the past or future.",
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildMeditationCard(BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.blue.shade600),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Satoshi',  // Use custom font here
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontFamily: 'Satoshi',  // Use custom font here
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(BuildContext context, String tip) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          tip,
          style: const TextStyle(
            color: Colors.black87,
            fontFamily: 'Satoshi',  // Use custom font here
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
