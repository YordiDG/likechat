import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = ['Flutter', 'Dart', 'Firebase']; // Ejemplo de búsquedas recientes
  List<String> _popularSearches = ['Widgets', 'State Management', 'UI Design']; // Ejemplo de búsquedas populares
  List<String> _searchResults = []; // Lista para almacenar resultados de la búsqueda

  @override
  void initState() {
    super.initState();
    _searchResults = _recentSearches; // Mostrar búsquedas recientes inicialmente
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0), // Altura personalizada del AppBar
        child: AppBar(
          backgroundColor: Colors.deepPurple[600], // Color del appbar
          elevation: 0, // Sin sombra bajo el appbar
          titleSpacing: 0, // Espaciado entre el título y los bordes del AppBar
          title: Container(
            height: 45, // Altura personalizada del contenedor de búsqueda
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.white,
              border: Border.all(color: Colors.grey.withOpacity(0.5)), // Borde ligero
            ),
            padding: EdgeInsets.symmetric(horizontal: 12), // Ajuste de padding para el TextField
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.grey),
                SizedBox(width: 8), // Aumentado el espacio para mejor separación visual
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          constraints: BoxConstraints(minWidth: 0),
                          width: MediaQuery.of(context).size.width - 100,
                          child: TextField(
                            controller: _searchController,
                            maxLines: 1, // Máximo de una línea para evitar que el texto se corte
                            textInputAction: TextInputAction.search, // Acción de teclado para "Buscar"
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                              _performSearch(value);
                            },
                            decoration: InputDecoration(
                              hintText: 'Buscar',
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Condicional para mostrar icono de limpiar (X) o micrófono
                _searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _searchResults = _recentSearches;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Icon(Icons.clear, color: Colors.white, size: 18),
                  ),
                )
                    : IconButton(
                  icon: Icon(Icons.mic, color: Colors.grey),
                  onPressed: () {
                    // Acción para activar el micrófono
                  },
                ),
              ],
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.group_add, color: Colors.white),
              onPressed: () {
                _clearSearch();
              },
            ),
          ],
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = _recentSearches; // Mostrar búsquedas recientes si no hay query
      });
    } else {
      // Simulación de búsqueda real o lógica para filtrar resultados
      List<String> results = _popularSearches
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _searchResults = results.isNotEmpty ? results : ['No encontrado']; // Mostrar resultados o mensaje de no encontrado
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _searchResults = _recentSearches; // Restaurar búsquedas recientes al limpiar
    });
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
      child: Text(
        'No se encontraron resultados',
        style: TextStyle(fontSize: 18, color: Colors.grey),
      ),
    )
        : ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_searchResults[index]),
          onTap: () {
            // Acción al seleccionar un resultado de búsqueda
          },
        );
      },
    );
  }
}
