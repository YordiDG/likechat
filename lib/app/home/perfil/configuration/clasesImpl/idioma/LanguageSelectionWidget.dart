import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import 'AppTranslations.dart';

class LanguageSelectionWidget extends StatelessWidget {
  String _getCountryFlag(String languageCode) {
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
    final darkModeProvider = Provider.of<DarkModeProvider>(context);

    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      child: Scaffold(
        backgroundColor: darkModeProvider.backgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: darkModeProvider.iconColor,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Seleccionar Idioma',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: fontSizeProvider.fontSize + 2,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Elige tu idioma preferido',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkModeProvider.iconColor,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final language = availableLanguages[index];
                    final isSelected = currentLocale.languageCode == language['code'];

                    return OpenContainer(
                      closedElevation: 0,
                      openElevation: 0,
                      transitionDuration: Duration(milliseconds: 400),
                      closedColor: darkModeProvider.backgroundColor,
                      openColor: darkModeProvider.backgroundColor,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      closedBuilder: (context, openContainer) => AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.withOpacity(0.2),
                            width: 2,
                          ),
                          gradient: isSelected
                              ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              Theme.of(context).colorScheme.primary.withOpacity(0.05),
                            ],
                          )
                              : null,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            localizationProvider.changeLanguage(Locale(language['code']));
                            Navigator.of(context).pop();
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Hero(
                                tag: 'flag_${language['code']}',
                                child: SvgPicture.asset(
                                  _getCountryFlag(language['code']),
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                language['name'],
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : darkModeProvider.iconColor,
                                ),
                              ),
                              if (isSelected) ...[
                                SizedBox(height: 4),
                                Icon(
                                  Icons.check_circle,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      openBuilder: (context, closeContainer) => LanguageDetailsPage(
                        languageCode: language['code'],
                        languageName: language['name'],
                      ),
                    );
                  },
                  childCount: availableLanguages.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LanguageDetailsPage extends StatelessWidget {
  final String languageCode;
  final String languageName;

  const LanguageDetailsPage({
    Key? key,
    required this.languageCode,
    required this.languageName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);

    return Scaffold(
      backgroundColor: darkModeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'flag_$languageCode',
                    child: SvgPicture.asset(
                      'assets/flags/${languageCode}_large.svg',
                      width: 200,
                      height: 120,
                    ),
                  ),
                  SizedBox(height: 32),
                  Text(
                    languageName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: darkModeProvider.iconColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      languageCode.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);
                localizationProvider.changeLanguage(Locale(languageCode));
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                'Seleccionar ${languageName}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}