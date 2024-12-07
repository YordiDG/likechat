import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Clase para pintar el área de dibujo
class DrawingPainter extends CustomPainter {
  final List<List<Offset?>> points;
  final Color color;
  final double strokeWidth;
  final bool isEraser;

  DrawingPainter(this.points, this.color, this.strokeWidth, {this.isEraser = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isEraser ? Colors.transparent : color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    for (var pointList in points) {
      for (int i = 0; i < pointList.length - 1; i++) {
        if (pointList[i] != null && pointList[i + 1] != null) {
          if (isEraser) {
            paint.blendMode = BlendMode.clear;  // Borra la línea
          } else {
            paint.blendMode = BlendMode.srcOver;  // Dibuja normalmente
          }
          canvas.drawLine(pointList[i]!, pointList[i + 1]!, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth || oldDelegate.isEraser != isEraser;
  }
}

class DrawingAreaWithImage extends StatefulWidget {
  final String imagePath; // Ruta de la imagen seleccionada

  DrawingAreaWithImage({required this.imagePath});

  @override
  _DrawingAreaWithImageState createState() => _DrawingAreaWithImageState();
}

class _DrawingAreaWithImageState extends State<DrawingAreaWithImage> {
  List<List<Offset?>> points = [];
  Color selectedColor = Colors.black;
  double strokeWidth = 5.0;
  bool isEraser = false; // Variable para activar o desactivar el borrador
  List<Offset?> currentPoints = [];

  // Tipos de pinceles
  final List<IconData> brushIcons = [
    Icons.create,
    Icons.brush,
    Icons.format_paint,
    FontAwesomeIcons.highlighter,
    Icons.undo,
    Icons.delete,
  ];

  int selectedBrushIndex = 0;

  // Colores disponibles
  final List<Color> colors = [
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.brown,
    Colors.pink,
    Colors.cyan,
    Colors.teal,
    Colors.indigo,
    Colors.amber,
    Colors.lime,
    Colors.deepPurple,
    Colors.deepOrange,
  ];


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Imagen de fondo
        Positioned.fill(
          child: Image.file(
            File(widget.imagePath), // Mostrar la imagen cargada
            fit: BoxFit.cover,
          ),
        ),
        // Área de dibujo
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              RenderBox renderBox = context.findRenderObject() as RenderBox;
              Offset localPosition = renderBox.globalToLocal(details.globalPosition);
              currentPoints.add(localPosition); // Añadir puntos a la lista actual
            });
          },
          onPanEnd: (details) {
            setState(() {
              if (currentPoints.isNotEmpty) {
                points.add(List.from(currentPoints)); // Guardar el trazo en la lista de puntos
                currentPoints.clear();
              }
            });
          },
          child: CustomPaint(
            size: Size.infinite,
            painter: DrawingPainter(points..add(currentPoints), selectedColor, strokeWidth, isEraser: isEraser),
          ),
        ),
        // Selector de color (Carrusel en la parte inferior)
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Opciones de pincel (Diagonal superior izquierda)
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            children: [
              for (int i = 0; i < brushIcons.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedBrushIndex = i;
                      switch (selectedBrushIndex) {
                        case 0: // Lápiz
                          strokeWidth = 2.0;
                          isEraser = false;
                          selectedColor = Colors.black; // Poner el color negro al elegir lápiz
                          break;
                        case 1: // Pincel
                          strokeWidth = 5.0;
                          isEraser = false;
                          selectedColor = Colors.blue; // Poner un color azul al elegir pincel
                          break;
                        case 2: // Borrador
                          isEraser = true;
                          strokeWidth = 20.0; // Ancho más grande para el borrador
                          break;
                      }
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: selectedBrushIndex == i ? Colors.black.withOpacity(0.7) : Colors.black.withOpacity(0.5), // Diferenciar el color de fondo
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      brushIcons[i],
                      color: selectedBrushIndex == i ? Colors.white : Colors.grey,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Botón "Deshacer" en la parte superior izquierda
        Positioned(
          top: 80,
          left: 20,
          child: IconButton(
            onPressed: () {
              setState(() {
                if (points.isNotEmpty) {
                  points.removeLast(); // Eliminar el último trazo
                }
              });
            },
            icon: Icon(
              Icons.undo,
              color: Colors.white,
            ),
          ),
        ),
        // Botón "Aplicar cambios" en la parte superior derecha
        Positioned(
          top: 20,
          right: 20,
          child: ElevatedButton(
            onPressed: () {
              // Aplicar cambios (puedes agregar funcionalidad aquí)
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, // Color de fondo del botón
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Bordes redondeados
              ),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(
              'Aplicar cambios',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void clearDrawing() {
    setState(() {
      points.clear(); // Limpia el área de dibujo
    });
  }
}

class DrawingPage extends StatelessWidget {
  final String imagePath;

  DrawingPage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dibujo'),
      ),
      body: DrawingAreaWithImage(imagePath: imagePath), // Aquí colocamos el área de dibujo con la imagen
    );
  }
}
