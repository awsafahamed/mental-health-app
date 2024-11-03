import 'package:emotions_support_app/screens/home_screen.dart';
import 'package:emotions_support_app/screens/music_screen.dart';
import 'package:emotions_support_app/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for Montserrat
import 'package:url_launcher/url_launcher.dart';
import '/utils/youtube_service.dart';
import '/widgets/bottom_navbar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final YouTubeService _youTubeService = YouTubeService();
  int _selectedIndex = 1;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Emotion detection and response generation functions remain unchanged

  String _detectEmotion(String text) {
    if (text.contains(RegExp(r'happy|joy|glad|excited|elated|cheerful|delighted|content|thrilled'))) {
      return 'happy';
    } else if (text.contains(RegExp(r'sad|down|unhappy|depressed|gloomy|miserable|heartbroken|melancholy'))) {
      return 'sad';
    } else if (text.contains(RegExp(r'angry|mad|furious|irritated|annoyed|frustrated|enraged'))) {
      return 'angry';
    } else if (text.contains(RegExp(r'anxious|nervous|worried|tense|stressed|overwhelmed'))) {
      return 'anxious';
    } else if (text.contains(RegExp(r'lonely|isolated|alone|abandoned'))) {
      return 'lonely';
    } else if (text.contains(RegExp(r'loved|appreciated|cared|cherished|adored'))) {
      return 'loved';
    } else if (text.contains(RegExp(r'tired|exhausted|drained|fatigued'))) {
      return 'tired';
    } else if (text.contains(RegExp(r'confused|lost|uncertain|doubtful'))) {
      return 'confused';
    } else {
      return 'neutral';
    }
  }

  String _generateResponse(String emotion) {
    switch (emotion) {
      case 'happy':
        return "That's amazing! I love hearing that you're feeling happy. Keep shining and spreading those positive vibes!";
      case 'sad':
        return "I'm really sorry you're feeling this way. Remember, it's okay to feel sad, and I'm here to help you through it.";
      case 'angry':
        return "I understand that you're angry. It's a strong emotion, but it can pass. Let's find a way to calm down together.";
      case 'anxious':
        return "I get that you're feeling anxious. Try to breathe slowly, and I'm here to guide you through whatever is making you feel this way.";
      case 'lonely':
        return "It's tough feeling lonely, but you're not alone. I’m here with you, and we can talk anytime you need.";
      case 'loved':
        return "It's wonderful that you're feeling loved! Those connections are so important. Hold onto that feeling.";
      case 'tired':
        return "Sounds like you're feeling tired. Maybe some rest or relaxation will help recharge you. Remember to take care of yourself.";
      case 'confused':
        return "Feeling confused can be unsettling. Let’s talk it through. I’ll help you find some clarity.";
      default:
        return "Hi there! I'm here to listen. How can I assist you today?";
    }
  }

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });

    _controller.clear();
    String emotion = _detectEmotion(text);
    String response = _generateResponse(emotion);

    setState(() {
      _messages.add({'sender': 'bot', 'text': response});
    });

    if (emotion != 'neutral') {
      try {
        Map<String, String> videoRecommendation = await _youTubeService.getRecommendationWithThumbnail(emotion);
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': videoRecommendation['title'] ?? '',
            'url': videoRecommendation['url'] ?? '',
            'thumbnail': videoRecommendation['thumbnail'] ?? ''
          });
        });
      } catch (e) {
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': 'Sorry, I could not fetch a video recommendation at this time.',
          });
        });
      }
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUserMessage = message['sender'] == 'user';
    bool isLinkMessage = message.containsKey('url') && message['url']!.isNotEmpty;

    if (isLinkMessage) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: Colors.blueAccent.shade100,
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            children: [
              Image.network(
                message['thumbnail']!,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, color: Colors.red);
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => _launchURL(message['url']!),
                  child: Text(
                    message['text']!,
                    style: GoogleFonts.montserrat(
                      textStyle: const TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isUserMessage ? Colors.purple.shade100 : Colors.purple.shade200,

            borderRadius: isUserMessage
                ? const BorderRadius.only(
              topLeft: Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            )
                : const BorderRadius.only(
              topRight: Radius.circular(15.0),
              bottomLeft: Radius.circular(15.0),
              bottomRight: Radius.circular(15.0),
            ),
          ),
          child: Text(
            message['text'] ?? '',
            style: GoogleFonts.montserrat(),
          ),
        ),
      );
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
        title: Text(
          'ChatBot Assistant',
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.montserrat(color: Colors.deepPurple), // Set text color to white
                      decoration: InputDecoration(
                        hintText: 'Enter your message',
                        hintStyle: GoogleFonts.montserrat(color: Colors.deepPurple), // Set hint text color to white
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple), // White border when not focused
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.deepPurple), // White border when focused
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.deepPurple),
                    onPressed: _sendMessage,
                  ),
                ],
              ),

            ),
          ],
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
      textTheme: GoogleFonts.montserratTextTheme(),
    ),
    initialRoute: '/chatbot',
    routes: {
      '/home': (context) => HomeScreen(),
      '/chatbot': (context) => ChatScreen(),
      '/music': (context) => MusicScreen(),
      '/profile': (context) => ProfileScreen(),
    },
  ));
}
