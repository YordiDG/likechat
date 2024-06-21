import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String description;

  EditProfileScreen({
    required this.username,
    required this.description,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  String _username = 'Yordi Gonzales';
  String _description = 'Añade una descripcion breve';
  String _facebookLink = '';
  String _instagramLink = '';
  String _tiktokLink = '';
  bool _showSocialLinks = false;


  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _tiktokController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _usernameController.text = widget.username;
    _descriptionController.text = widget.description;
  _facebookController.text = _facebookLink;
    _instagramController.text = _instagramLink;
    _tiktokController.text = _tiktokLink;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    super.dispose();
  }

  Future<void> openCameraOrGallery(BuildContext context) async {
    final XFile? pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecciona una opción'),
        content: Text('Elige la fuente para la imagen:',
            style: TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context)
                  .pop(await _picker.pickImage(source: ImageSource.camera));
            },
            child: Text('Cámara'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context)
                  .pop(await _picker.pickImage(source: ImageSource.gallery));
            },
            child: Text('Galería'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _updateProfileImage(pickedFile);
      });
    }
  }

  void _updateProfileImage(XFile pickedFile) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        backgroundColor: Colors.white,
        // Color de fondo de la AppBar
        iconTheme: IconThemeData(color: Colors.black),
        // Color del ícono de retroceso
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.black),
            // Icono de check en negro
            onPressed: () {
              // Acción para guardar cambios
              _saveChanges();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('lib/assets/placeholder_user.jpg'),
                          // Imagen de perfil actual
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              openCameraOrGallery(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                                border:
                                    Border.all(color: Colors.white, width: 3),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Acción para cambiar foto de perfil
                      },
                      child: Text(
                        'Cambiar Foto de Perfil',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Divider(
                color: Colors.grey[300],
                height: 1,
                thickness: 1,
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        maxLength: 35,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Nombre de Usuario',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _username = value;
                          });
                          if (value.length > 35) {
                            _usernameController.text = value.substring(0, 35);
                            _usernameController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: _usernameController.text.length));
                          }
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Visibility(
                          visible: _usernameController.text.length == 35,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Se alcanzó el límite de 35 caracteres',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        maxLength: 60,
                        minLines: 3,
                        maxLines: 5,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(60),
                        ],
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() {
                            if (value.length <= 60) {
                              _description = value;
                            }
                          });
                        },
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Visibility(
                          visible: _descriptionController.text.length == 60,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Se alcanzó el límite de 60 caracteres',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  setState(() {
                    _showSocialLinks = !_showSocialLinks;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        _showSocialLinks
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.black,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Añadir Redes Sociales',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _showSocialLinks ? 220 : 0,
                constraints: BoxConstraints(maxHeight: 220),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      _buildSocialLinkField(
                        controller: _facebookController,
                        platform: 'Facebook',
                        icon: Icons.facebook,
                      ),
                      SizedBox(height: 10),
                      _buildSocialLinkField(
                        controller: _instagramController,
                        platform: 'Instagram',
                        icon: Icons.photo_camera_outlined,
                      ),
                      SizedBox(height: 10),
                      _buildSocialLinkField(
                        controller: _tiktokController,
                        platform: 'TikTok',
                        icon: Icons.play_circle_fill,
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _saveChanges();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD9F103),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                ),
                child: Text(
                  'Guardar Cambios',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF0D0D55),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinkField({
    required TextEditingController controller,
    required String platform,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: 'Enlace de $platform',
        labelStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          if (platform == 'Facebook') {
            _facebookLink = value;
          } else if (platform == 'Instagram') {
            _instagramLink = value;
          } else if (platform == 'TikTok') {
            _tiktokLink = value;
          }
        });
      },
      validator: (value) {
        if (value!.isEmpty) {
          return null; // Permitir campo vacío, ya que es opcional
        }
        // Expresión regular para verificar enlaces de Facebook, Instagram o TikTok
        RegExp regExp = RegExp(
          r'^(https?:\/\/)?(www\.)?(facebook|fb|instagram|tiktok)\.com\/',
          caseSensitive: false,
        );
        if (!regExp.hasMatch(value)) {
          return 'Por favor, ingresa un enlace válido de $platform.';
        }
        return null; // Retornar null si la validación es exitosa
      },
    );
  }

  void _saveChanges() {

    if (_usernameController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error', style: TextStyle(color: Colors.red)),
          content: Text('Por favor, ingresa un nombre de usuario.',
              style: TextStyle(color: Colors.black)),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Error',
            style: TextStyle(color: Colors.red),
          ),
          content: Text(
            'Por favor, ingresa una descripción.',
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
      return;
    }

    _username = _usernameController.text;
    _description = _descriptionController.text;
    _facebookLink = _facebookController.text;
    _instagramLink = _instagramController.text;
    _tiktokLink = _tiktokController.text;

    Navigator.pop(context);
  }
}
