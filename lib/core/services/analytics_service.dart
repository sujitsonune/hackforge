import 'package:flutter/foundation.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../constants/app_constants.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Initialize analytics
  static Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
    await _crashlytics.setCrashlyticsCollectionEnabled(true);
  }

  // User identification
  static Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
    await _crashlytics.setUserIdentifier(userId);
  }

  static Future<void> setUserProperties({
    String? language,
    String? currency,
    String? theme,
    bool? isPremium,
    bool? inFamilyGroup,
  }) async {
    if (language != null) {
      await _analytics.setUserProperty(
        name: AnalyticsConstants.userProperties['user_language']!,
        value: language,
      );
    }
    if (currency != null) {
      await _analytics.setUserProperty(
        name: AnalyticsConstants.userProperties['user_currency']!,
        value: currency,
      );
    }
    if (theme != null) {
      await _analytics.setUserProperty(
        name: AnalyticsConstants.userProperties['user_theme']!,
        value: theme,
      );
    }
    if (isPremium != null) {
      await _analytics.setUserProperty(
        name: AnalyticsConstants.userProperties['user_premium']!,
        value: isPremium.toString(),
      );
    }
    if (inFamilyGroup != null) {
      await _analytics.setUserProperty(
        name: AnalyticsConstants.userProperties['user_family_member']!,
        value: inFamilyGroup.toString(),
      );
    }
  }

  // Custom events
  static Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    Map<String, Object?> analyticsParameters = {};
    
    if (parameters != null) {
      for (var entry in parameters.entries) {
        analyticsParameters[entry.key] = entry.value?.toString();
      }
    }

    await _analytics.logEvent(
      name: eventName,
      parameters: analyticsParameters,
    );
  }

  // App lifecycle events
  static Future<void> logAppOpen() async {
    await logEvent(AnalyticsConstants.eventAppOpen);
  }

  // Authentication events
  static Future<void> logUserSignup(String method, {String? userId}) async {
    await logEvent(
      AnalyticsConstants.eventUserSignup,
      parameters: {
        'method': method,
        if (userId != null) 'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logUserLogin(String method, {String? userId}) async {
    await logEvent(
      AnalyticsConstants.eventUserLogin,
      parameters: {
        'method': method,
        if (userId != null) 'user_id': userId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Subscription events
  static Future<void> logSubscriptionAdd({
    required String subscriptionName,
    required String category,
    required double cost,
    required String billingCycle,
    String? paymentMethod,
  }) async {
    await logEvent(
      AnalyticsConstants.eventSubscriptionAdd,
      parameters: {
        'subscription_name': subscriptionName,
        'category': category,
        'cost': cost,
        'billing_cycle': billingCycle,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logSubscriptionEdit({
    required String subscriptionName,
    required String category,
    String? changeType,
  }) async {
    await logEvent(
      AnalyticsConstants.eventSubscriptionEdit,
      parameters: {
        'subscription_name': subscriptionName,
        'category': category,
        if (changeType != null) 'change_type': changeType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logSubscriptionDelete({
    required String subscriptionName,
    required String category,
    required String reason,
  }) async {
    await logEvent(
      AnalyticsConstants.eventSubscriptionDelete,
      parameters: {
        'subscription_name': subscriptionName,
        'category': category,
        'reason': reason,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Notification events
  static Future<void> logNotificationSent({
    required String notificationType,
    required String subscriptionName,
    int? daysBeforeRenewal,
  }) async {
    await logEvent(
      AnalyticsConstants.eventNotificationSent,
      parameters: {
        'notification_type': notificationType,
        'subscription_name': subscriptionName,
        if (daysBeforeRenewal != null) 'days_before_renewal': daysBeforeRenewal,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logNotificationOpened({
    required String notificationType,
    required String subscriptionName,
    String? action,
  }) async {
    await logEvent(
      AnalyticsConstants.eventNotificationOpened,
      parameters: {
        'notification_type': notificationType,
        'subscription_name': subscriptionName,
        if (action != null) 'action': action,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Family group events
  static Future<void> logFamilyGroupCreate({
    required String groupName,
    required int memberCount,
  }) async {
    await logEvent(
      AnalyticsConstants.eventFamilyGroupCreate,
      parameters: {
        'group_name': groupName,
        'member_count': memberCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logFamilyGroupJoin({
    required String groupName,
    required String role,
  }) async {
    await logEvent(
      AnalyticsConstants.eventFamilyGroupJoin,
      parameters: {
        'group_name': groupName,
        'role': role,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // User behavior events
  static Future<void> logLanguageChange({
    required String fromLanguage,
    required String toLanguage,
  }) async {
    await logEvent(
      AnalyticsConstants.eventLanguageChange,
      parameters: {
        'from_language': fromLanguage,
        'to_language': toLanguage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logThemeChange({
    required String fromTheme,
    required String toTheme,
  }) async {
    await logEvent(
      AnalyticsConstants.eventThemeChange,
      parameters: {
        'from_theme': fromTheme,
        'to_theme': toTheme,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Feature usage events
  static Future<void> logExportData({
    required String format,
    required int subscriptionCount,
  }) async {
    await logEvent(
      AnalyticsConstants.eventExportData,
      parameters: {
        'format': format,
        'subscription_count': subscriptionCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logShareApp({
    required String method,
    String? content,
  }) async {
    await logEvent(
      AnalyticsConstants.eventShareApp,
      parameters: {
        'method': method,
        if (content != null) 'content': content,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logRateApp({
    required int rating,
    String? feedback,
  }) async {
    await logEvent(
      AnalyticsConstants.eventRateApp,
      parameters: {
        'rating': rating,
        if (feedback != null) 'feedback': feedback,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logSupportContact({
    required String channel,
    required String category,
  }) async {
    await logEvent(
      AnalyticsConstants.eventSupportContact,
      parameters: {
        'channel': channel,
        'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Screen tracking
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  // Purchase events (for premium features)
  static Future<void> logPurchase({
    required String transactionId,
    required String currency,
    required double value,
    required String itemName,
  }) async {
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      transactionId: transactionId,
      parameters: {
        'item_name': itemName,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Custom metrics for Indian context
  static Future<void> logIndianFestivalEngagement({
    required String festivalName,
    required String action,
    String? offerType,
  }) async {
    await logEvent(
      'indian_festival_engagement',
      parameters: {
        'festival_name': festivalName,
        'action': action,
        if (offerType != null) 'offer_type': offerType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logOTTPlatformInteraction({
    required String platformName,
    required String action,
    String? category,
  }) async {
    await logEvent(
      'ott_platform_interaction',
      parameters: {
        'platform_name': platformName,
        'action': action,
        if (category != null) 'category': category,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logPaymentMethodSelection({
    required String paymentMethod,
    required String context,
  }) async {
    await logEvent(
      'payment_method_selection',
      parameters: {
        'payment_method': paymentMethod,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // Error and crash logging
  static Future<void> logError({
    required String error,
    required String context,
    Map<String, dynamic>? additionalData,
  }) async {
    await _crashlytics.log('Error in $context: $error');
    
    if (additionalData != null) {
      for (var entry in additionalData.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value?.toString() ?? 'null');
      }
    }
    
    await _crashlytics.recordError(
      Exception(error),
      StackTrace.current,
      reason: context,
      fatal: false,
    );
  }

  static Future<void> recordFlutterError(FlutterErrorDetails errorDetails) async {
    await _crashlytics.recordFlutterFatalError(errorDetails);
  }

  // Performance monitoring
  static Future<void> logPerformance({
    required String operationName,
    required Duration duration,
    bool? success,
    String? errorMessage,
  }) async {
    await logEvent(
      'performance_metric',
      parameters: {
        'operation_name': operationName,
        'duration_ms': duration.inMilliseconds,
        if (success != null) 'success': success,
        if (errorMessage != null) 'error_message': errorMessage,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // User engagement metrics
  static Future<void> logSessionDuration(Duration sessionDuration) async {
    await logEvent(
      'session_duration',
      parameters: {
        'duration_minutes': sessionDuration.inMinutes,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logFeatureUsage({
    required String featureName,
    int? usageCount,
    Map<String, dynamic>? metadata,
  }) async {
    Map<String, dynamic> parameters = {
      'feature_name': featureName,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    if (usageCount != null) {
      parameters['usage_count'] = usageCount;
    }
    
    if (metadata != null) {
      parameters.addAll(metadata);
    }
    
    await logEvent('feature_usage', parameters: parameters);
  }
}