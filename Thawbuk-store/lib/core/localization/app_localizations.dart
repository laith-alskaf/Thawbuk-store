import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('assets/lang/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap;
    return true;
  }

  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;
    
    for (String k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // إرجاع المفتاح إذا لم يتم العثور على الترجمة
      }
    }
    
    return value?.toString() ?? key;
  }

  // اختصارات للترجمات الشائعة
  String get appName => translate('app.name');
  String get loading => translate('common.loading');
  String get error => translate('common.error');
  String get success => translate('common.success');
  String get cancel => translate('common.cancel');
  String get confirm => translate('common.confirm');
  String get save => translate('common.save');
  String get retry => translate('common.retry');
  String get noData => translate('common.no_data');
  String get noInternet => translate('common.no_internet');
  String get somethingWentWrong => translate('common.something_went_wrong');

  // المصادقة
  String get login => translate('auth.login');
  String get register => translate('auth.register');
  String get logout => translate('auth.logout');
  String get email => translate('auth.email');
  String get password => translate('auth.password');
  String get confirmPassword => translate('auth.confirm_password');
  String get name => translate('auth.name');
  String get forgotPassword => translate('auth.forgot_password');
  String get dontHaveAccount => translate('auth.dont_have_account');
  String get alreadyHaveAccount => translate('auth.already_have_account');
  String get welcomeBack => translate('auth.welcome_back');
  String get welcome => translate('auth.welcome');
  String get loginSubtitle => translate('auth.login_to_account');
  String get emailHint => translate('auth.email');
  String get passwordHint => translate('auth.password');
  String get rememberMe => translate('auth.remember_me');
  String get signUp => translate('auth.create_account');
  String get continueAsGuest => 'المتابعة كضيف';
  String get or => 'أو';

  // التحقق من صحة البيانات
  String get required => translate('validation.required');
  String get invalidEmail => translate('validation.invalid_email');
  String get passwordTooShort => translate('validation.password_too_short');
  String get passwordsDontMatch => translate('validation.passwords_dont_match');
  String get emailRequired => translate('validation.required');
  String get emailInvalid => translate('validation.invalid_email');
  String get passwordRequired => translate('validation.required');

  // المنتجات
  String get products => translate('products.title');
  String get addToCart => translate('products.add_to_cart');
  String get addToWishlist => translate('products.add_to_wishlist');
  String get outOfStock => translate('products.out_of_stock');
  String get inStock => translate('products.in_stock');

  // السلة
  String get cart => translate('cart.title');
  String get emptyCart => translate('cart.empty_cart');
  String get checkout => translate('cart.checkout');
  String get continueShopping => translate('cart.continue_shopping');

  // المفضلة
  String get wishlist => translate('wishlist.title');
  String get emptyWishlist => translate('wishlist.empty_wishlist');

  // التنقل
  String get home => translate('navigation.home');
  String get categories => translate('navigation.categories');
  String get profile => translate('navigation.profile');
  String get orders => translate('navigation.orders');

  // شاشة البداية
  String get splashLoading => translate('splash.loading');
  String get splashWelcome => translate('splash.welcome');

  // الأخطاء
  String get networkError => translate('errors.network_error');
  String get serverError => translate('errors.server_error');
  String get unknownError => translate('errors.unknown_error');
  String get timeoutError => translate('errors.timeout_error');
  String get unauthorized => translate('errors.unauthorized');
  String get tryAgain => translate('errors.try_again');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ar', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension لسهولة الاستخدام
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}