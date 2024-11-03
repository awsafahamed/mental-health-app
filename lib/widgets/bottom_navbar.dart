// lib/shared_widgets.dart

import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF673AB7)],
          // New color theme
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),


      child: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.home, 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.chat_bubble_outline, 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.headset, 2),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem(Icons.person_outline, 3),
            label: '',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.transparent,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: isSelected ? const EdgeInsets.all(10) : const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ]
              : [],
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: isSelected ? 1.0 : 0.6,
          child: Icon(
            icon,
            color: isSelected ? Colors.deepOrangeAccent : Colors.deepOrangeAccent,
            size: isSelected ? 28 : 24,
          ),
        ),
      ),
    );
  }
}
