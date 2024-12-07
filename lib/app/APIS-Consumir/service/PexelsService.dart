import 'dart:convert';
import 'package:http/http.dart' as http;

class PexelsService {
  final String apiKey = 'jUOv1hg2RxnB7vQcFZzbYdQB9bhYCAyS7wjvZVVpFoDQTqtj2QzoStbB';

  Future<List<dynamic>> fetchVideos() async {
    final url = Uri.parse('https://api.pexels.com/videos/search?query=nature&per_page=10&duration=short');

    final response = await http.get(url, headers: {
      'Authorization': apiKey,
    });

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data['videos']); // Verifica que estás recibiendo datos
      return data['videos'];
    } else {
      throw Exception('Error al cargar videos');
    }
  }

}
