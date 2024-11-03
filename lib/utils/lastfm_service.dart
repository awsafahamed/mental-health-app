import 'dart:convert';
import 'package:http/http.dart' as http;

class LastFmService {
  final String apiKey = '5beb9fcfc75dc154e81b79b3d99b06ec';
  final String apiUrl = 'http://ws.audioscrobbler.com/2.0/';

  // Search for tracks by query
  Future<Map<String, dynamic>> searchTrack(String query) async {
    final response = await http.get(Uri.parse(
        '$apiUrl?method=track.search&track=$query&api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tracks: ${response.reasonPhrase}');
    }
  }

  // Search for albums by query
  Future<Map<String, dynamic>> searchAlbum(String query) async {
    final response = await http.get(Uri.parse(
        '$apiUrl?method=album.search&album=$query&api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load albums: ${response.reasonPhrase}');
    }
  }

  // Get top tracks
  Future<Map<String, dynamic>> getTopTracks() async {
    final response = await http.get(Uri.parse(
        '$apiUrl?method=chart.gettoptracks&api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load top tracks: ${response.reasonPhrase}');
    }
  }

  // Get suggested albums
  Future<Map<String, dynamic>> getSuggestedAlbums() async {
    final response = await http.get(Uri.parse(
        '$apiUrl?method=chart.gettopalbums&api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load suggested albums: ${response.reasonPhrase}');
    }
  }

  // Fetch details of a specific track by its ID
  Future<Map<String, dynamic>> getTrackDetails(String trackId) async {
    final response = await http.get(Uri.parse(
        '$apiUrl?method=track.getinfo&mbid=$trackId&api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load track details: ${response.reasonPhrase}');
    }
  }

  // Fetch details of a specific album by its ID
  Future<Map<String, dynamic>> getAlbumDetails(String albumId) async {
    final response = await http.get(Uri.parse(
        '$apiUrl?method=album.getinfo&mbid=$albumId&api_key=$apiKey&format=json'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load album details: ${response.reasonPhrase}');
    }
  }

  // Optional: Fetch a track's URL by its ID (if URL is not available in search results)
  Future<String?> getTrackUrl(String trackId) async {
    try {
      final details = await getTrackDetails(trackId);
      return details['track']['url'];
    } catch (e) {
      print('Failed to fetch track URL: $e');
      return null;
    }
  }
}
