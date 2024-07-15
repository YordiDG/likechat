import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactSelectionScreen extends StatefulWidget {
  @override
  _ContactSelectionScreenState createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar Contactos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _contacts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _buildContactList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendSelectedContacts,
        backgroundColor: Colors.cyan,
        child: Icon(Icons.send),
      ),
      backgroundColor: Colors.black, // Set background color
    );
  }

  Future<void> _fetchContacts() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      Iterable<Contact> contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts.where((contact) => contact.displayName != null).toList();
      });
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Widget _buildContactList() {
    return ListView.builder(
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Container(
          color: _selectedContacts.contains(contact) ? Colors.grey[700] : Colors.grey[850],
          child: ListTile(
            leading: CircleAvatar(
              child: Text(contact.initials()),
              backgroundColor: Colors.cyan,
            ),
            title: Text(
              contact.displayName ?? '',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() {
                if (_selectedContacts.contains(contact)) {
                  _selectedContacts.remove(contact);
                } else {
                  _selectedContacts.add(contact);
                }
              });
            },
            trailing: _selectedContacts.contains(contact)
                ? Icon(Icons.check, color: Colors.cyan)
                : null,
          ),
        );
      },
    );
  }

  void _sendSelectedContacts() {
    if (_selectedContacts.isNotEmpty) {
      print('Contactos seleccionados: ${_selectedContacts.map((c) => c.displayName).toList()}');
      Navigator.of(context).pop(_selectedContacts);
    } else {
      _showEmptySelectionDialog();
    }
  }

  void _showEmptySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850], // Dark background
          title: Text(
            'Sin Selección',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Bold white title
          ),
          content: Text(
            'Por favor, selecciona al menos un contacto.',
            style: TextStyle(color: Colors.grey[300]), // Light gray text
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(color: Colors.cyan), // Cyan text
              ),
            ),
          ],
        );
      },
    );
  }


  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Permiso Denegado', style: TextStyle(color: Colors.white)),
          content: Text(
            'Por favor, permite el acceso a los contactos en la configuración de la aplicación.',
            style: TextStyle(color: Colors.grey[300]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
  }
}
