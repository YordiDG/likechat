import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AccountOptionsDialog {
  static void show(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final contentColor = isDarkMode ? Colors.grey[300] : Colors.black;
    final buttonTextColor = isDarkMode ? Colors.white : Colors.black;
    final snackBarBackgroundColor = Colors.red;
    final snackBarTextColor = Colors.white;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            '¿Qué quieres hacer?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Selecciona una opción para desactivar o eliminar tu cuenta.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
            ),
            textAlign: TextAlign.justify,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          actions: <Widget>[
            _buildDialogButton(
              dialogContext,
              label: 'Desactivar Cuenta',
              icon: Icons.pause_circle_outline,
              color: Colors.orange,
              textColor: buttonTextColor,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deactivateAccount(
                  context,
                  snackBarBackgroundColor,
                  snackBarTextColor,
                );
              },
            ),
            _buildDialogButton(
              dialogContext,
              label: 'Eliminar Cuenta',
              icon: Icons.delete_forever,
              color: Colors.red,
              textColor: buttonTextColor,
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showDeleteConfirmation(context);
              },
            ),
            _buildDialogButton(
              dialogContext,
              label: 'Cancelar',
              icon: Icons.cancel,
              color: Colors.grey,
              textColor: buttonTextColor,
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static TextButton _buildDialogButton(
      BuildContext context, {
        required String label,
        required IconData icon,
        required Color color,
        required Color textColor,
        required VoidCallback onPressed,
      }) {
    return TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color.withOpacity(0.6)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      onPressed: onPressed,
    );
  }

  static void _deactivateAccount(
      BuildContext context,
      Color snackBarBackgroundColor,
      Color snackBarTextColor,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tu cuenta ha sido desactivada indefinidamente. Puedes reactivarla en cualquier momento.',
          style: TextStyle(fontSize: 16, color: snackBarTextColor),
        ),
        backgroundColor: snackBarBackgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
    // Lógica adicional para manejar la desactivación indefinida
  }

  static void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext confirmDialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text(
            '¿Estás seguro?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Se perderán todos tus datos y no podrás recuperarlos. ¿Deseas continuar?',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
            textAlign: TextAlign.justify,
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.grey),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(confirmDialogContext).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.red),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(confirmDialogContext).pop();
                _deleteAccount(context);
              },
            ),
          ],
        );
      },
    );
  }

  static Future<void> _deleteAccount(BuildContext context) async {
    // Bloquear la interfaz por completo durante la eliminación
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar el diálogo
      barrierColor: Colors.black.withOpacity(0.8), // Fondo oscuro
      builder: (BuildContext loadingContext) {
        return WillPopScope(
          onWillPop: () async => false, // Desactivar el botón de retroceso
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'lib/assets/loading-end.json',
                    width: 130,
                    height: 130,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Eliminando cuenta, espera un momento...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      // Evaluar la conexión
      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.none) {
        // No hay conexión, mostrar mensaje de error
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No tienes conexión a internet. Por favor, verifica tu conexión.',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      } else if (connectivityResult == ConnectivityResult.mobile ||
          connectivityResult == ConnectivityResult.wifi) {
        // Conexión buena, simular demora
        await Future.delayed(Duration(seconds: 5));
      } else {
        // Conexión lenta, mostrar animación de carga más tiempo
        await Future.delayed(Duration(seconds: 8));
      }

      // Simular proceso de eliminación de cuenta
      await Future.delayed(Duration(seconds: 2));

      // Cerrar diálogo de carga
      Navigator.of(context, rootNavigator: true).pop();

      // Mostrar SnackBar de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tu cuenta ha sido eliminada exitosamente.',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Esperar a que el SnackBar desaparezca antes de navegar
      await Future.delayed(Duration(seconds: 2));

      // Navegar al login y limpiar la pila de rutas
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } catch (e) {
      // Manejo de errores
      Navigator.of(context, rootNavigator: true).pop(); // Cerrar diálogo de carga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hubo un error al eliminar tu cuenta. Por favor, intenta de nuevo.',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}


class AccountMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const AccountMenuTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Cambia el color a un gris claro si no está en modo oscuro
    final tileColor = isDarkMode ? Colors.grey[900] : Colors.grey[100];
    final titleColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey;

    return ListTile(
      tileColor: tileColor,
      leading: Icon(
        icon,
        color: Colors.blue,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: subtitleColor,
          fontSize: 11,
        ),
      ),
      onTap: () {
        AccountOptionsDialog.show(context);
      },
    );
  }
}

