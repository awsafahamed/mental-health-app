import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class FeelingDiaryScreen extends StatefulWidget {
  const FeelingDiaryScreen({super.key});

  @override
  _FeelingDiaryScreenState createState() => _FeelingDiaryScreenState();
}

class _FeelingDiaryScreenState extends State<FeelingDiaryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _sleepingTimeController = TextEditingController();
  final TextEditingController _stressLevelController = TextEditingController();
  String _selectedMood = 'Happy';
  bool _isFormValid = false;
  bool _isStressLevelCalculated = false;

  final List<String> _moods = ['Happy', 'Sad', 'Angry', 'Excited', 'Tired'];
  AnimationController? _animationController;
  Animation<Color?>? _gradient;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _noteController.addListener(_validateForm);
    _sleepingTimeController.addListener(_validateForm);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _gradient = _animationController!.drive(
      ColorTween(
        begin: Colors.purple.shade100,
        end: Colors.purple.shade800,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _noteController.dispose();
    _sleepingTimeController.dispose();
    _stressLevelController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final sleepingTime = _sleepingTimeController.text;
    final note = _noteController.text;
    final sleepingTimeRegExp = RegExp(r'^\d{1,2}h \d{1,2}m$');

    setState(() {
      _isFormValid = sleepingTimeRegExp.hasMatch(sleepingTime) &&
          note.isNotEmpty &&
          _selectedMood.isNotEmpty;
    });
  }

  void _displayStressLevel() {
    if (_isFormValid) {
      final stressLevel = _calculateStressLevel();
      String stressDescription;

      if (stressLevel == 1) {
        stressDescription = 'Low Stress';
      } else if (stressLevel == 2) {
        stressDescription = 'Medium Stress';
      } else {
        stressDescription = 'High Stress';
      }

      _stressLevelController.text = '$stressLevel ($stressDescription)';
      setState(() {
        _isStressLevelCalculated = true;
      });
    }
  }

  int _calculateStressLevel() {
    final sleepingTime = _sleepingTimeController.text;
    if (!RegExp(r'^\d{1,2}h \d{1,2}m$').hasMatch(sleepingTime)) return 3;

    final moodScore = _getMoodScore(_selectedMood);
    final noteScore = _getNoteScore(_noteController.text);

    final sleepingTimeParts = sleepingTime.split(' ');
    final hours = int.tryParse(sleepingTimeParts[0].replaceAll('h', '')) ?? 0;
    final minutes = int.tryParse(sleepingTimeParts[1].replaceAll('m', '')) ?? 0;
    final totalMinutes = hours * 60 + minutes;

    int sleepScore;
    if (totalMinutes >= 420) {
      sleepScore = 1;
    } else if (totalMinutes >= 180 && totalMinutes < 420) {
      sleepScore = 2;
    } else {
      sleepScore = 3;
    }

    return sleepScore;
  }

  int _getMoodScore(String mood) {
    switch (mood) {
      case 'Happy':
      case 'Excited':
        return 1;
      case 'Sad':
      case 'Tired':
        return 2;
      case 'Angry':
        return 3;
      default:
        return 2;
    }
  }

  int _getNoteScore(String note) {
    if (note.contains('happy') || note.contains('good')) return 1;
    if (note.contains('sad') || note.contains('bad')) return 2;
    return 3;
  }

  String? _userId;

  Future<void> _fetchUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    setState(() {
      _userId = userId;
    });
  }

  Future<void> _pickSleepingTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _sleepingTimeController.text = '${picked.hour}h ${picked.minute}m';
        _validateForm();
      });
    }
  }

  void _saveNote() async {
    final DateTime now = DateTime.now();
    final note = _noteController.text;
    final sleepingTime = _sleepingTimeController.text;
    final stressLevel = _stressLevelController.text;

    if (_isStressLevelCalculated) {
      try {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(_userId)
            .collection('feeling_diary')
            .add({
          'date': Timestamp.fromDate(now),
          'sleeping_time': sleepingTime,
          'mood': _selectedMood,
          'note': note,
          'stress_level': stressLevel,
        });

        _noteController.clear();
        _sleepingTimeController.clear();
        _stressLevelController.clear();
        setState(() {
          _isStressLevelCalculated = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note saved successfully!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please calculate stress level before saving!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('EEEE - MMMM d, yyyy \na h:mm a');
    final String formattedDate = formatter.format(now);

    return AnimatedBuilder(
      animation: _gradient!,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Feeling Diary',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Satoshi',
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
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feeling Diary',
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontFamily: 'Satoshi',  // Use custom font here
                      fontSize: 24,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text('All notes'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feeling Diary',
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Satoshi',  // Use custom font here
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _sleepingTimeController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Enter sleeping time (e.g., 07h 25m)',
                            hintStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onTap: _pickSleepingTime,
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _selectedMood,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                          ),
                          dropdownColor: Colors.white.withOpacity(0.9),
                          items: _moods.map((mood) {
                            return DropdownMenuItem<String>(
                              value: mood,
                              child: Text(mood),
                            );
                          }).toList(),
                          onChanged: (String? newMood) {
                            setState(() {
                              _selectedMood = newMood!;
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            hintText: 'Enter your note',
                            hintStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _stressLevelController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'Stress Level',
                            hintStyle: const TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.2),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _displayStressLevel,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Calculate Stress Level',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isFormValid ? _saveNote : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Save',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
