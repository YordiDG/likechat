import 'package:flutter/material.dart';

class PoliticasPrivacidadScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black), // Nuevo ícono
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Política de Privacidad',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16, // Título más grande
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.local_police, color: Colors.black),
            onPressed: () {
              // Acción de ayuda
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: RichText(
            textAlign: TextAlign.justify, // Ajustar texto justificado
            text: TextSpan(
              style: TextStyle(color: Colors.black, fontSize: 16),
              children: [
                TextSpan(
                  text: 'Política de Privacidad\n\n',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.blueGrey,
                  ),
                ),
                _buildSectionTitle('1. Introducción'),
                _buildSectionText(
                  'En nuestra plataforma, la privacidad y seguridad de los datos personales de nuestros usuarios son de suma importancia. Esta Política de Privacidad describe cómo recopilamos, utilizamos y protegemos tu información personal.\n\n',
                ),
                _buildSectionTitle('2. Información que Recopilamos'),
                _buildSectionText(
                  'Recopilamos información que nos proporcionas directamente al crear una cuenta, como nombre, correo electrónico, número de teléfono, y contenido que generas (fotos, videos, comentarios). También recopilamos datos sobre cómo interactúas con nuestra plataforma, como la dirección IP, el tipo de dispositivo, y las páginas visitadas.\n\n',
                ),
                _buildSectionTitle('3. Uso de la Información'),
                _buildSectionText(
                  'Usamos la información que recopilamos para:\n• Proporcionar y mejorar nuestros servicios.\n• Personalizar tu experiencia en la plataforma.\n• Enviar notificaciones relacionadas con tu cuenta o el servicio.\n• Responder a tus consultas o brindarte soporte.\n\n',
                ),
                _buildSectionTitle('4. Compartir Información con Terceros'),
                _buildSectionText(
                  'No compartimos tu información personal con terceros, excepto en las siguientes circunstancias:\n• Con proveedores de servicios que nos ayudan a operar la plataforma.\n• Cuando lo exija la ley o sea necesario para cumplir con obligaciones legales.\n• Para proteger la seguridad de nuestros usuarios o de la plataforma.\n\n',
                ),
                _buildSectionTitle('5. Seguridad de los Datos'),
                _buildSectionText(
                  'Implementamos medidas de seguridad técnicas y organizativas para proteger tu información personal contra accesos no autorizados, alteraciones, o divulgación. Sin embargo, no podemos garantizar la seguridad absoluta de los datos transmitidos a través de internet.\n\n',
                ),
                _buildSectionTitle('6. Tus Derechos'),
                _buildSectionText(
                  'Tienes derecho a acceder, corregir, o eliminar la información personal que tenemos sobre ti. También puedes retirar tu consentimiento para el procesamiento de tus datos en cualquier momento.\n\n',
                ),
                _buildSectionTitle('7. Retención de Datos'),
                _buildSectionText(
                  'Conservamos tu información personal mientras mantengas una cuenta activa o sea necesario para proporcionarte nuestros servicios. En algunos casos, podemos conservar datos durante un período más largo para cumplir con obligaciones legales.\n\n',
                ),
                _buildSectionTitle('8. Cambios en la Política de Privacidad'),
                _buildSectionText(
                  'Podemos actualizar esta Política de Privacidad de vez en cuando para reflejar cambios en nuestras prácticas o en la legislación aplicable. Te notificaremos sobre cualquier cambio importante a través de nuestra plataforma o por correo electrónico.\n\n',
                ),
                _buildSectionTitle('9. Contacto'),
                _buildSectionText(
                  'Si tienes alguna pregunta sobre esta Política de Privacidad o sobre cómo gestionamos tus datos personales, no dudes en ponerte en contacto con nosotros a través de los medios de soporte proporcionados.\n\n',
                ),
                TextSpan(
                  text: 'Última actualización: 16 de Octubre 2024 \n',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextSpan _buildSectionTitle(String title) {
    return TextSpan(
      text: '$title\n',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.black,
      ),
    );
  }

  TextSpan _buildSectionText(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(fontSize: 16, color: Colors.black),
    );
  }
}
