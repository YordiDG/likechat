import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
//import 'package:gallery_saver/gallery_saver.dart';

class ProfileDetailScreen extends StatelessWidget {
  final String imagePath;

  const ProfileDetailScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'Foto de Perfil',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white), // Text color
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              _showDeleteDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareImage(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.save, color: Colors.white),
            onPressed: () {
              _saveImage(context);
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: imagePath.contains('lib/assets/')
              ? Image.asset(
            imagePath,
            fit: BoxFit.contain,
          )
              : Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Image", style: TextStyle(color: Colors.black)), // Text color
          content: Text("Are you sure you want to delete this image?", style: TextStyle(color: Colors.black)), // Text color
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteImage(context); // Call method to delete image
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteImage(BuildContext context) {
    // Implement delete functionality here
    // For example, you can delete the image file
    try {
      File imageFile = File(imagePath);
      if (imageFile.existsSync()) {
        imageFile.deleteSync();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image deleted successfully')),
        );
        Navigator.pop(context); // Optionally close the screen after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image file not found')),
        );
      }
    } catch (e) {
      print('Error deleting image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete image')),
      );
    }
  }


  void _shareImage(BuildContext context) async {
    /*try {
      final imageFile = File(imagePath);
      await Share.shareFiles([imageFile.path], text: 'Check out my profile picture');
    } catch (e) {
      print('Error sharing image: $e');
    }*/
  }

  void _saveImage(BuildContext context) async {
    /** try {
        final imageFile = File(imagePath);
        final result = await GallerySaver.saveImage(imageFile.path);
        if (result['isSuccess']) {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved successfully')),
        );
        } else {
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image')),
        );
        }
        } catch (e) {
        print('Error saving image: $e');
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image')),
        );
        }*/
  }
}
