import 'package:flutter/material.dart';

import 'MetodosPagos/PaymentMethodScreen.dart';

class PromotionPreview extends StatelessWidget {
  final String imageUrl; // URL de la imagen a previsualizar
  final Color textColor;

  PromotionPreview({required this.imageUrl, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promocionar Contenido', style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 17)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muestra la imagen previsualizada
            Container(
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Título de la promoción
            Text(
              'Promocionar publicación',
              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Opciones de promoción
            Expanded(
              child: ListView(
                children: [
                  Text('Alcance de la publicación:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 8),
                  _buildPromotionReachOption('Impulsar ventas', Icons.sell),
                  _buildPromotionReachOption('Conseguir clientes potenciales', Icons.people),
                  _buildPromotionReachOption('Más visualizaciones', Icons.visibility),
                  _buildPromotionReachOption('Más seguidores', Icons.person_add),
                  _buildPromotionReachOption('Más visualizaciones de perfil', Icons.visibility_outlined),
                  SizedBox(height: 16),
                  Text('Elige un plan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  _buildPromotionOption('Básica', 10, '1 día'),
                  _buildPromotionOption('Estándar', 50, '3 días'),
                  _buildPromotionOption('Premium', 100, '7 días'),
                  _buildPromotionOption('Pro', 500, '30 días'),
                  _buildPromotionOption('Max', 2800, '90 días'),
                  SizedBox(height: 16),
                  Text('Promoción personalizada:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Descripción de la promoción',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Campo para monto seleccionado
                  Text('Monto Seleccionado: ₡100', style: TextStyle(color: textColor, fontSize: 16)),
                  SizedBox(height: 16),
                  Text('Método de Pago', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  // Llama al método para crear la opción de pago
                  _buildPaymentMethodOption(context, 'Tarjeta de crédito', Icons.credit_card),
                  _buildPaymentMethodOption(context, 'PayPal', Icons.account_balance_wallet),
                  _buildPaymentMethodOption(context, 'Transferencia bancaria', Icons.account_balance),
                  SizedBox(height: 16),
                  // Botón para confirmar la promoción
                  ElevatedButton(
                    onPressed: () {
                      _confirmPromotion(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Pagar', style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 16),
                  // Términos y condiciones
                  Text(
                    'Al continuar, aceptas los términos de pago de LikeChat y la política de publicidad.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Método para crear una opción de alcance de publicación
  Widget _buildPromotionReachOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: () {
        // Lógica para seleccionar el alcance
        print('Seleccionaste el alcance: $title');
      },
    );
  }

  // Método para crear una opción de promoción
  Widget _buildPromotionOption(String title, int price, String duration) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.campaign_sharp, size: 29, color: Colors.red),
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(
        '₡$price • Duración: $duration',
        style: TextStyle(color: Colors.grey),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      onTap: () {
        // Lógica adicional para seleccionar la opción
        print('Seleccionaste la opción $title por ₡$price');
      },
    );
  }

  // Método para crear una opción de método de pago
  Widget _buildPaymentMethodOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(title, style: TextStyle(color: Colors.black)),
      onTap: () {
        // Navega a PaymentMethodScreen si se selecciona la tarjeta de crédito
        if (title == 'Tarjeta de crédito') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PaymentMethodScreen()),
          );
        } else {
          // Lógica para otros métodos de pago
          print('Seleccionaste el método de pago: $title');
        }
      },
    );
  }

  // Método para confirmar la promoción
  void _confirmPromotion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Promoción Confirmada'),
        content: Text('Tu publicación ha sido promovida.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
