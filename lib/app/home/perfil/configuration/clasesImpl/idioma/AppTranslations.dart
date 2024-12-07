import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppTranslations {
  final Locale locale;

  AppTranslations(this.locale);

  // Mapa de traducciones para 10 idiomas más hablados
  static final Map<String, Map<String, String>> _localizedValues = {
    // Inglés
    'en': {
      'home': 'Home',
      'profile': 'Profile',
      'messages': 'Messages',
      'settings': 'Settings',
      'login': 'Login',
      'logout': 'Logout',
      'welcome': 'Welcome to our Social App',
      'search': 'Search',
      'friends': 'Friends',
      'notifications': 'Notifications'
    },
    // Chino Mandarín
    'zh': {
      'home': '首页',
      'profile': '个人资料',
      'messages': '消息',
      'settings': '设置',
      'login': '登录',
      'logout': '退出登录',
      'welcome': '欢迎使用社交应用',
      'search': '搜索',
      'friends': '朋友',
      'notifications': '通知'
    },
    // Hindi
    'hi': {
      'home': 'होम',
      'profile': 'प्रोफ़ाइल',
      'messages': 'संदेश',
      'settings': 'सेटिंग्स',
      'login': 'लॉग इन',
      'logout': 'लॉग आउट',
      'welcome': 'हमारे सोशल ऐप में आपका स्वागत है',
      'search': 'खोजें',
      'friends': 'दोस्त',
      'notifications': 'सूचनाएं'
    },
    // Español
    'es': {
      'home': 'Inicio',
      'profile': 'Perfil',
      'messages': 'Mensajes',
      'settings': 'Configuración',
      'login': 'Iniciar Sesión',
      'logout': 'Cerrar Sesión',
      'welcome': 'Bienvenido a nuestra App Social',
      'search': 'Buscar',
      'friends': 'Amigos',
      'notifications': 'Notificaciones'
    },
    // Francés
    'fr': {
      'home': 'Accueil',
      'profile': 'Profil',
      'messages': 'Messages',
      'settings': 'Paramètres',
      'login': 'Connexion',
      'logout': 'Déconnexion',
      'welcome': 'Bienvenue sur notre application sociale',
      'search': 'Rechercher',
      'friends': 'Amis',
      'notifications': 'Notifications'
    },
    // Árabe
    'ar': {
      'home': 'الصفحة الرئيسية',
      'profile': 'الملف الشخصي',
      'messages': 'الرسائل',
      'settings': 'الإعدادات',
      'login': 'تسجيل الدخول',
      'logout': 'تسجيل الخروج',
      'welcome': 'مرحباً بك في تطبيقنا الاجتماعي',
      'search': 'بحث',
      'friends': 'أصدقاء',
      'notifications': 'إشعارات'
    },
    // Bengalí
    'bn': {
      'home': 'হোম',
      'profile': 'প্রোফাইল',
      'messages': 'বার্তা',
      'settings': 'সেটিংস',
      'login': 'লগ ইন',
      'logout': 'লগ আউট',
      'welcome': 'আমাদের সোশ্যাল অ্যাপে স্বাগতম',
      'search': 'অনুসন্ধান',
      'friends': 'বন্ধুরা',
      'notifications': 'বিজ্ঞপ্তি'
    },
    // Ruso
    'ru': {
      'home': 'Главная',
      'profile': 'Профиль',
      'messages': 'Сообщения',
      'settings': 'Настройки',
      'login': 'Войти',
      'logout': 'Выйти',
      'welcome': 'Добро пожаловать в наше социальное приложение',
      'search': 'Поиск',
      'friends': 'Друзья',
      'notifications': 'Уведомления'
    },
    // Portugués
    'pt': {
      'home': 'Início',
      'profile': 'Perfil',
      'messages': 'Mensagens',
      'settings': 'Configurações',
      'login': 'Entrar',
      'logout': 'Sair',
      'welcome': 'Bem-vindo ao nosso aplicativo social',
      'search': 'Pesquisar',
      'friends': 'Amigos',
      'notifications': 'Notificações'
    },
    // Indonesio
    'id': {
      'home': 'Beranda',
      'profile': 'Profil',
      'messages': 'Pesan',
      'settings': 'Pengaturan',
      'login': 'Masuk',
      'logout': 'Keluar',
      'welcome': 'Selamat datang di aplikasi sosial kami',
      'search': 'Cari',
      'friends': 'Teman',
      'notifications': 'Pemberitahuan'
    }
  };

  // Método para obtener traducción
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Lista de locales soportados
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),  // Inglés
    Locale('zh', 'CN'),  // Chino
    Locale('hi', 'IN'),  // Hindi
    Locale('es', 'ES'),  // Español
    Locale('fr', 'FR'),  // Francés
    Locale('ar', 'SA'),  // Árabe
    Locale('bn', 'BD'),  // Bengalí
    Locale('ru', 'RU'),  // Ruso
    Locale('pt', 'BR'),  // Portugués
    Locale('id', 'ID'),  // Indonesio
  ];
}

// Provider de Localización
class LocalizationProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');

  Locale get currentLocale => _currentLocale;

  // Cambiar idioma
  void changeLanguage(Locale newLocale) {
    if (!AppTranslations.supportedLocales.contains(newLocale)) {
      return;
    }
    _currentLocale = newLocale;
    notifyListeners();
  }

  // Obtener traducción
  String translate(String key) {
    return AppTranslations(_currentLocale).translate(key);
  }

  // Método para obtener nombre del idioma
  String getLanguageName(Locale locale) {
    final languageNames = {
      'en': 'English',
      'zh': '中文 (Chinese)',
      'hi': 'हिन्दी (Hindi)',
      'es': 'Español (Spanish)',
      'fr': 'Français (French)',
      'ar': 'العربية (Arabic)',
      'bn': 'বাংলা (Bengali)',
      'ru': 'Русский (Russian)',
      'pt': 'Português (Portuguese)',
      'id': 'Bahasa Indonesia (Indonesian)'
    };
    return languageNames[locale.languageCode] ?? locale.languageCode;
  }

  // Método para obtener todos los idiomas disponibles
  List<Map<String, dynamic>> getAvailableLanguages() {
    return AppTranslations.supportedLocales.map((locale) {
      return {
        'code': locale.languageCode,
        'name': getLanguageName(locale)
      };
    }).toList();
  }
}

// Delegado de localización personalizado
class AppLocalizationDelegate extends LocalizationsDelegate<AppTranslations> {
  const AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppTranslations.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppTranslations> load(Locale locale) async {
    return AppTranslations(locale);
  }

  @override
  bool shouldReload(AppLocalizationDelegate old) => false;
}

// Extensión para acceder fácilmente a traducciones
extension TranslationExtension on BuildContext {
  String translate(String key) {
    return Provider.of<LocalizationProvider>(this, listen: false).translate(key);
  }
}