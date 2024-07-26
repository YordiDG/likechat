import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../../ShortVideosScreen.dart';
import 'MasOpciones/MasOpcionesModal.dart';

// Modelo para opciones de publicación
class PublishOptions {
  String description = ''; // Descripción del video
  List<String> hashtags = []; // Lista de hashtags
  List<String> mentions = []; // Lista de menciones
  String privacyOption = 'publico'; // Opción de privacidad: publico o privado
  bool allowSave = true; // Permitir descargas
  bool allowComments = true; // Permitir comentarios
  bool allowPromote = false; // Permitir promoción
  bool allowDownloads = true; // Permitir descargas
  bool allowLocationTagging = true; // Permitir etiquetado de ubicación

  PublishOptions({
    this.description = '',
    this.hashtags = const [],
    this.mentions = const [],
    this.privacyOption = 'publico',
    this.allowSave = true,
    this.allowComments = true,
    this.allowPromote = false,
    this.allowDownloads = true,
    this.allowLocationTagging = true,
  });
}

class VideoPublishScreen extends StatefulWidget {
  final String videoPath;
  final PublishOptions publishOptions; // Modelo de opciones de publicación

  VideoPublishScreen({
    required this.videoPath,
    required this.publishOptions,
  });

  @override
  _VideoPublishScreenState createState() => _VideoPublishScreenState();
}

class _VideoPublishScreenState extends State<VideoPublishScreen> {
  late VideoPlayerController _controller;
  bool allowSave = true; // Permitir descargas (se movió aquí)

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void handlePrivacyOption(String newOption) {
    setState(() {
      widget.publishOptions.privacyOption = newOption;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Publicar',
          style: TextStyle(fontSize: 21,color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Video Display and Description Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sección de visualización del video
                  Container(
                    width: 110,
                    height: 150,
                    color: Colors.black,
                    child: _controller.value.isInitialized
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          )
                        : Center(
                            child: CircularProgressIndicator(),
                          ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        height: 150,
                        padding: EdgeInsets.symmetric(horizontal: 2.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              widget.publishOptions.description = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Añade una breve descripción para alcanzar mas visitas',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.0),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white, width: 1.0),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            counterStyle: TextStyle(color: Colors.black),
                            counterText: '',
                            hintMaxLines: 2, // Añadir esta línea para establecer un máximo de líneas
                          ),
                          maxLength: 130,
                          maxLines: null,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          style: TextStyle(
                            fontSize: 16.0, color: Colors.black, height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              // Hashtags and Mentions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 18.0),
                    child: TextButton(
                      onPressed: () {
                        // Lógica para gestionar hashtags
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 12.0),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                        ),
                      ),
                      child: Text(
                        '# Hashtag',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 1.0),
                  Container(
                    margin: EdgeInsets.only(right: 25.0),
                    child: TextButton(
                      onPressed: () {
                        // Lógica para gestionar menciones
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 2.0, horizontal: 12.0),
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.5), width: 1),
                        ),
                      ),
                      child: Text(
                        '@ Amigos',
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.0),
              // Privacy Options Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(
                              color: Colors.grey.withOpacity(0.4), width: 0.7)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Quién puede ver tus vídeos',
                                  style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: Row(
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  handlePrivacyOption('publico');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 16.0),
                                  backgroundColor:
                                      widget.publishOptions.privacyOption ==
                                              'publico'
                                          ? Colors.lightBlueAccent
                                          : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.public,
                                  color: widget.publishOptions.privacyOption ==
                                          'publico'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                label: Text(
                                  'Público',
                                  style: TextStyle(
                                    color:
                                        widget.publishOptions.privacyOption ==
                                                'publico'
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.0),
                              TextButton.icon(
                                onPressed: () {
                                  handlePrivacyOption('privado');
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 4.0, horizontal: 16.0),
                                  backgroundColor:
                                      widget.publishOptions.privacyOption ==
                                              'privado'
                                          ? Colors.lightBlueAccent
                                          : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20.0),
                                    side: BorderSide(
                                        color: Colors.grey.withOpacity(0.3),
                                        width: 1),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.lock,
                                  color: widget.publishOptions.privacyOption ==
                                          'privado'
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                label: Text(
                                  'Privado',
                                  style: TextStyle(
                                    color:
                                        widget.publishOptions.privacyOption ==
                                                'privado'
                                            ? Colors.white
                                            : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.0),

              GestureDetector(
                onTap: () {
                  setState(() {
                    allowSave = !allowSave;
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Permisos',
                          style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          allowSave
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    if (allowSave)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                widget.publishOptions.allowDownloads =
                                    !widget.publishOptions.allowDownloads;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.save,
                                  color: widget.publishOptions.allowDownloads
                                      ? Colors.lightBlueAccent
                                      : Colors.grey,
                                  size: 29,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Permitir descargas',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13),
                                ),
                                Spacer(),
                                Transform.scale(
                                  scale: 0.9,
                                  child: Switch(
                                    value: widget.publishOptions.allowDownloads,
                                    onChanged: (value) {
                                      setState(() {
                                        widget.publishOptions.allowDownloads =
                                            value;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: Colors.lightBlueAccent,
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor:
                                        Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                widget.publishOptions.allowLocationTagging =
                                    !widget.publishOptions.allowLocationTagging;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color:
                                      widget.publishOptions.allowLocationTagging
                                          ? Colors.lightBlueAccent
                                          : Colors.grey,
                                  size: 29,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Permitir Ubicación',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                Transform.scale(
                                  scale: 0.9,
                                  child: Switch(
                                    value: widget
                                        .publishOptions.allowLocationTagging,
                                    onChanged: (value) {
                                      setState(() {
                                        widget.publishOptions
                                            .allowLocationTagging = value;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: Colors.lightBlueAccent,
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor:
                                        Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                widget.publishOptions.allowComments =
                                    !widget.publishOptions.allowComments;
                              });
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  color: widget.publishOptions.allowComments
                                      ? Colors.lightBlueAccent
                                      : Colors.grey,
                                  size: 29,
                                ),
                                SizedBox(width: 8),
                                Text('Permitir Comentarios',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Spacer(),
                                Transform.scale(
                                  scale: 0.9,
                                  child: Switch(
                                    value: widget.publishOptions.allowComments,
                                    onChanged: (value) {
                                      setState(() {
                                        widget.publishOptions.allowComments =
                                            value;
                                      });
                                    },
                                    activeColor: Colors.white,
                                    activeTrackColor: Colors.lightBlueAccent,
                                    inactiveThumbColor: Colors.grey,
                                    inactiveTrackColor:
                                        Colors.grey.withOpacity(0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Opciones Avanzadas',
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.more_horiz),
                        onPressed: () {
                          // Mostrar el modal de más opciones
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return MasOpcionesModal();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 16.0),

              // Post Button
              ElevatedButton(
                onPressed: () {

                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding:
                      EdgeInsets.symmetric(vertical: 11.0, horizontal: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 3,
                  // Elevación del botón
                  shadowColor: Colors.grey, // Color de la sombra del botón
                ),
                child: Text(
                  'Postear',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDownloadOption(bool isEnabled) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.publishOptions.allowDownloads = !isEnabled;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isEnabled ? Colors.blue : Colors.white,
          border: Border.all(color: Colors.blue, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.save,
              color: isEnabled ? Colors.white : Colors.blue,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Permitir descargas',
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
