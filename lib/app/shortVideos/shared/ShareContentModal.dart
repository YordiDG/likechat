import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ShareContentModal {
  final TextEditingController textController = TextEditingController();

  void showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Share Text'),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter Message',
                  ),
                ),
              ),
              ElevatedButton(
                child: const Text('Share Text'),
                onPressed: () async {
                  if (textController.text.isNotEmpty) {
                    await Share.share(textController.text);
                  }
                },
              ),
              const SizedBox(height: 25),
              const Text('Share Image from Internet'),
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text('Share Image from URL'),
                onPressed: () async {
                  final url = 'lib/assets/logo.png';
                  final uri = Uri.parse(url);
                  final response = await http.get(uri);
                  final bytes = response.bodyBytes;

                  final temp = await getTemporaryDirectory();
                  final path = '${temp.path}/image.jpg';

                  File(path).writeAsBytesSync(bytes);

                  await Share.shareXFiles([XFile(path)], text: 'Check out this image!');
                },
              ),
              const SizedBox(height: 15),
              const Text('Share Image from Gallery'),
              const SizedBox(height: 15),
              ElevatedButton(
                child: const Text('Share From Gallery'),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles();
                  if (result != null && result.files.isNotEmpty) {
                    final files = result.files.map((file) => XFile(file.path!)).toList();
                    await Share.shareXFiles(files);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
