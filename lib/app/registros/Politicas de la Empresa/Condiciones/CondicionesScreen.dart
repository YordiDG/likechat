import 'package:flutter/material.dart';

class CondicionesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);  // Al presionar el botón de retroceso del dispositivo, cerrar la pantalla
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);  // Regresa a la pantalla anterior
            },
          ),
          title: Text(
            'Condiciones de Uso',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.help_outline, color: Colors.black),
              onPressed: () {
                // Acción de ayuda
              },
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[100],
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Términos y Condiciones',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey[400], height: 0.4),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildCondicionItem(
                        '1. Aceptación de las Condiciones',
                        'Al crear una cuenta en nuestra plataforma y utilizar nuestros servicios, aceptas cumplir con estas Condiciones de Uso. Si no aceptas alguna parte de estas condiciones, no debes utilizar la aplicación.',
                      ),
                      _buildCondicionItem(
                        '2. Creación de Cuenta y Veracidad de la Información',
                        'Es obligatorio que los usuarios proporcionen información veraz al crear una cuenta. Nos reservamos el derecho de suspender o eliminar cuentas que contengan información falsa o engañosa.',
                      ),
                      _buildCondicionItem(
                        '3. Propiedad Intelectual y Derechos de Autor',
                        'Todo el contenido que creas y publiques en nuestra plataforma es de tu propiedad. Sin embargo, al publicar, nos otorgas una licencia no exclusiva para usar, distribuir, y promocionar tu contenido dentro de la plataforma.',
                      ),
                      _buildCondicionItem(
                        '4. Uso Responsable de la Plataforma',
                        'Te comprometes a no utilizar la plataforma para compartir contenido que sea ilegal, ofensivo, o que infrinja los derechos de otros.',
                      ),
                      _buildCondicionItem(
                        '5. Contenido Inapropiado',
                        'Nos reservamos el derecho de eliminar cualquier contenido que consideremos inapropiado o que infrinja estas condiciones.',
                      ),
                      _buildCondicionItem(
                        '6. Privacidad y Protección de Datos',
                        'Nos tomamos muy en serio la privacidad de nuestros usuarios. Consulta nuestra Política de Privacidad para obtener más detalles.',
                      ),
                      _buildCondicionItem(
                        '7. Modificaciones a las Condiciones de Uso',
                        'Nos reservamos el derecho de modificar estas Condiciones de Uso en cualquier momento. Notificaremos a los usuarios sobre cualquier cambio significativo.',
                      ),
                      _buildCondicionItem(
                        '8. Limitación de Responsabilidad',
                        'No seremos responsables de ningún daño directo, indirecto o consecuente que surja del uso o la incapacidad de uso de nuestra plataforma.',
                      ),
                      _buildCondicionItem(
                        '9. Contacto',
                        'Si tienes alguna pregunta sobre estas Condiciones de Uso, contáctanos a través de los canales de soporte disponibles.',
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Última actualización: 16 de Octubre 2024',
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget reutilizable para cada sección de condiciones
  Widget _buildCondicionItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
