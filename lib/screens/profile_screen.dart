import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/widgets/bottom_navbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String profileImageUrl = '/lib/assets/images/logo.png'; // Initial profile image URL
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 3;

  String _userName = "User"; // Default user name
  String _userEmail = "user@example.com"; // Default user email

  Future<void> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _userName = userData?['name'] ?? "User";
            _userEmail = userData?['email'] ?? "user@example.com";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        profileImageUrl = image.path;
      });
    }
  }

  void _onItemTapped(int index) {
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
        Navigator.pushNamed(context, '/music');
        break;
      case 3:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Montserrat',
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF673AB7), Color(0xFF673AB7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: profileImageUrl.startsWith('http')
                            ? NetworkImage(profileImageUrl)
                            : FileImage(File(profileImageUrl)),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.blueAccent),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    _userEmail,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  ),
                ),
                const Divider(color: Colors.black),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.black),
                  title: const Text(
                    'Name',
                    style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                  subtitle: Text(_userName, style: const TextStyle(color: Colors.black)),
                ),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.black),
                  title: const Text(
                    'Email',
                    style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                  subtitle: Text(_userEmail, style: const TextStyle(color: Colors.black)),
                ),
                const ListTile(
                  leading: Icon(Icons.phone, color: Colors.black),
                  title: Text(
                    'Phone',
                    style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                  subtitle: Text(
                    '+1234567890',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.location_on, color: Colors.black),
                  title: Text(
                    'Address',
                    style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                  subtitle: Text(
                    '123 Main Street, City, Country',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    color: Colors.black,
                  ),
                ),
                const Divider(color: Colors.black),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.black),
                  title: const Text(
                    'Change Password',
                    style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/changePassword');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.black),
                  title: const Text(
                    'Notifications',
                    style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                  onTap: () {
                    // Handle notifications action
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.black),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.black, fontFamily: 'Montserrat'),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
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
}

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
      fontFamily: 'Montserrat',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    ),
    initialRoute: '/profile',
    routes: {
      '/profile': (context) => ProfileScreen(),
    },
  ));
}
