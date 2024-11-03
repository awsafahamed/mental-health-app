import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feeling_diary_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'music_screen.dart';
import '/widgets/bottom_navbar.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _showYoutubeVideo = true;
  String _userName = "User";
  String? _userId;

  final Map<String, String> _selectedVideo = {
    'url': 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    'thumbnail': 'https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg',
  };

  String _latestSleepingTime = '';
  String _latestMood = '';
  String _latestStressLevel = '';

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _chooseContent();
    _fetchUserName();
    getFeelingDiaryEntries();
  }

  Future<void> _fetchUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
          setState(() {
            _userName = userData?['name'] ?? "User";
            _userId = userId;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
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

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _chooseContent() {
    setState(() {
      _showYoutubeVideo = Random().nextBool();
    });
  }

  Future<void> getFeelingDiaryEntries() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(_userId)
          .collection('feeling_diary')
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          _latestSleepingTime = data['sleeping_time'];
          _latestMood = data['mood'];
          _latestStressLevel = data['stress_level'].toString();
        });
      }
    } catch (e) {
      print('Error fetching feeling diary entries: $e');
    }
  }

  void _navigateToLoginPage() {
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildGreetingSection(),
              _buildOverviewSection(),
              _buildFeelingDiaryButton(),
              _buildMeditationTipsButton(),
              const SizedBox(height: 60),
              _buildBarChart()
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Color(0xFFB7A7FA),
      ),
      child: Row(
        children: [
          Text(
            'Hi ${_userName[0].toUpperCase()}${_userName.substring(1)} 👋 !',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              fontFamily: 'Satoshi',
              color: Colors.white,
            ),
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _navigateToLoginPage,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text('Today\'s Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Satoshi')),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAnimatedCard('Sleeping Time', _latestSleepingTime, Color(0xFFD7C9F5)),
              _buildAnimatedCard('Mood', _latestMood, Color(0xFFD7C9F5)),
              _buildAnimatedCard('Stress', _latestStressLevel,Color(0xFFD7C9F5)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(String title, String data, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Satoshi')),
            const SizedBox(height: 10),
            Text(data, style: const TextStyle(fontSize: 12, fontFamily: 'Satoshi')),
          ],
        ),
      ),
    );
  }


  Widget _buildFeelingDiaryButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFB7A7FA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          minimumSize: Size(double.infinity, 56),
        ),
        onPressed: () => Navigator.pushNamed(context, '/feelingDiary'),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '  Feeling Diary',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontFamily: 'Satoshi',
              ),
            ),
            Icon(Icons.edit, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationTipsButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/meditationTips'),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFD7C9F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.mic, color: Colors.black),
              SizedBox(width: 8),
              Text('Meditation Tips', style: TextStyle(fontSize: 18, fontFamily: 'Satoshi')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 10,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return Text(days[value.toInt()]);
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 8, color: Colors.deepPurpleAccent)]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 6, color: Colors.deepPurpleAccent)]),
            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 4, color: Colors.deepPurpleAccent)]),
            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 7, color: Colors.deepPurpleAccent)]),
            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 0, color: Colors.deepPurpleAccent)]),
            BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 0, color: Colors.deepPurpleAccent)]),
            BarChartGroupData(x: 6, barRods: [BarChartRodData(toY: 0, color: Colors.deepPurpleAccent)]),
          ],
        ),
      ),
    );
  }
}
