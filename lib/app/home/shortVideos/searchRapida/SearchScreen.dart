import 'package:flutter/material.dart';
import 'Ayuda/HelpScreen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _recentSearches = ['LikeChat', 'Dart', 'Firebase', 'Amor', 'Flutter', 'Yoes'];
  List<String> _popularSearches = [
    'Widgets', 'State Management', 'Amor', 'viral', 'musica', 'persona',
    'dato', 'likechat', 'Hola', 'nuevo', 'UI Design', 'Messi'
  ];
  List<String> _searchResults = [];
  List<String> _trendingSearches = ['Messi', 'LikeChat', 'UI Design', 'Flutter', 'Amor', 'UI Design']; // Ejemplo de palabras tendencia
  bool _showAllPopularSearches = false;

  @override
  void initState() {
    super.initState();
    _searchResults = _recentSearches;
    if (_recentSearches.isNotEmpty) {
      _searchController.text = _recentSearches.first; // Establece la última búsqueda como texto inicial
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          titleSpacing: 0,
          title: Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              border: Border.all(color: Colors.white.withOpacity(0.9)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12),
            margin: EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 0),
                      width: MediaQuery.of(context).size.width - 100,
                      decoration: BoxDecoration(
                        color: Colors.transparent, // Fondo transparente del contenedor
                      ),
                      child: TextField(
                        controller: _searchController,
                        maxLines: 1,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _performSearch(value);
                        },
                        decoration: InputDecoration(
                          hintText: _searchController.text.isEmpty ? 'Buscar' : _searchController.text,
                          hintStyle: TextStyle(color: Colors.white), // Ajusta el color del hint a blanco
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          fillColor: Colors.transparent, // Fondo del TextField transparente
                          filled: true,
                        ),
                        style: TextStyle(color: Colors.white), // Color del texto blanco
                      ),
                    ),

                  ),
                ),
                _searchQuery.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    _addToRecentSearches(_searchQuery);
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _searchResults = _recentSearches;
                    });
                  },
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                    child: Icon(Icons.clear, color: Colors.white, size: 16),
                  ),
                )
                    : IconButton(
                  icon: _searchQuery.toLowerCase() == 'tendencia'
                      ? Icon(Icons.candlestick_chart, color: Colors.orange) // Icono de candelas
                      : Icon(Icons.mic, color: Colors.white), // Icono de micrófono
                  onPressed: () {
                    if (_searchQuery.toLowerCase() == 'tendencia') {
                      _searchController.text = 'tendencia';
                      _performSearch('tendencia');
                    } else {
                      // Acción al tocar el ícono de micrófono
                    }
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
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height, // Ajusta la altura al tamaño de la pantalla
        color: Colors.black, // Fondo negro para todo el cuerpo
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 12),
              if (_trendingSearches.isNotEmpty)
                Container(
                  color: Colors.black, // Color de fondo para las palabras tendencia
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tendencias',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        height: 40, // Altura deseada para el carrusel de palabras tendencia
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _trendingSearches.length,
                          separatorBuilder: (context, index) => SizedBox(width: 8), // Espacio entre elementos
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                _searchController.text = _trendingSearches[index];
                                _performSearch(_trendingSearches[index]);
                              },
                              child: Chip(
                                label: Row(
                                  children: [
                                    Icon(Icons.local_fire_department, color: Colors.red),
                                    SizedBox(width: 4),
                                    Text(
                                      _trendingSearches[index],
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                                backgroundColor: Colors.cyan,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              Container(
                color: Colors.black, // Fondo negro para los resultados de búsqueda
                child: _buildSearchResults(),
              ),
              SizedBox(height: 80),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HelpScreen()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.grey.withOpacity(0.6),
                    ),
                    child: Text(
                      'Ayuda',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, // Color de la letra blanca
                        fontSize: 15,
                        decoration: TextDecoration.none,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = _recentSearches;
      });
    } else {
      List<String> results = _popularSearches
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();

      setState(() {
        _searchResults = results.isNotEmpty ? results : ['No encontrado'];
      });
    }
  }

  void _addToRecentSearches(String query) {
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  Widget _buildSearchResults() {
    return _searchResults.isEmpty
        ? Center(
      child: Text('No hay resultados'),
    )
        : Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _showAllPopularSearches
              ? _searchResults.length
              : (_searchResults.length > 5 ? 6 : _searchResults.length),
          itemBuilder: (context, index) {
            if (!_showAllPopularSearches &&
                index == 5 &&
                _searchResults.length > 5) {
              return InkWell(
                onTap: () {
                  setState(() {
                    _showAllPopularSearches = true;
                  });
                },
                child: Padding(
                  padding:
                  EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.expand_more, color: Colors.grey[400]),
                      SizedBox(width: 4),
                      Text(
                        'Ver más',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return Dismissible(
              key: Key(_searchResults[index]),
              background: Container(
                color: Colors.grey.withOpacity(0.1),
              ),
              onDismissed: (direction) {
                setState(() {
                  _searchResults.removeAt(index);
                });
              },
              child: ListTile(
                title: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      child: Center(
                        child: Icon(
                          Icons.access_time_filled,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(_searchResults[index], style: TextStyle(color: Colors.white),),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchResults.removeAt(index);
                        });
                      },
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red,
                        ),
                        child:
                        Center(child: Icon(Icons.clear, color: Colors.white, size: 16)),
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  // Acción al seleccionar un resultado de búsqueda
                },
              ),
            );
          },
        ),
        if (_showAllPopularSearches)
          InkWell(
            onTap: () {
              setState(() {
                _showAllPopularSearches = false;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.expand_less, color: Colors.grey[400]),
                  SizedBox(width: 4),
                  Text(
                    'Ver menos',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
