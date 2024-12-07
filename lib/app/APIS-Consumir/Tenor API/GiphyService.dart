import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dao/Sticker.dart';

class GiphyService {
  final String _apiKey = 'p6rPANn02pXfWSgluEILhSNw1DDGAm0r';
  final String _baseUrl = 'https://api.giphy.com/v1/gifs';

  Future<List<Sticker>> fetchStickers(String query) async {
    // Si la consulta está vacía, devuelvo stickers predeterminados
    String searchQuery = query.isEmpty ? 'sticker' : query; // Puedes elegir otro término predeterminado
    final response = await http.get(
      Uri.parse('$_baseUrl/search?api_key=$_apiKey&q=$searchQuery&limit=80'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> results = data['data'];

      return results.map((item) {
        return Sticker(
          id: item['id'],
          url: item['images']['original']['url'], // URL del sticker
        );
      }).toList();
    } else {
      throw Exception('Error al cargar stickers: ${response.statusCode}');
    }
  }
}
