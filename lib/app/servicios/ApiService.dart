import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl = 'http://192.168.0.10:8088/api/v1';

  Future<void> uploadVideo(
      int userId,
      String title,
      String description,
      File videoContent, {
        File? thumbnailImage,
        List<File>? images,
        required String authToken,
      }) async {
    String url = '$baseUrl/snippets/$userId';

    Dio dio = Dio();
    FormData formData = FormData.fromMap({
      'title': title,
      'description': description,
      'videoContent': await MultipartFile.fromFile(videoContent.path, filename: 'video.mp4'),
      if (thumbnailImage != null)
        'thumbnailImage': await MultipartFile.fromFile(thumbnailImage.path, filename: 'thumbnail.jpg'),
      if (images != null)
        'images': images.map((image) => MultipartFile.fromFile(image.path, filename: 'image.jpg')).toList(),
    });

    try {
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      // Handle server response here
    } catch (e) {
      print('Error uploading video: $e');
      // Handle errors
    }
  }
}
