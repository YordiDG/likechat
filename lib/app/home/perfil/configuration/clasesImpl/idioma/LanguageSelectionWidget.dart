import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'AppTranslations.dart';

class LanguageSelectionWidget extends StatelessWidget {
  // Método para obtener la bandera (usando SVG de ser posible)
  String _getCountryFlag(String languageCode) {
    // Mapeo de códigos de idioma a banderas
    final flagMap = {
      'en': 'assets/flags/us.svg',
      'zh': 'assets/flags/china.svg',
      'hi': 'assets/flags/india.svg',
      'es': 'assets/flags/spain.svg',
      'fr': 'assets/flags/france.svg',
      'ar': 'assets/flags/saudi_arabia.svg',
      'bn': 'assets/flags/bangladesh.svg',
      'ru': 'assets/flags/russia.svg',
      'pt': 'assets/flags/brazil.svg',
      'id': 'assets/flags/indonesia.svg'
    };
    return flagMap[languageCode] ?? 'assets/flags/default.svg';
  }

  @override
  Widget build(BuildContext context) {
    final localizationProvider = Provider.of<LocalizationProvider>(context);
    final currentLocale = localizationProvider.currentLocale;
    final availableLanguages = localizationProvider.getAvailableLanguages();
    final colorScheme = Theme.of(context).colorScheme;

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final iconColor = darkModeProvider.iconColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: iconColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Seleccionar Idioma',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surfaceVariant,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surfaceVariant.withOpacity(0.1),
              colorScheme.surfaceVariant.withOpacity(0.3)
            ],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          separatorBuilder: (context, index) => Divider(
            color: colorScheme.onSurface.withOpacity(0.1),
            indent: 70,
          ),
          itemCount: availableLanguages.length,
          itemBuilder: (context, index) {
            final language = availableLanguages[index];
            final isSelected = currentLocale.languageCode == language['code'];

            return OpenContainer(
              closedElevation: 0,
              openElevation: 16,
              closedBuilder: (context, openContainer) => ListTile(
                leading: SvgPicture.asset(
                  _getCountryFlag(language['code']),
                  width: 50,
                  height: 30,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  language['name'],
                  style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface
                  ),
                ),
                trailing: isSelected
                    ? Icon(
                    Icons.check_circle,
                    color: colorScheme.primary
                )
                    : null,
                onTap: () {
                  localizationProvider.changeLanguage(
                      Locale(language['code'])
                  );
                  Navigator.of(context).pop();
                },
              ),
              openBuilder: (context, closeContainer) => LanguageDetailsPage(
                languageCode: language['code'],
                languageName: language['name'],
              ),
            );
          },
        ),
      ),
    );
  }
}

// Página de detalles de idioma (opcional)
class LanguageDetailsPage extends StatelessWidget {
  final String languageCode;
  final String languageName;

  const LanguageDetailsPage({
    Key? key,
    required this.languageCode,
    required this.languageName
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$languageName Details'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/flags/${languageCode}_large.svg',
              width: 200,
              height: 120,
            ),
            SizedBox(height: 20),
            Text(
              languageName,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 10),
            Text(
              'Language Code: $languageCode',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}