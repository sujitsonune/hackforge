import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/analytics_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _selectedColorScheme = 'default';
  bool _isLoading = false;

  static const String _themeModeKey = 'theme_mode';
  static const String _colorSchemeKey = 'color_scheme';

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get selectedColorScheme => _selectedColorScheme;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  ThemeProvider() {
    _loadThemePreferences();
  }

  Future<void> _loadThemePreferences() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeModeString = prefs.getString(_themeModeKey) ?? 'system';
      _themeMode = _parseThemeMode(themeModeString);
      
      // Load color scheme
      _selectedColorScheme = prefs.getString(_colorSchemeKey) ?? 'default';
      
    } catch (e) {
      // Use default values if loading fails
      _themeMode = ThemeMode.system;
      _selectedColorScheme = 'default';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode) return;

    final oldTheme = _getThemeModeString(_themeMode);
    final newTheme = _getThemeModeString(themeMode);
    
    _themeMode = themeMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, newTheme);
      
      // Log theme change analytics
      await AnalyticsService.logThemeChange(
        fromTheme: oldTheme,
        toTheme: newTheme,
      );
    } catch (e) {
      // Revert if saving fails
      _themeMode = _parseThemeMode(oldTheme);
      notifyListeners();
    }
  }

  Future<void> setColorScheme(String colorScheme) async {
    if (_selectedColorScheme == colorScheme) return;

    final oldScheme = _selectedColorScheme;
    _selectedColorScheme = colorScheme;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_colorSchemeKey, colorScheme);
      
      // Log color scheme change analytics
      await AnalyticsService.logEvent(
        'color_scheme_changed',
        parameters: {
          'from_scheme': oldScheme,
          'to_scheme': colorScheme,
        },
      );
    } catch (e) {
      // Revert if saving fails
      _selectedColorScheme = oldScheme;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    ThemeMode newMode;
    switch (_themeMode) {
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.system;
        break;
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
    }
    await setThemeMode(newMode);
  }

  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _getThemeModeString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
      default:
        return 'system';
    }
  }

  // Available color schemes
  static const Map<String, Map<String, dynamic>> availableColorSchemes = {
    'default': {
      'name': 'Default',
      'nameHi': 'डिफ़ॉल्ट',
      'primaryColor': 0xFFFF6B35,
      'description': 'Modern orange theme',
      'descriptionHi': 'आधुनिक नारंगी थीम',
    },
    'saffron': {
      'name': 'Saffron',
      'nameHi': 'केसरिया',
      'primaryColor': 0xFFFF9933,
      'description': 'Traditional saffron theme',
      'descriptionHi': 'पारंपरिक केसरिया थीम',
    },
    'tricolor': {
      'name': 'Tricolor',
      'nameHi': 'तिरंगा',
      'primaryColor': 0xFFFF6B35,
      'description': 'Indian flag inspired theme',
      'descriptionHi': 'भारतीय झंडे से प्रेरित थीम',
    },
    'green': {
      'name': 'Green',
      'nameHi': 'हरा',
      'primaryColor': 0xFF138808,
      'description': 'Nature green theme',
      'descriptionHi': 'प्रकृति हरी थीम',
    },
    'blue': {
      'name': 'Blue',
      'nameHi': 'नीला',
      'primaryColor': 0xFF2196F3,
      'description': 'Ocean blue theme',
      'descriptionHi': 'समुद्री नीली थीम',
    },
  };

  Map<String, dynamic>? getCurrentColorSchemeInfo() {
    return availableColorSchemes[_selectedColorScheme];
  }

  Color get primaryColor {
    final schemeInfo = getCurrentColorSchemeInfo();
    if (schemeInfo != null && schemeInfo['primaryColor'] != null) {
      return Color(schemeInfo['primaryColor'] as int);
    }
    return const Color(0xFFFF6B35); // Default color
  }

  String getColorSchemeName(String language) {
    final schemeInfo = availableColorSchemes[_selectedColorScheme];
    if (schemeInfo == null) return 'Default';
    
    if (language == 'hi' && schemeInfo['nameHi'] != null) {
      return schemeInfo['nameHi'] as String;
    }
    return schemeInfo['name'] as String;
  }

  String getColorSchemeDescription(String language) {
    final schemeInfo = availableColorSchemes[_selectedColorScheme];
    if (schemeInfo == null) return 'Default theme';
    
    if (language == 'hi' && schemeInfo['descriptionHi'] != null) {
      return schemeInfo['descriptionHi'] as String;
    }
    return schemeInfo['description'] as String;
  }

  // Reset to default theme
  Future<void> resetToDefault() async {
    await Future.wait([
      setThemeMode(ThemeMode.system),
      setColorScheme('default'),
    ]);
  }
}