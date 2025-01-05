import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class ContactSelectionScreen extends StatefulWidget {
  @override
  _ContactSelectionScreenState createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends State<ContactSelectionScreen> {
  List<Contact> _contacts = [];
  List<Contact> _selectedContacts = [];
  TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  static const int MAX_CONTACTS = 30;

  // Color schemes
  static const lightColors = {
    'primary': Color(0xFF1976D2),
    'secondary': Color(0xFF2196F3),
    'accent': Color(0xFF03A9F4),
    'background': Color(0xFFF5F6FA),
    'card': Colors.white,
    'text': Color(0xFF2C3E50),
    'subtext': Color(0xFF546E7A),
    'searchBackground': Color(0xFFFFFFFF),
    'error': Color(0xFFE57373),
  };

  static const darkColors = {
    'primary': Color(0xFF1565C0),
    'secondary': Color(0xFF1976D2),
    'accent': Color(0xFF03A9F4),
    'background': Color(0xFF121212),
    'card': Color(0xFF1E1E1E),
    'text': Color(0xFFE0E0E0),
    'subtext': Color(0xFFB0BEC5),
    'searchBackground': Color(0xFF2C2C2C),
    'error': Color(0xFFEF5350),
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterContacts);
    _fetchContacts();
  }

  void _filterContacts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredContacts = _contacts
          .where((contact) =>
          (contact.displayName?.toLowerCase() ?? '').contains(query))
          .toList();
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchContacts();
  }

  Widget _buildContactAvatar(Contact contact, bool isSelected, Map<String, Color> colors) {
    // Verificar si el contacto tiene foto
    if (contact.avatar != null && contact.avatar!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: isSelected ? colors['accent'] : colors['primary']!.withOpacity(0.1),
        radius: 20,
        backgroundImage: MemoryImage(contact.avatar!),
      );
    } else {
      // Si no tiene foto, mostrar iniciales
      return CircleAvatar(
        backgroundColor: isSelected ? colors['accent'] : colors['primary']!.withOpacity(0.1),
        radius: 20,
        child: Text(
          contact.initials() ?? '',
          style: TextStyle(
            color: isSelected ? Colors.white : colors['primary'],
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      );
    }
  }

  void _handleContactSelection(Contact contact, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedContacts.remove(contact);
      } else {
        if (_selectedContacts.length >= MAX_CONTACTS) {
          _showMaxContactsDialog();
          return;
        }
        _selectedContacts.add(contact);
      }
    });
  }

  void _showMaxContactsDialog() {
    final colors = Theme.of(context).brightness == Brightness.dark
        ? darkColors
        : lightColors;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors['card'],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Límite Alcanzado',
          style: TextStyle(
            color: colors['text'],
            fontWeight: FontWeight.w600, fontSize: 15
          ),
        ),
        content: Text(
          'Solo puedes seleccionar hasta $MAX_CONTACTS contactos.',
          style: TextStyle(
            color: colors['text']!.withOpacity(0.7),
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey), // Borde gris
            ),
            child: Text(
              'Entendido',
              style: TextStyle(color: colors['accent']), // Texto con color personalizado
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = isDark ? darkColors : lightColors;

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: colors['background'],
        primaryColor: colors['primary'],
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: colors['primary']!,
          secondary: colors['accent']!,
          surface: colors['card']!,
          onSurface: colors['text']!,
        ),
      ),
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: colors['primary'],
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Seleccionar Contactos',
                      style: TextStyle(
                        fontSize: fontSizeProvider.fontSize + 2,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (innerBoxIsScrolled && _selectedContacts.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: 10), // Ajusta el valor para moverlo más o menos
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            '${_selectedContacts.length}/$MAX_CONTACTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors['primary']!,
                        colors['secondary']!,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(
                            Icons.contacts,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      if (_selectedContacts.isNotEmpty)
                        Positioned(
                          bottom: 15,
                          right: 30,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              '${_selectedContacts.length}/$MAX_CONTACTS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          body: RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Search Bar
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    decoration: BoxDecoration(
                      color: colors['searchBackground'],
                      borderRadius: BorderRadius.circular(13),
                      boxShadow: [
                        BoxShadow(
                          color: colors['primary']!.withOpacity(0.08),
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: colors['text'],
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Buscar contactos',
                        hintStyle: TextStyle(
                          color: colors['subtext'],
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: colors['accent'],
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  ),
                ),

                // Loading State
                if (_isLoading)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Lottie.asset(
                            'lib/assets/loading/loading_infinity.json',
                            width: 50,
                            height: 50,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Cargando contactos...',
                            style: TextStyle(
                              color: colors['subtext'],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_contacts.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contacts_outlined,
                            size: 48,
                            color: colors['subtext'],
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No se encontraron contactos',
                            style: TextStyle(
                              color: colors['subtext'],
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Desliza hacia abajo para recargar',
                            style: TextStyle(
                              color: colors['subtext'],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                // Contacts List
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final contact = _searchController.text.isEmpty
                            ? _contacts[index]
                            : _filteredContacts[index];
                        final isSelected = _selectedContacts.contains(contact);

                        return AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          margin:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors['card'],
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: colors['primary']!.withOpacity(0.05),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                            border: isSelected
                                ? Border.all(color: colors['accent']!, width: 2)
                                : null,
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 2),
                            leading: _buildContactAvatar(contact, isSelected, colors),
                            title: Text(
                              contact.displayName ?? '',
                              style: TextStyle(
                                color: colors['text'],
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: contact.phones?.isNotEmpty ?? false
                                ? Text(
                              contact.phones!.first.value ?? '',
                              style: TextStyle(
                                color: colors['subtext'],
                                fontSize: 11,
                              ),
                            )
                                : null,
                            trailing: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color:
                              isSelected ? colors['accent'] : colors['subtext'],
                              size: 20,
                            ),
                            onTap: () => _handleContactSelection(contact, isSelected),
                          ),
                        );
                      },
                      childCount: _searchController.text.isEmpty
                          ? _contacts.length
                          : _filteredContacts.length,
                    ),
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton:
        _selectedContacts.isEmpty ? null : _buildFloatingActionButton(colors),
      ),
    );
  }

  Widget _buildFloatingActionButton(Map<String, Color> colors) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: colors['primary'],
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: colors['primary']!.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_selectedContacts.length} seleccionados',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 12),
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors['accent'],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchContacts() async {
    try {
      var status = await Permission.contacts.request();
      if (status.isGranted) {
        Iterable<Contact> contacts = await ContactsService.getContacts();
        setState(() {
          _contacts =
              contacts.where((contact) => contact.displayName != null).toList();
          _filteredContacts = _contacts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showPermissionDeniedDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Permiso Denegado'),
        content: Text(
            'Por favor, permite el acceso a los contactos en la configuración de la aplicación.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text('Error al cargar los contactos. Intenta nuevamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}