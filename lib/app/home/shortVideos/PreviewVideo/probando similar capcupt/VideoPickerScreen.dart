import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'CapCutEditorScreen.dart';

class VideoPickerScreen extends StatefulWidget {
  @override
  _VideoPickerScreenState createState() => _VideoPickerScreenState();
}

class _VideoPickerScreenState extends State<VideoPickerScreen> {
  XFile? _video;

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    setState(() {
      _video = pickedFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Carga de Video")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _video != null
                ? Text("Video seleccionado: ${_video!.name}")
                : Text("Seleccione un video"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text("Cargar Video"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_video != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CapCutEditorScreen(videoPath: _video!.path),
                    ),
                  );
                }
              },
              child: Text("Ir a Edición"),
            ),
          ],
        ),
      ),
    );
  }
}
