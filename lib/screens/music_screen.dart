import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/utils/lastfm_service.dart';
import 'music_player_screen.dart';
import '/widgets/bottom_navbar.dart'; // Import the BottomNavBar widget

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  _MusicScreenState createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final LastFmService _lastFmService = LastFmService();
  List<dynamic> _tracks = [];
  String _query = '';
  bool _isLoading = false;
  int _selectedIndex = 2; // Set default index to 2 for MusicScreen

  @override
  void initState() {
    super.initState();
    _fetchTopTracks(); // Fetch top tracks automatically when screen is loaded
  }

  void _search(String query) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _lastFmService.searchTrack(query);
      setState(() {
        _tracks = data['results']['trackmatches']['track'];
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _fetchTopTracks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final data = await _lastFmService.getTopTracks();
      setState(() {
        _tracks = data['tracks']['track'];
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playTrack(String trackUrl, String trackName, String artistName, String trackImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayerScreen(
          trackUrl: trackUrl,
          trackName: trackName,
          artistName: artistName,
          trackImage: trackImage,
          albumArtUrl: '',
        ),
      ),
    );
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
          'Music Search',
          style: GoogleFonts.montserrat(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                style: GoogleFonts.montserrat(color: Colors.deepPurple),
                decoration: InputDecoration(
                  labelText: 'Search for a track',
                  labelStyle: GoogleFonts.montserrat(color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.deepPurple),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _search(_query),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text('Search', style: GoogleFonts.montserrat(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 10),
              Text('Most Listened Songs', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black)),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : _tracks.isEmpty
                    ? Center(child: Text('No results found', style: GoogleFonts.montserrat(color: Colors.black)))
                    : AnimatedList(
                  initialItemCount: _tracks.length,
                  itemBuilder: (context, index, animation) {
                    final track = _tracks[index];
                    final trackUrl = track['url'] ?? ''; // Handle nullable URLs
                    final trackName = track['name'] ?? 'Unknown Track';
                    final trackArtist = track['artist']['name'] ?? 'Unknown Artist';
                    final trackImage = track['image'] != null && track['image'].isNotEmpty
                        ? track['image'][2]['#text'] ?? 'https://via.placeholder.com/150'
                        : 'https://via.placeholder.com/150'; // Default image if null

                    return SlideTransition(
                      position: animation.drive(Tween(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      )),
                      child: ListTile(
                        title: Text(trackName, style: GoogleFonts.montserrat(color: Colors.black)),
                        subtitle: Text(trackArtist, style: GoogleFonts.montserrat(color: Colors.black)),
                        leading: Image.network(trackImage, height: 50, fit: BoxFit.cover),
                        onTap: () => _playTrack(trackUrl, trackName, trackArtist, trackImage),
                      ),
                    );
                  },
                ),
              ),
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
}
