class AppConstants {
  static const String appName = 'SubTracker Pro India';
  static const String appVersion = '1.0.0';
  static const String packageName = 'com.subtracker.india';

  static const String defaultCurrency = 'INR';
  static const String defaultLanguage = 'hi';
  static const List<String> supportedLanguages = [
    'en',
    'hi',
    'ta',
    'te',
    'bn',
    'gu',
    'mr',
    'kn',
    'pa',
    'or'
  ];

  static const Map<String, String> languageNames = {
    'en': 'English',
    'hi': 'हिंदी',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'bn': 'বাংলা',
    'gu': 'ગુજરાતી',
    'mr': 'मराठी',
    'kn': 'ಕನ್ನಡ',
    'pa': 'ਪੰਜਾਬੀ',
    'or': 'ଓଡ଼ିଆ'
  };

  static const List<int> defaultReminderDays = [7, 3, 1];
  static const int maxFamilyMembers = 6;
  static const int maxSubscriptionsPerUser = 100;
  static const int maxNotificationsPerUser = 1000;

  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration cacheExpiry = Duration(hours: 1);
  static const Duration notificationScheduleBuffer = Duration(hours: 1);

  static const double maxSubscriptionCost = 100000.0;
  static const double minSubscriptionCost = 1.0;

  static const String defaultAvatarUrl = 'assets/images/default_avatar.png';
  static const String defaultSubscriptionIcon = 'assets/images/default_subscription.png';

  static const Map<String, String> socialMediaLinks = {
    'privacy': 'https://subtrackerpro.in/privacy',
    'terms': 'https://subtrackerpro.in/terms',
    'support': 'https://subtrackerpro.in/support',
    'feedback': 'https://subtrackerpro.in/feedback',
    'playstore': 'https://play.google.com/store/apps/details?id=com.subtracker.india'
  };

  static const Map<String, String> supportChannels = {
    'email': 'support@subtrackerpro.in',
    'whatsapp': '+91-9876543210',
    'telegram': 'https://t.me/subtrackerindia'
  };
}

class FirebaseConstants {
  static const String usersCollection = 'users';
  static const String subscriptionsCollection = 'subscriptions';
  static const String notificationsCollection = 'notifications';
  static const String familyGroupsCollection = 'family_groups';
  static const String categoriesCollection = 'categories';
  static const String feedbackCollection = 'feedback';
  static const String analyticsCollection = 'analytics';

  static const String fcmTopic = 'all_users';
  static const String fcmTopicIndia = 'india_users';
  
  static const Map<String, String> fcmTopicsByLanguage = {
    'hi': 'hindi_users',
    'en': 'english_users',
    'ta': 'tamil_users',
    'te': 'telugu_users',
    'bn': 'bengali_users',
    'gu': 'gujarati_users',
    'mr': 'marathi_users',
    'kn': 'kannada_users'
  };

  static const Map<String, String> notificationChannels = {
    'reminders': 'subscription_reminders',
    'renewals': 'subscription_renewals',
    'family': 'family_notifications',
    'offers': 'special_offers',
    'updates': 'app_updates'
  };

  static const int firestoreTimeoutSeconds = 30;
  static const int batchSize = 500;
  static const int maxRetries = 3;
}

class ThemeConstants {
  static const String fontFamilyEnglish = 'Noto Sans';
  static const String fontFamilyHindi = 'Noto Sans Devanagari';
  
  static const Map<String, String> fontFamilyByLanguage = {
    'en': 'Noto Sans',
    'hi': 'Noto Sans Devanagari',
    'ta': 'Noto Sans Tamil',
    'te': 'Noto Sans Telugu',
    'bn': 'Noto Sans Bengali',
    'gu': 'Noto Sans Gujarati',
    'mr': 'Noto Sans Devanagari',
    'kn': 'Noto Sans Kannada'
  };

  static const Map<String, String> primaryColors = {
    'default': '#FF6B35',
    'saffron': '#FF9933',
    'green': '#138808',
    'blue': '#000080',
    'purple': '#800080'
  };
}

class ValidationConstants {
  static const int minNameLength = 2;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  
  static const String phoneRegex = r'^[6-9]\d{9}$';
  static const String emailRegex = r'^[^\s@]+@[^\s@]+\.[^\s@]+$';
  
  static const int otpLength = 6;
  static const Duration otpValidityDuration = Duration(minutes: 5);
  static const int maxOtpAttempts = 3;

  static const List<String> commonPasswords = [
    '123456',
    'password',
    '123456789',
    '12345678',
    '12345',
    '1234567',
    '1234567890',
    'qwerty',
    'abc123',
    '111111'
  ];
}

class AnalyticsConstants {
  static const String eventAppOpen = 'app_open';
  static const String eventUserSignup = 'user_signup';
  static const String eventUserLogin = 'user_login';
  static const String eventSubscriptionAdd = 'subscription_add';
  static const String eventSubscriptionEdit = 'subscription_edit';
  static const String eventSubscriptionDelete = 'subscription_delete';
  static const String eventNotificationSent = 'notification_sent';
  static const String eventNotificationOpened = 'notification_opened';
  static const String eventFamilyGroupCreate = 'family_group_create';
  static const String eventFamilyGroupJoin = 'family_group_join';
  static const String eventLanguageChange = 'language_change';
  static const String eventThemeChange = 'theme_change';
  static const String eventExportData = 'export_data';
  static const String eventShareApp = 'share_app';
  static const String eventRateApp = 'rate_app';
  static const String eventSupportContact = 'support_contact';

  static const Map<String, String> userProperties = {
    'user_language': 'language',
    'user_currency': 'currency',
    'user_theme': 'theme',
    'user_premium': 'is_premium',
    'user_family_member': 'in_family_group'
  };
}

class ErrorMessages {
  static const Map<String, Map<String, String>> messages = {
    'network': {
      'en': 'Network error. Please check your internet connection.',
      'hi': 'नेटवर्क त्रुटि। कृपया अपना इंटरनेट कनेक्शन जांचें।'
    },
    'auth_failed': {
      'en': 'Authentication failed. Please try again.',
      'hi': 'प्रमाणीकरण विफल। कृपया पुनः प्रयास करें।'
    },
    'invalid_phone': {
      'en': 'Invalid phone number. Please enter a valid Indian mobile number.',
      'hi': 'अमान्य फोन नंबर। कृपया एक वैध भारतीय मोबाइल नंबर दर्ज करें।'
    },
    'invalid_otp': {
      'en': 'Invalid OTP. Please check and try again.',
      'hi': 'अमान्य ओटीपी। कृपया जांचें और पुनः प्रयास करें।'
    },
    'subscription_limit': {
      'en': 'You have reached the maximum subscription limit.',
      'hi': 'आपने अधिकतम सब्स्क्रिप्शन सीमा पहुंच ली है।'
    },
    'family_limit': {
      'en': 'Maximum family members limit reached.',
      'hi': 'अधिकतम पारिवारिक सदस्य सीमा पहुंच गई है।'
    },
    'permission_denied': {
      'en': 'Permission denied. Please grant necessary permissions.',
      'hi': 'अनुमति अस्वीकृत। कृपया आवश्यक अनुमतियां प्रदान करें।'
    },
    'data_not_found': {
      'en': 'Data not found.',
      'hi': 'डेटा नहीं मिला।'
    },
    'something_went_wrong': {
      'en': 'Something went wrong. Please try again.',
      'hi': 'कुछ गलत हुआ। कृपया पुनः प्रयास करें।'
    }
  };

  static String getMessage(String key, String language) {
    return messages[key]?[language] ?? messages[key]?['en'] ?? 'Unknown error';
  }
}