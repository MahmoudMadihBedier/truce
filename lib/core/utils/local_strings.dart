class LocalStrings {
  static const Map<String, Map<String, String>> values = {
    'en': {
      'app_title': 'Truce Egypt',
      'search_hint': 'Search products...',
      'price_drops': 'Price Drops',
      'market_products': 'Market Products',
      'lowest': 'Lowest',
      'at': 'at',
      'login': 'Login',
      'signup': 'Sign Up',
      'guest': 'Continue as Guest',
      'gold': 'Gold',
      'usd_egp': 'USD/EGP',
      'settings': 'Settings',
      'theme': 'Appearance',
      'language': 'Language',
      'account': 'Account',
      'logout': 'Log Out',
      'dark_mode': 'Dark Mode',
      'light_mode': 'Light Mode',
      'en_lang': 'English',
      'ar_lang': 'Arabic',
      'guest_mode': 'You are browsing as Guest',
    },
    'ar': {
      'app_title': 'تروس مصر',
      'search_hint': 'ابحث عن المنتجات...',
      'price_drops': 'انخفاض الأسعار',
      'market_products': 'منتجات السوق',
      'lowest': 'أقل سعر',
      'at': 'في',
      'login': 'تسجيل الدخول',
      'signup': 'إنشاء حساب',
      'guest': 'المتابعة كضيف',
      'gold': 'الذهب',
      'usd_egp': 'الدولار/الجنية',
      'settings': 'الإعدادات',
      'theme': 'المظهر',
      'language': 'اللغة',
      'account': 'الحساب',
      'logout': 'تسجيل الخروج',
      'dark_mode': 'الوضع الداكن',
      'light_mode': 'الوضع الفاتح',
      'en_lang': 'الإنجليزية',
      'ar_lang': 'العربية',
      'guest_mode': 'أنت تتصفح كضيف',
    },
  };

  static String get(String key, String locale) {
    return values[locale]?[key] ?? key;
  }
}
