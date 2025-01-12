import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'MockPostApi.dart';

class MockPostService {
  static final Random _random = Random();
  static const int postLimit = 30;

  // Categorías de posts
  static final List<Map<String, dynamic>> _postTypes = [
    {
      'type': 'selfie',
      'descriptions': [
        '¡Nuevo look! 💇‍♂️',
        'Sintiéndome genial hoy ✨',
        'Buenos días mundo 🌞',
        'Nueva selfie del día 📱',
      ],
      'hashtags': ['#selfie', '#me', '#goodvibes', '#smile'],
      'imageUrl': 'https://i.pravatar.cc'
    },
    {
      'type': 'friends',
      'descriptions': [
        'Con mis mejores amigos ❤️',
        'Reunión inolvidable 🤗',
        'Momentos que atesoraré siempre 👥',
        'Squad goals 🙌',
      ],
      'hashtags': ['#friends', '#squad', '#friendship', '#moments'],
      'imageUrl': 'https://picsum.photos'
    },
    {
      'type': 'travel',
      'descriptions': [
        'Explorando nuevos lugares 🗺️',
        'Aventuras por el mundo 🌎',
        'Descubriendo paraísos 🏖️',
        'Viajes inolvidables ✈️',
      ],
      'hashtags': ['#travel', '#wanderlust', '#explore', '#adventure'],
      'imageUrl': 'https://picsum.photos'
    },
    {
      'type': 'party',
      'descriptions': [
        '¡Noche increíble! 🎉',
        'Celebrando la vida 🥳',
        'Fiesta con los mejores 🎊',
        'Momentos de diversión 🎸',
      ],
      'hashtags': ['#party', '#nightout', '#fun', '#celebration'],
      'imageUrl': 'https://picsum.photos'
    },
    {
      'type': 'food',
      'descriptions': [
        'Delicioso brunch 🍳',
        'Nueva receta casera 👨‍🍳',
        'Food lover 🍕',
        'Sabores únicos 🍝',
      ],
      'hashtags': ['#foodie', '#instafood', '#yummy', '#foodlover'],
      'imageUrl': 'https://picsum.photos'
    },
    {
      'type': 'nature',
      'descriptions': [
        'Conexión con la naturaleza 🌿',
        'Paz interior 🍃',
        'Momentos de tranquilidad 🌅',
        'Belleza natural 🏞️',
      ],
      'hashtags': ['#nature', '#peace', '#naturelover', '#sunset'],
      'imageUrl': 'https://picsum.photos'
    }
  ];

  static Future<List<MockPostApi>> fetchMockPosts() async {
    try {
      final usersResponse = await http.get(
        Uri.parse(
            'https://jsonplaceholder.typicode.com/users?_limit=$postLimit'),
      );

      if (usersResponse.statusCode != 200) {
        throw Exception(
            'Error al cargar usuarios: ${usersResponse.statusCode}');
      }

      final List<dynamic> users = json.decode(usersResponse.body);
      List<MockPostApi> mockPosts = [];

      await Future.wait(
        users.map((user) async {
          // Generar entre 1 y 3 posts por usuario
          final numberOfPosts = _random.nextInt(3) + 1;

          for (var i = 0; i < numberOfPosts; i++) {
            // Seleccionar tipo de post aleatorio
            final postType = _postTypes[_random.nextInt(_postTypes.length)];

            // Generar fecha aleatoria en los últimos 7 días
            final randomHours = _random.nextInt(168);
            final createdAt =
            DateTime.now().subtract(Duration(hours: randomHours));

            // Generar entre 1 y 4 imágenes por post
            final numberOfImages = _random.nextInt(8) + 1;
            List<String> images = [];

            if (postType['type'] == 'selfie') {
              // Aumentar la resolución de los avatares
              images = List.generate(
                numberOfImages,
                    (index) =>
                '${postType['imageUrl']}/600?u=${user['id']}${_random.nextInt(1000)}', // Cambiado de 150 a 600px
              );
            } else {
              // Usar resolución más alta para otros tipos
              images = List.generate(
                numberOfImages,
                    (index) =>
                '${postType['imageUrl']}/1080/1080?random=${user['id']}${_random.nextInt(1000)}', // Cambiado de 600/600 a 1080/1080px
              );
            }

            // Seleccionar descripción aleatoria y hashtags
            final description =
                '${postType['descriptions'][_random.nextInt(postType['descriptions'].length)]} '
                '${postType['hashtags'].take(_random.nextInt(3) + 1).join(' ')} '
                '#${postType['type']}';

            // Generar likes aleatorios más realistas
            final likeCount = _random.nextInt(500) + 50;

            mockPosts.add(MockPostApi(
              id: int.parse('${user['id']}${i + 1}'),
              userName: user['name'],
              description: description,
              imagePaths: images,
              createdAt: createdAt,
              likeCount: likeCount,
              isLiked: _random.nextBool(),
            ));
          }
        }),
      );

      // Ordenar posts por fecha de creación
      mockPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return mockPosts;
    } catch (e) {
      print('Error al obtener posts simulados: $e');
      return [];
    }
  }

  // Método para refrescar posts
  static Future<void> refreshPosts(
      Function(List<MockPostApi>) onPostsUpdated) async {
    try {
      final posts = await fetchMockPosts();
      onPostsUpdated(posts);
    } catch (e) {
      print('Error al refrescar posts: $e');
    }
  }
}