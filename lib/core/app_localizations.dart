import 'package:flutter/widgets.dart';

import '../app/app_scope.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    final language = AppScope.of(context, listen: false).language;
    return AppLocalizations(_localeForLanguage(language));
  }

  static Locale _localeForLanguage(String language) {
    return switch (language) {
      'Somali' => const Locale('so'),
      'Arabic' => const Locale('ar'),
      'Chinese' => const Locale('zh'),
      'French' => const Locale('fr'),
      'Spanish' => const Locale('es'),
      'Turkish' => const Locale('tr'),
      'Swahili' => const Locale('sw'),
      'Hindi' => const Locale('hi'),
      'Portuguese' => const Locale('pt'),
      _ => const Locale('en'),
    };
  }

  String get languageCode => locale.languageCode;

  String text(String key) {
    return _translations[languageCode]?[key] ?? _translations['en']![key] ?? key;
  }

  static const _translations = <String, Map<String, String>>{
    'en': {
      'home': 'Home', 'products': 'Products', 'cart': 'Cart', 'orders': 'Orders',
      'profile': 'Profile', 'settings': 'Settings', 'logout': 'Logout',
      'users': 'Customers', 'cylinders': 'Products', 'drivers': 'Drivers',
      'stock': 'Stock', 'revenue': 'Revenue', 'reports': 'Reports',
      'assigned': 'Assigned', 'general': 'General', 'language': 'Language',
      'appearance': 'Appearance', 'notifications': 'Notifications',
      'privacy': 'Privacy', 'account': 'Account', 'pushNotifications': 'Push notifications',
      'offers': 'Offers and promotions', 'location': 'Location access',
      'analytics': 'Usage analytics', 'privacyPolicy': 'Privacy policy',
      'about': 'About Sahal Gas', 'english': 'English', 'somali': 'Somali',
      'arabic': 'Arabic', 'chinese': 'Chinese', 'french': 'French',
      'spanish': 'Spanish', 'turkish': 'Turkish', 'swahili': 'Swahili',
      'hindi': 'Hindi', 'portuguese': 'Portuguese', 'light': 'Light',
      'dark': 'Dark', 'close': 'Close',
    },
    'so': {
      'home': 'Hoyga', 'products': 'Alaabooyin', 'cart': 'Gaariga', 'orders': 'Dalabyo',
      'profile': 'Profile', 'settings': 'Dejinta', 'logout': 'Ka bax',
      'users': 'Macaamiil', 'cylinders': 'Alaabooyin', 'drivers': 'Darawallo',
      'stock': 'Kaydka', 'revenue': 'Dakhliga', 'reports': 'Warbixinno',
      'assigned': 'La xilsaaray', 'general': 'Guud', 'language': 'Luqad',
      'appearance': 'Muuqaal', 'notifications': 'Ogeysiisyo', 'privacy': 'Asturnaanta',
      'account': 'Akoon', 'pushNotifications': 'Ogeysiisyada app-ka',
      'offers': 'Dalabyo iyo xayeysiisyo', 'location': 'Goobta',
      'analytics': 'Falanqaynta isticmaalka', 'privacyPolicy': 'Siyaasadda asturnaanta',
      'about': 'Ku saabsan Sahal Gas', 'english': 'Ingiriisi', 'somali': 'Soomaali',
      'arabic': 'Carabi', 'chinese': 'Shiine', 'french': 'Faransiis',
      'spanish': 'Isbaanish', 'turkish': 'Turki', 'swahili': 'Sawaaxili',
      'hindi': 'Hindi', 'portuguese': 'Boortaqiis', 'light': 'Iftiin',
      'dark': 'Madow', 'close': 'Xir',
    },
    'ar': {
      'home': 'الرئيسية', 'products': 'المنتجات', 'cart': 'السلة', 'orders': 'الطلبات',
      'profile': 'الملف الشخصي', 'settings': 'الإعدادات', 'logout': 'تسجيل الخروج',
      'users': 'العملاء', 'cylinders': 'المنتجات', 'drivers': 'السائقون',
      'stock': 'المخزون', 'revenue': 'الإيرادات', 'reports': 'التقارير',
      'assigned': 'مُعيّن', 'general': 'عام', 'language': 'اللغة',
      'appearance': 'المظهر', 'notifications': 'الإشعارات', 'privacy': 'الخصوصية',
      'account': 'الحساب', 'pushNotifications': 'إشعارات الدفع',
      'offers': 'العروض والترويج', 'location': 'الوصول إلى الموقع',
      'analytics': 'تحليلات الاستخدام', 'privacyPolicy': 'سياسة الخصوصية',
      'about': 'عن Sahal Gas', 'light': 'فاتح', 'dark': 'داكن', 'close': 'إغلاق',
    },
    'zh': {
      'home': '首页', 'products': '产品', 'cart': '购物车', 'orders': '订单',
      'profile': '个人资料', 'settings': '设置', 'logout': '退出登录',
      'users': '客户', 'drivers': '司机', 'stock': '库存', 'revenue': '收入',
      'reports': '报告', 'assigned': '已分配', 'general': '常规', 'language': '语言',
      'appearance': '外观', 'notifications': '通知', 'privacy': '隐私',
      'account': '账户', 'pushNotifications': '推送通知', 'offers': '优惠和促销',
      'location': '位置访问', 'analytics': '使用分析', 'privacyPolicy': '隐私政策',
      'about': '关于 Sahal Gas', 'light': '浅色', 'dark': '深色', 'close': '关闭',
    },
    'fr': {'home': 'Accueil', 'products': 'Produits', 'cart': 'Panier', 'orders': 'Commandes', 'profile': 'Profil', 'settings': 'Paramètres', 'logout': 'Déconnexion', 'language': 'Langue', 'appearance': 'Apparence', 'notifications': 'Notifications', 'privacy': 'Confidentialité', 'account': 'Compte', 'light': 'Clair', 'dark': 'Sombre', 'close': 'Fermer'},
    'es': {'home': 'Inicio', 'products': 'Productos', 'cart': 'Carrito', 'orders': 'Pedidos', 'profile': 'Perfil', 'settings': 'Ajustes', 'logout': 'Cerrar sesión', 'language': 'Idioma', 'appearance': 'Apariencia', 'notifications': 'Notificaciones', 'privacy': 'Privacidad', 'account': 'Cuenta', 'light': 'Claro', 'dark': 'Oscuro', 'close': 'Cerrar'},
    'tr': {'home': 'Ana sayfa', 'products': 'Ürünler', 'cart': 'Sepet', 'orders': 'Siparişler', 'profile': 'Profil', 'settings': 'Ayarlar', 'logout': 'Çıkış', 'language': 'Dil', 'appearance': 'Görünüm', 'notifications': 'Bildirimler', 'privacy': 'Gizlilik', 'account': 'Hesap', 'light': 'Açık', 'dark': 'Koyu', 'close': 'Kapat'},
    'sw': {'home': 'Nyumbani', 'products': 'Bidhaa', 'cart': 'Kikapu', 'orders': 'Maagizo', 'profile': 'Wasifu', 'settings': 'Mipangilio', 'logout': 'Ondoka', 'language': 'Lugha', 'appearance': 'Mwonekano', 'notifications': 'Arifa', 'privacy': 'Faragha', 'account': 'Akaunti', 'light': 'Mwanga', 'dark': 'Giza', 'close': 'Funga'},
    'hi': {'home': 'होम', 'products': 'उत्पाद', 'cart': 'कार्ट', 'orders': 'ऑर्डर', 'profile': 'प्रोफ़ाइल', 'settings': 'सेटिंग्स', 'logout': 'लॉग आउट', 'language': 'भाषा', 'appearance': 'दिखावट', 'notifications': 'सूचनाएं', 'privacy': 'गोपनीयता', 'account': 'खाता', 'light': 'लाइट', 'dark': 'डार्क', 'close': 'बंद करें'},
    'pt': {'home': 'Início', 'products': 'Produtos', 'cart': 'Carrinho', 'orders': 'Pedidos', 'profile': 'Perfil', 'settings': 'Definições', 'logout': 'Sair', 'language': 'Idioma', 'appearance': 'Aparência', 'notifications': 'Notificações', 'privacy': 'Privacidade', 'account': 'Conta', 'light': 'Claro', 'dark': 'Escuro', 'close': 'Fechar'},
  };
}
