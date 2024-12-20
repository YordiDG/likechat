import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';

import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'detalle imagen y Video/ImageDetailGaleria.dart';
import 'detalle imagen y Video/VideoDetailScreen.dart';


class GalleryPage extends StatefulWidget {
  @override
  _GalleryPageState createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ImagePicker _picker = ImagePicker();
  int _selectedPage = 0;

  List<AssetEntity> _videos = [];
  List<AssetEntity> _imagenes = [];
  List<AssetEntity> _selectedAssets = [];

  bool _isSelectionBlocked = false; // Estado global para bloquear la selección

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Diferencia entre plataformas
    final permission = Platform.isIOS
        ? Permission.photos
        : Permission.storage;

    var status = await permission.status;

    if (status.isGranted) {
      _loadAssets();
    } else {
      status = await permission.request();

      if (status.isGranted) {
        _loadAssets();
      } else if (status.isDenied) {
        // Mostrar diálogo explicando por qué necesitas permisos
        _showPermissionDialog();
      } else if (status.isPermanentlyDenied) {
        // Guiar al usuario a configuraciones de la app
        await openAppSettings();
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permiso Requerido'),
        content: Text('Necesitamos acceso a tus fotos y videos para esta función.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Abrir Configuraciones'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAssets() async {
    try {
      final List<AssetPathEntity> assetPaths = await PhotoManager.getAssetPathList(onlyAll: true);

      if (assetPaths.isEmpty) {
        // Manejar caso donde no hay rutas de assets
        print('No se encontraron rutas de assets');
        return;
      }

      _imagenes.clear();
      _videos.clear();

      for (var path in assetPaths) {
        final int assetCount = await path.assetCountAsync;

        if (assetCount == 0) continue; // Saltar rutas vacías

        final List<AssetEntity> assets = await path.getAssetListPaged(
            page: 0,
            size: assetCount
        );

        for (var asset in assets) {
          switch (asset.type) {
            case AssetType.video:
              _videos.add(asset);
              break;
            case AssetType.image:
              _imagenes.add(asset);
              break;
            default:
              break;
          }
        }
      }

      setState(() {
        // Verifica si hay assets
        if (_imagenes.isEmpty && _videos.isEmpty) {
          // Mostrar mensaje de que no hay contenido
          print('No se encontraron imágenes ni videos');
        }
      });
    } catch (e) {
      print('Error al cargar assets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final isDarkMode = darkModeProvider.isDarkMode;
    final iconColor = darkModeProvider.iconColor;
    final textColor = darkModeProvider.textColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Álbum',
              style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: iconColor,
              size: 22,
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade800.withOpacity(0.8) : Colors.grey.shade400.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(5),
            child: Icon(
              Icons.close,
              color: iconColor,
              size: 20,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.white.withOpacity(0.2),
                border: Border.all(
                  color: isDarkMode ? Colors.grey.shade700 :  Colors.grey.shade400,
                  width: 0.8,
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              child: Text(
                'Cancelar',
                style: TextStyle(color: textColor, fontSize: 11),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Categorías
          _buildNavigationBar(),
          // Galería
          Expanded(
            child: _buildContent(),
          ),
          _buildSelectedAssets(),
          // Botones en la parte inferior
          buildBottomBar(context),
        ],
      ),
    );
  }

  //botone de arriba buton bar
  Widget _buildNavigationBar() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final isDarkMode = darkModeProvider.isDarkMode;
    final iconColor = darkModeProvider.iconColor;
    final textColor = darkModeProvider.textColor;

    return Container(
      color: backgroundColor,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: ['Todo', 'Videos', 'Fotos'].map((category) {
          int index = ['Todo', 'Videos', 'Fotos'].indexOf(category);
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPage = index;
              });
            },
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                children: [
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: _selectedPage == index
                          ? FontWeight.bold
                          : FontWeight.w600,
                      color: _selectedPage == index
                          ? textColor
                          : Colors.grey,
                    ),
                  ),
                  if (_selectedPage == index)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 2,
                      width: double.infinity,
                      color: iconColor,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  //contenido
  Widget _buildContent() {
    if (_selectedPage == 0) {
      return _imagenes.isEmpty && _videos.isEmpty
          ? Center(
        child: Lottie.asset(
          'lib/assets/loading/infinity_cyan.json',
          width: 50,
          height: 50,
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(1),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.2,
          crossAxisSpacing: 1.2,
          childAspectRatio: 1.0, // Puedes modificar esto si las imágenes no se ven bien
        ),
        itemCount: _imagenes.length + _videos.length,
        itemBuilder: (context, index) {
          if (index < _imagenes.length) {
            return _buildImageThumbnail(_imagenes[index]);
          } else {
            return _buildVideoThumbnail(_videos[index - _imagenes.length]);
          }
        },
      );
    } else if (_selectedPage == 1) {
      return _videos.isEmpty
          ? Center(
        child: Lottie.asset(
          'lib/assets/loading/infinity_cyan.json',
          width: 50,
          height: 50,
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(1),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.2,
          crossAxisSpacing: 1.2,
          childAspectRatio: 1.0, // Puedes modificar esto si las imágenes no se ven bien
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return _buildVideoThumbnail(_videos[index]);
        },
      );
    } else if (_selectedPage == 2) {
      return _imagenes.isEmpty
          ? Center(
        child: Lottie.asset(
          'lib/assets/loading/infinity_cyan.json',
          width: 50,
          height: 50,
        ),
      )
          : GridView.builder(
        padding: EdgeInsets.all(1),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 1.2,
          crossAxisSpacing: 1.2,
          childAspectRatio: 1.0, // Puedes modificar esto si las imágenes no se ven bien
        ),
        itemCount: _imagenes.length,
        itemBuilder: (context, index) {
          return _buildImageThumbnail(_imagenes[index]);
        },
      );
    } else {
      return Center(
        child: Text(
          'Selecciona una categoría para ver contenido.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }
  }

//seleccion de imagenes
  Widget _buildImageThumbnail(AssetEntity asset) {
    final isSelected = _selectedAssets.contains(asset);
    final index = isSelected ? _selectedAssets.indexOf(asset) + 1 : null;
    final isMaxSelected = _selectedAssets.length >= 20; // Límite máximo de selección

    return GestureDetector(
      onTap: () {
        if (!isMaxSelected || isSelected) {
          HapticFeedback.selectionClick(); // Vibración al seleccionar
          setState(() {
            _toggleSelection(asset); // Cambiar estado de selección
          });
        } else {
          // Mostrar mensaje si se intenta seleccionar más de lo permitido
          Fluttertoast.showToast(
            msg: "Selecciona hasta 20 imágenes",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black.withOpacity(0.7),
            textColor: Colors.white,
            fontSize: 15.0,
          );
        }
      },
      onLongPress: () {
        // Mostrar detalle de la imagen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImageDetailGaleria(
              asset: asset,
              onClose: () => Navigator.pop(context),
              onSelect: () {
                _toggleSelection(asset);
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
      child: FutureBuilder<Uint8List?>(
        future: asset.thumbnailData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Stack(
                children: [
                  // Miniatura de la imagen
                  Opacity(
                    opacity: isMaxSelected && !isSelected ? 0.5 : 1.0,
                    child: Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  // Indicador de selección
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 23,
                      height: 23,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.cyan : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.white,
                          width: 1.3,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isSelected
                          ? Center(
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      )
                          : null,
                    ),
                  ),
                ],
              );
            } else {
              return Container(color: Colors.grey); // Placeholder si no hay datos
            }
          }
          return Center(
            child: Lottie.asset(
              'lib/assets/loading/infinity_cyan.json',
              width: 50,
              height: 50,
            ), // Indicador de carga mientras se obtiene la imagen
          );
        },
      ),
    );
  }

  //detallede video
  Widget _buildVideoThumbnail(AssetEntity asset) {
    final isSelected = _selectedAssets.contains(asset);
    final index = isSelected ? _selectedAssets.indexOf(asset) + 1 : null;

    // Verificar si ya se ha alcanzado el máximo de selección
    final isMaxSelected = _selectedAssets.length >= 20;
    _isSelectionBlocked = isMaxSelected; // Actualizar el estado global

    return FutureBuilder<Uint8List?>(
      future: asset.thumbnailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
          return GestureDetector(
            onTap: () {
              if (!isMaxSelected || isSelected) {
                HapticFeedback.selectionClick();
                setState(() {
                  _toggleSelection(asset); // Actualiza solo el estado de selección
                });
              } else {
                // Mostrar mensaje si se excede el límite
                Fluttertoast.showToast(
                  msg: "Selecciona hasta 20 videos",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.black.withOpacity(0.7),
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              }
            },
            onLongPress: () async {
              // Mostrar detalle del video
              if (asset.type == AssetType.video) {
                final file = await asset.file;
                if (file != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return VideoDetailGaleria(
                          videoFile: file,
                          onClose: () => Navigator.pop(context),
                          onSelect: () {
                            _toggleSelection(asset);
                            Navigator.pop(context);
                          },
                          isSelected: isSelected,
                        );
                      },
                    ),
                  );
                }
              }
            },
            child: Stack(
              children: [
                // Miniatura del video
                Image.memory(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                if (asset.type == AssetType.video)
                  Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white.withOpacity(0.2),
                      size: 30,
                    ),
                  ),
                if (asset.type == AssetType.video)
                  Positioned(
                    bottom: 5,
                    left: 5,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        _formatDuration(asset.videoDuration),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                // Indicador de selección
                Positioned(
                  top: 5,
                  right: 5,
                  child: isSelected
                      ? Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '$index',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                      : Container(
                    width: 23,
                    height: 23,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Container(color: Colors.grey); // Placeholder si no hay datos
        }
        return Center(
          child: Lottie.asset(
            'lib/assets/loading/infinity_cyan.json',
            width: 50,
            height: 50,
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  //logica de seleccion
  Widget _buildSelectedAssets() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;

    if (_selectedAssets.isNotEmpty) {
      return Container(
        height: 80,
        color: backgroundColor,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _selectedAssets.length,
          itemBuilder: (context, index) {
            final asset = _selectedAssets[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  FutureBuilder<Uint8List?>(  // Carga la miniatura del asset
                    future: asset.thumbnailData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 0.5, // Borde gris delgado
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Image.memory(
                              snapshot.data!,
                              width: 65,
                              height: 65,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                      return Container(
                        color: Colors.grey,
                        width: 60,
                        height: 60,
                      );
                    },
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAssets.removeAt(index);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5), // Borde gris claro
                            width: 0.5,
                          ),
                        ),
                        padding: EdgeInsets.all(3),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            size: 13,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }
    return SizedBox.shrink(); // Devuelve un widget vacío si no hay elementos seleccionados
  }

  //botones de inferior
  int get selectedCount {
    return _selectedAssets.length;
  }

  Widget buildBottomBar(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final isDarkMode = darkModeProvider.isDarkMode;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  /*Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PostClass()));*/
                },
                style: buttonStyle(isDarkMode ? Colors.white : Colors.grey.shade300, Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cut, color: Colors.black),
                    SizedBox(width: 5),
                    Text(
                      "Edición",
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: buttonStyle(Colors.cyan, Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Ok",
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),

                    SizedBox(width: 3),
                    // Mostrar contador de elementos seleccionados
                    if (selectedCount > 0)
                      Text(
                        '($selectedCount)',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                  ],
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  //disñeo de botones de publicar y siguiente
  ButtonStyle buttonStyle(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selectedAssets.contains(asset)) {
        _selectedAssets.remove(asset);
      } else {
        _selectedAssets.add(asset);
      }
    });
  }

}


