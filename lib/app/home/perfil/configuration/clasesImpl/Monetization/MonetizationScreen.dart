import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';


class MonetizationScreen extends StatefulWidget {
  @override
  _MonetizationScreenState createState() => _MonetizationScreenState();
}

class _MonetizationScreenState extends State<MonetizationScreen> {
  // Variables para controlar el estado de expansión de las secciones
  bool _showEarningsDetails = false;
  bool _showPayoutDetails = false;
  bool _showTransactions = false;
  bool _showReferrals = false;
  bool _showHistory = false;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Monetización'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder para cuentas nuevas
            _buildPlaceholder(),
            SizedBox(height: 16.0),
            _buildExpandableSection(
              title: 'Detalles de Ganancias',
              showDetails: _showEarningsDetails,
              onToggle: () {
                setState(() {
                  _showEarningsDetails = !_showEarningsDetails;
                });
              },
              details: [
                _buildDetailItem(
                  title: 'Ganancias Totales',
                  value: '\$2,345.67',
                ),
                _buildDetailItem(
                  title: 'Ganancias del Mes',
                  value: '\$123.45',
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _buildExpandableSection(
              title: 'Detalles de Pagos',
              showDetails: _showPayoutDetails,
              onToggle: () {
                setState(() {
                  _showPayoutDetails = !_showPayoutDetails;
                });
              },
              details: [
                _buildDetailItem(
                  title: 'Último Pago',
                  value: '\$100.00',
                ),
                _buildDetailItem(
                  title: 'Método de Pago',
                  value: 'Transferencia Bancaria',
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _buildExpandableSection(
              title: 'Transacciones',
              showDetails: _showTransactions,
              onToggle: () {
                setState(() {
                  _showTransactions = !_showTransactions;
                });
              },
              details: [
                _buildDetailItem(
                  title: 'Transacción 1',
                  value: '\$50.00 - 01/08/2024',
                ),
                _buildDetailItem(
                  title: 'Transacción 2',
                  value: '\$30.00 - 05/08/2024',
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _buildExpandableSection(
              title: 'Referencias',
              showDetails: _showReferrals,
              onToggle: () {
                setState(() {
                  _showReferrals = !_showReferrals;
                });
              },
              details: [
                _buildDetailItem(
                  title: 'Referido 1',
                  value: 'Ganancias: \$10.00',
                ),
                _buildDetailItem(
                  title: 'Referido 2',
                  value: 'Ganancias: \$15.00',
                ),
              ],
            ),
            SizedBox(height: 16.0),
            _buildExpandableSection(
              title: 'Historial',
              showDetails: _showHistory,
              onToggle: () {
                setState(() {
                  _showHistory = !_showHistory;
                });
              },
              details: [
                _buildDetailItem(
                  title: 'Actividad del Mes',
                  value: 'Ver Historial',
                ),
                _buildDetailItem(
                  title: 'Historial Anterior',
                  value: 'Ver Historial',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 50.0, color: Colors.blueAccent),
            SizedBox(height: 16.0),
            Text(
              'Aún no tienes datos de monetización.',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[700],
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '¡Empieza a publicar contenido y ganar dinero!',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.blueGrey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool showDetails,
    required VoidCallback onToggle,
    required List<Widget> details,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            title: Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[800],
              ),
            ),
            trailing: Icon(
              showDetails ? Icons.expand_less : Icons.expand_more,
              size: 28.0,
              color: Colors.blueGrey[600],
            ),
            onTap: onToggle,
          ),
          if (showDetails) ...details,
        ],
      ),
    );
  }

  Widget _buildDetailItem({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 1.0),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
            color: Colors.blueGrey[700],
          ),
        ),
        trailing: Text(
          value,
          style: TextStyle(
            fontSize: 14.0,
            color: Colors.blueGrey[900],
          ),
        ),
      ),
    );
  }
}
