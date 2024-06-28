
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiServicePhoto {
  static const String baseUrl = 'http://your-backend-url.com/api/users';

  static Future<http.Response> uploadProfilePhoto(int userId, File image) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/$userId/photo'))
      ..files.add(await http.MultipartFile.fromPath('photo', image.path));
    return await http.Response.fromStream(await request.send());
  }

// Other methods (getPhoto, deletePhoto, etc.)
}
