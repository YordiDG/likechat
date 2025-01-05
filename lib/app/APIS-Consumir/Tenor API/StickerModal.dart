import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'GiphyService.dart';
import 'dao/Sticker.dart';
import 'database/DatabaseHelper.dart';
import 'package:provider/provider.dart';

class StickerModal extends StatefulWidget {
  @override
  _StickerModalState createState() => _StickerModalState();
}

class _StickerModalState extends State<StickerModal> {
  Future<List<Sticker>>? stickers; // Cambia a Future<List<Sticker>>?
  late List<Sticker> allStickers = [];
  List<Sticker> favoriteStickers = [];
  String searchQuery = '';
  String selectedCategory = 'Stickers';
  final dbHelper = DatabaseHelper();
  final giphService = GiphyService();

  final TextEditingController _searchTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStickers(); // Cargar stickers inicialmente
    loadFavorites();
  }

  void loadStickers() async {
    allStickers =
        await giphService.fetchStickers(''); // Cargar stickers por defecto
    setState(() {
      stickers = Future.value(allStickers); // Asignar future al inicio
    });
  }

  void loadFavorites() async {
    favoriteStickers = await dbHelper.getFavorites();
    setState(() {});
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      // Filtrar stickers según el query
      if (query.isEmpty) {
        stickers = Future.value(allStickers);
      } else {
        stickers = giphService.fetchStickers(query);
      }
    });
  }

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  Future<bool> checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(15),
          ),
        ),
        child: Column(
          children: [
            buildStickerHeader(iconColor, textColor, _searchTextController, (searchText) {
            }),

            customSearchField(
              searchController: _searchTextController,
              onSearchChanged: onSearchChanged,
              isDarkMode: isDarkMode,
            ),

            SizedBox(height: 11.0),
            categorySelectionRow(
              selectedCategory: selectedCategory,
              selectCategory: selectCategory,
              textColor: textColor,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.0),
              child: Divider(
                color: Colors.grey,
                thickness: 0.2,
              ),
            ),

            // Grilla de stickers
            buildStickerGrid(),
          ],
        ),
      ),
    );
  }

  //seccion de header
  Widget buildStickerHeader(
      Color iconColor,
      Color textColor,
      TextEditingController _searchTextController,
      Function(String) onSearchChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _searchTextController.clear();
              onSearchChanged('');
            },
            child: Icon(
              Icons.clear,
              color: iconColor,
              size: 20,
            ),
          ),
          Expanded(
            child: Text(
              'Selecciona stickers',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Icon(
              Icons.error_outline,
              color: Colors.grey.shade500,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  //seccion e search
  Widget customSearchField({
    required TextEditingController searchController,
    required Function(String) onSearchChanged,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.cyan,
            selectionColor: Colors.cyan.withOpacity(0.3),
            selectionHandleColor: Colors.cyan,
          ),
        ),
        child: SizedBox(
          child: SizedBox(
            height: 40, // Altura ajustada para mejor visibilidad
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              cursorColor: Colors.cyan,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDarkMode
                    ? const Color(0xFF2C2C2C)
                    : const Color(0xFFF3F3F3),
                hintText: 'Buscar GIPHY',
                hintStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode
                      ? Colors.grey.shade400
                      : Colors.grey.shade600,
                ),
                isDense: true,
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                  iconSize: 16,
                  icon: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 13,
                    ),
                  ),
                  onPressed: () {
                    searchController.clear();
                    onSearchChanged('');
                  },
                )
                    : null,
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: isDarkMode
                      ? Colors.grey.shade500
                      : Colors.grey.shade700,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12.0,
                  horizontal: 12.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.cyan.shade400,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

//section de categoria
  Widget categorySelectionRow({
    required String selectedCategory,
    required Function(String) selectCategory,
    required Color textColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _categoryButton(
          label: 'Stickers',
          isSelected: selectedCategory == 'Stickers',
          onTap: () => selectCategory('Stickers'),
          textColor: textColor,
        ),
        _categoryButton(
          label: 'Emoticones',
          isSelected: selectedCategory == 'Emoticones',
          onTap: () => selectCategory('Emoticones'),
          textColor: textColor,
        ),
        _categoryButton(
          label: 'Favoritos',
          isSelected: selectedCategory == 'Favoritos',
          onTap: () => selectCategory('Favoritos'),
          textColor: textColor,
        ),
      ],
    );
  }

  Widget _categoryButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Colors.cyan : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  //eventos de sticker
  Widget buildStickerGrid() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Expanded(
      child: FutureBuilder<List<Sticker>>(
        future: stickers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Lottie.asset(
                'lib/assets/loading/infinity_cyan.json',
                width: 40,
                height: 40,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.signal_wifi_off,
                    size: 50,
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                  ),
                  Text(
                    'Sin conexión a internet',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            );
          } else {
            final stickerList = snapshot.data ?? [];
            List<Sticker> displayedList;

            if (selectedCategory == 'Stickers') {
              displayedList = stickerList;
            } else if (selectedCategory == 'Favoritos') {
              displayedList = favoriteStickers;
            } else {
              displayedList = [];
            }

            // Verificar si hay conexión a Internet
            return FutureBuilder<bool>(
              future: checkInternetConnection(),
              builder: (context, connectionSnapshot) {
                if (connectionSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Lottie.asset(
                      'lib/assets/loading/infinity_cyan.json',
                      width: 40,
                      height: 40,
                    ),
                  );
                } else if (connectionSnapshot.data == false) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.signal_wifi_off,
                          size: 50,
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sin conexión a internet',
                          style: TextStyle(
                            fontSize: 18,
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (selectedCategory == 'Favoritos' && displayedList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.sadTear,
                          size: 50,
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No hay stickers en favoritos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (displayedList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.sadTear,
                          size: 50,
                          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Sticker no encontrado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.grey.shade800 : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: displayedList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Guardar en favoritos al seleccionar un sticker
                        if (selectedCategory == 'Stickers') {
                          dbHelper.insertFavorite(displayedList[index]);
                          Fluttertoast.showToast(
                            msg: 'Sticker guardado en favoritos',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.grey.shade800,
                            textColor: Colors.white,
                            fontSize: 13.0,
                          );
                        }
                      },
                      onLongPress: () {
                        // Mostrar cuadro de diálogo personalizado para eliminar sticker de favoritos
                        if (selectedCategory == 'Favoritos') {
                          showDeleteConfirmationDialog(
                            context,
                            displayedList[index],
                                () async {
                              // Acción de eliminar el sticker
                              await dbHelper.deleteFavorite(displayedList[index]);
                              setState(() {
                                favoriteStickers.remove(displayedList[index]);
                              });
                            },
                          );
                        }
                      },
                      child: CachedNetworkImage(
                        imageUrl: displayedList[index].url,
                        placeholder: (context, url) => Container(
                          alignment: Alignment.center,
                          child: Lottie.asset(
                            'lib/assets/loading/infinity_cyan.json',
                            width: 40,
                            height: 40,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.error,
                          color: iconColor,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  //dialogo de eliminar de favoritos
  void showDeleteConfirmationDialog(
    BuildContext context,
    Sticker sticker,
    Function onDelete,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final darkModeProvider =
          Provider.of<DarkModeProvider>(context, listen: false);
      final isDarkMode = darkModeProvider.isDarkMode;
      final textColor = darkModeProvider.textColor;

      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor:
              isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CachedNetworkImage(
                  imageUrl: sticker.url,
                  width: 140,
                  height: 140,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      Icon(Icons.error, color: Colors.red),
                ),
                SizedBox(height: 10),
                Text(
                  'Eliminar favorito',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '¿Estás seguro de que deseas eliminar \neste sticker de tus favoritos?',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDarkMode
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                            color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode
                            ? Colors.redAccent.shade700
                            : Colors.redAccent.shade200,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () async {
                        onDelete();
                        Navigator.of(context).pop();

                        Fluttertoast.showToast(
                          msg: "Sticker eliminado de favoritos",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.grey.shade800,
                          textColor: Colors.white,
                          fontSize: 11.0,
                        );
                      },
                      child: Text(
                        'Eliminar',
                        style: TextStyle(
                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
