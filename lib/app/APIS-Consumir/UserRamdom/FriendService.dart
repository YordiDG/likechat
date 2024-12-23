import 'dart:convert';
import 'package:http/http.dart' as http;

class FriendService {
  // Método para obtener los amigos desde la API
  Future<List<Map<String, dynamic>>> fetchFriends() async {
    try {
      // Hacemos la solicitud HTTP
      final response = await http.get(Uri.parse('https://randomuser.me/api/?results=50'));

      // Verificamos que la respuesta sea correcta (código 200)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Mapear los datos a un formato específico para la UI
        List<Map<String, dynamic>> friends = (data['results'] as List)
            .map<Map<String, dynamic>>((dynamic user) {
          return {
            "name": "${user['name']['first']} ${user['name']['last']}",
            "username": user['login']['username'],
            "photoUrl": user['picture']['medium'],
            "id": user['login']['uuid'],
            "followers": (user['dob']['age'] * 10).toString(),
            // Mock followers count
            "isFollowing": false, // Estado inicial de seguir
          };
        }).toList();

        return friends;
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (error) {
      print('Error: $error');
      throw Exception('Error al cargar los amigos');
    }
  }
}
