import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';


class EmpresaAccountSettings extends StatefulWidget {
  @override
  _EmpresaAccountSettingsState createState() => _EmpresaAccountSettingsState();
}

class _EmpresaAccountSettingsState extends State<EmpresaAccountSettings> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Variables de estado para los switches
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _adsInPosts = false;
  bool _collaborationWithInfluencers = true;
  bool _useAIGeneratedContent = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _password;
  String? _confirmPassword;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;
    final switchColor = Colors.cyan;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: iconColor,
            size: 25,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: backgroundColor,
        title: Text('Configuración de la Cuenta', style: TextStyle(color: textColor)),
      ),
      body: Form(
        key: _formKey,
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.cyan,
            hintColor: Colors.cyan,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: textColor),
            ),
            colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.cyan),
          ),
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (_currentStep < 4) {
                setState(() {
                  _currentStep += 1;
                });
              } else {
                if (_formKey.currentState!.validate()) {
                  // Aquí se puede guardar la información en un backend o base de datos
                  // y luego mostrar un mensaje de éxito
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Datos guardados exitosamente')),
                  );
                  // Después de mostrar el mensaje de éxito, cerrar la pantalla
                  Future.delayed(Duration(seconds: 1), () {
                    Navigator.of(context).pop();
                  });
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }
            },
            type: StepperType.vertical,
            steps: [
              Step(
                title: Text('Información Personal',  style: TextStyle(color: textColor)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nombre de la Empresa',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        labelStyle: TextStyle(color: textColor), // Cambia el color de la etiqueta
                      ),
                      style: TextStyle(color: textColor), // Cambia el color del texto ingresado
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, ingrese el nombre de la empresa';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        labelStyle: TextStyle(color: textColor)
                      ),
                      style: TextStyle(color: textColor),
                      validator: (value) {
                        if (value!.isEmpty || !value.contains('@')) {
                          return 'Por favor, ingrese un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 0,
                state: _currentStep >= 0 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: Text('Detalles de la Empresa', style: TextStyle(color: textColor)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Dirección',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                          labelStyle: TextStyle(color: textColor)
                      ),
                      style: TextStyle(color: textColor),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, ingrese la dirección de la empresa';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                          labelStyle: TextStyle(color: textColor)
                      ),
                      style: TextStyle(color: textColor),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Por favor, ingrese el teléfono de la empresa';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 1,
                state: _currentStep >= 1 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: Text('Configuración de Seguridad'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        labelStyle: TextStyle(color: textColor), // Cambia el color del texto de la etiqueta a blanco
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.cyan,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: textColor), // Cambia el color del texto ingresado a blanco
                      obscureText: _obscurePassword,
                      onChanged: (value) {
                        _password = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Por favor, ingrese una contraseña de al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        labelStyle: TextStyle(color: textColor), // Cambia el color del texto de la etiqueta a blanco
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.cyan),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.cyan,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: textColor), // Cambia el color del texto ingresado a blanco
                      obscureText: _obscureConfirmPassword,
                      onChanged: (value) {
                        _confirmPassword = value;
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 6) {
                          return 'Por favor, confirme su contraseña';
                        } else if (value != _password) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                isActive: _currentStep >= 2,
                state: _currentStep >= 2 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: Text('Notificaciones',  style: TextStyle(color: textColor)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text('Recibir notificaciones por correo electrónico', style: TextStyle(color: textColor)),
                      value: _emailNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _emailNotifications = value;
                        });
                      },
                      activeColor: switchColor,
                      inactiveTrackColor: Colors.grey,
                    ),
                    SwitchListTile(
                      title: Text('Recibir notificaciones por SMS',  style: TextStyle(color: textColor)),
                      value: _smsNotifications,
                      onChanged: (bool value) {
                        setState(() {
                          _smsNotifications = value;
                        });
                      },
                      activeColor: switchColor,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ],
                ),
                isActive: _currentStep >= 3,
                state: _currentStep >= 3 ? StepState.complete : StepState.indexed,
              ),
              Step(
                title: Text('Opciones de Publicidad y Negocio', style: TextStyle(color: textColor)),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text('Habilitar publicidad en publicaciones',  style: TextStyle(color: textColor)),
                      value: _adsInPosts,
                      onChanged: (bool value) {
                        setState(() {
                          _adsInPosts = value;
                        });
                      },
                      activeColor: switchColor,
                      inactiveTrackColor: Colors.grey,
                    ),
                    SwitchListTile(
                      title: Text('Permitir colaboración con influencers',  style: TextStyle(color: textColor)),
                      value: _collaborationWithInfluencers,
                      onChanged: (bool value) {
                        setState(() {
                          _collaborationWithInfluencers = value;
                        });
                      },
                      activeColor: switchColor,
                      inactiveTrackColor: Colors.grey,
                    ),
                    SwitchListTile(
                      title: Text('Utilizar contenido generado por IA', style: TextStyle(color: textColor),),
                      value: _useAIGeneratedContent,
                      onChanged: (bool value) {
                        setState(() {
                          _useAIGeneratedContent = value;
                        });
                      },
                      activeColor: switchColor,
                      inactiveTrackColor: Colors.grey,
                    ),
                  ],
                ),
                isActive: _currentStep >= 4,
                state: _currentStep >= 4 ? StepState.complete : StepState.indexed,
              ),
            ],
            controlsBuilder: (BuildContext context, ControlsDetails details) {
              final isLastStep = _currentStep == 4;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (!isLastStep) ...[
                    ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.cyan, // Texto blanco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes redondeados de 10 píxeles
                        ),
                      ),
                      child: Text('Siguiente'),
                    ),
                    TextButton(
                      onPressed: details.onStepCancel,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.orange, // Texto blanco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes redondeados de 10 píxeles
                        ),
                      ),
                      child: Text('Cancelar'),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () {
                        details.onStepContinue?.call();
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.cyan, // Texto blanco
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // Bordes redondeados de 10 píxeles
                        ),
                      ),
                      child: Text('Guardar Datos'),
                    )
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
