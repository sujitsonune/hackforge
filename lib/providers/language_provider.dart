import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/analytics_service.dart';
import '../core/constants/app_constants.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('hi'); // Default to Hindi
  bool _isLoading = false;

  static const String _languageKey = 'selected_language';

  // Getters
  Locale get currentLocale => _currentLocale;
  String get currentLanguageCode => _currentLocale.languageCode;
  bool get isLoading => _isLoading;
  bool get isHindi => _currentLocale.languageCode == 'hi';
  bool get isEnglish => _currentLocale.languageCode == 'en';

  LanguageProvider() {
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? 'hi';
      
      if (AppConstants.supportedLanguages.contains(languageCode)) {
        _currentLocale = Locale(languageCode);
      } else {
        _currentLocale = const Locale('hi');
      }
    } catch (e) {
      _currentLocale = const Locale('hi');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setLanguage(String languageCode) async {
    if (!AppConstants.supportedLanguages.contains(languageCode)) {
      throw ArgumentError('Unsupported language: $languageCode');
    }

    if (_currentLocale.languageCode == languageCode) return;

    final oldLanguage = _currentLocale.languageCode;
    _currentLocale = Locale(languageCode);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      
      // Log language change analytics
      await AnalyticsService.logLanguageChange(
        fromLanguage: oldLanguage,
        toLanguage: languageCode,
      );
      
      // Set user property for analytics
      await AnalyticsService.setUserProperties(language: languageCode);
    } catch (e) {
      // Revert if saving fails
      _currentLocale = Locale(oldLanguage);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setHindi() async {
    await setLanguage('hi');
  }

  Future<void> setEnglish() async {
    await setLanguage('en');
  }

  Future<void> setTamil() async {
    await setLanguage('ta');
  }

  Future<void> setTelugu() async {
    await setLanguage('te');
  }

  Future<void> setBengali() async {
    await setLanguage('bn');
  }

  Future<void> setGujarati() async {
    await setLanguage('gu');
  }

  Future<void> setMarathi() async {
    await setLanguage('mr');
  }

  Future<void> setKannada() async {
    await setLanguage('kn');
  }

  Future<void> setPunjabi() async {
    await setLanguage('pa');
  }

  Future<void> setOdia() async {
    await setLanguage('or');
  }

  String getLanguageName(String? languageCode) {
    final code = languageCode ?? _currentLocale.languageCode;
    return AppConstants.languageNames[code] ?? 'Unknown';
  }

  String getCurrentLanguageName() {
    return getLanguageName(_currentLocale.languageCode);
  }

  List<Map<String, String>> getSupportedLanguages() {
    return AppConstants.supportedLanguages.map((code) {
      return {
        'code': code,
        'name': AppConstants.languageNames[code] ?? code,
        'nativeName': AppConstants.languageNames[code] ?? code,
      };
    }).toList();
  }

  bool isRTL() {
    // Add RTL languages if needed in future
    // Currently all supported Indian languages are LTR
    return false;
  }

  String getDirectionality() {
    return isRTL() ? 'rtl' : 'ltr';
  }

  // Get localized text based on current language
  String getLocalizedText(Map<String, String> textMap) {
    final text = textMap[_currentLocale.languageCode];
    if (text != null && text.isNotEmpty) {
      return text;
    }
    
    // Fallback to English
    final englishText = textMap['en'];
    if (englishText != null && englishText.isNotEmpty) {
      return englishText;
    }
    
    // Fallback to Hindi
    final hindiText = textMap['hi'];
    if (hindiText != null && hindiText.isNotEmpty) {
      return hindiText;
    }
    
    // Last fallback to any available text
    return textMap.values.firstWhere(
      (value) => value.isNotEmpty,
      orElse: () => 'Text not available',
    );
  }

  // Check if current language uses Devanagari script
  bool usesDevanagariScript() {
    return ['hi', 'mr', 'ne'].contains(_currentLocale.languageCode);
  }

  // Check if current language is an Indian language
  bool isIndianLanguage() {
    return AppConstants.supportedLanguages.contains(_currentLocale.languageCode);
  }

  // Get appropriate font family based on current language
  String getFontFamily() {
    switch (_currentLocale.languageCode) {
      case 'hi':
      case 'mr':
        return 'Noto Sans Devanagari';
      case 'ta':
        return 'Noto Sans Tamil';
      case 'te':
        return 'Noto Sans Telugu';
      case 'bn':
        return 'Noto Sans Bengali';
      case 'gu':
        return 'Noto Sans Gujarati';
      case 'kn':
        return 'Noto Sans Kannada';
      case 'pa':
        return 'Noto Sans Gurmukhi';
      case 'or':
        return 'Noto Sans Oriya';
      default:
        return 'Noto Sans';
    }
  }

  // Language-specific formatting helpers
  String formatNumber(int number) {
    // Indian number formatting (lac, crore system)
    if (_currentLocale.languageCode == 'hi') {
      if (number < 100000) {
        return number.toString();
      } else if (number < 10000000) {
        return '${(number / 100000).toStringAsFixed(1)} लाख';
      } else {
        return '${(number / 10000000).toStringAsFixed(1)} करोड़';
      }
    } else {
      // English formatting
      if (number < 1000) {
        return number.toString();
      } else if (number < 100000) {
        return '${(number / 1000).toStringAsFixed(1)}K';
      } else if (number < 10000000) {
        return '${(number / 100000).toStringAsFixed(1)}L';
      } else {
        return '${(number / 10000000).toStringAsFixed(1)}Cr';
      }
    }
  }

  String formatCurrency(double amount) {
    if (_currentLocale.languageCode == 'hi') {
      return '₹${amount.toStringAsFixed(0)}';
    } else {
      return '₹${amount.toStringAsFixed(0)}';
    }
  }

  // Get greeting based on time and language
  String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    
    if (_currentLocale.languageCode == 'hi') {
      if (hour < 12) {
        return 'सुप्रभात'; // Good morning
      } else if (hour < 17) {
        return 'नमस्कार'; // Good afternoon
      } else {
        return 'शुभ संध्या'; // Good evening
      }
    } else {
      if (hour < 12) {
        return 'Good Morning';
      } else if (hour < 17) {
        return 'Good Afternoon';
      } else {
        return 'Good Evening';
      }
    }
  }

  // Regional preferences
  Map<String, dynamic> getRegionalPreferences() {
    switch (_currentLocale.languageCode) {
      case 'hi':
        return {
          'dateFormat': 'dd/MM/yyyy',
          'timeFormat': '24h',
          'firstDayOfWeek': 1, // Monday
          'currency': 'INR',
          'numberFormat': 'indian',
        };
      case 'ta':
        return {
          'dateFormat': 'dd/MM/yyyy',
          'timeFormat': '12h',
          'firstDayOfWeek': 1,
          'currency': 'INR',
          'numberFormat': 'indian',
        };
      default:
        return {
          'dateFormat': 'MM/dd/yyyy',
          'timeFormat': '12h',
          'firstDayOfWeek': 0, // Sunday
          'currency': 'INR',
          'numberFormat': 'western',
        };
    }
  }

  // Toggle between Hindi and English (most common use case)
  Future<void> toggleHindiEnglish() async {
    if (_currentLocale.languageCode == 'hi') {
      await setEnglish();
    } else {
      await setHindi();
    }
  }

  // Reset to default language (Hindi for Indian users)
  Future<void> resetToDefault() async {
    await setLanguage('hi');
  }
}