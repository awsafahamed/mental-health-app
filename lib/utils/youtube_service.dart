import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class YouTubeService {
  final String apiKey = 'AIzaSyA8Eo8R0_kHQ8H4gVReEB68K2Upe63kha8'; // Replace with your YouTube API key

  // Fetch a recommended video based on the user's emotion
  Future<Map<String, String>> getRecommendationWithThumbnail(String emotion) async {
    List<String> queries = _getSearchQueries(emotion);
    
    String query = queries[Random().nextInt(queries.length)];

    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&key=$apiKey'),
      );

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw Exception('Failed to fetch video: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching video: $e');
    }
  }

  // Return a list of queries based on the specified emotion
  List<String> _getSearchQueries(String emotion) {
    switch (emotion) {
      case 'happy':
        return ['happy music', 'upbeat songs', 'feel good music'];
      case 'sad':
        return ['comforting music', 'sad songs', 'soothing tunes'];
      case 'angry':
        return ['calming music', 'relaxing sounds', 'stress relief music'];
      default:
        return ['uplifting music', 'motivational songs', 'positive vibes'];
    }
  }

  // Parse the API response and extract video information
  Map<String, String> _parseResponse(String responseBody) {
    final data = jsonDecode(responseBody);
    final items = data['items'] as List;

    if (items.isEmpty) {
      throw Exception('No results found');
    }

    final item = items[Random().nextInt(items.length)];
    final videoId = item['id']['videoId'];
    final title = item['snippet']['title'];
    final thumbnail = item['snippet']['thumbnails']['default']['url'];

    return {
      'title': title,
      'url': 'https://www.youtube.com/watch?v=$videoId',
      'thumbnail': thumbnail,
    };
  }
}
