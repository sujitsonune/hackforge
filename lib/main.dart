import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';

import 'app/app.dart';
import 'core/services/analytics_service.dart';
import 'core/constants/app_constants.dart';
// Import the generated file
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Analytics and Crashlytics
  await AnalyticsService.initialize();
  
  // Set up Crashlytics
  FlutterError.onError = (errorDetails) {
    AnalyticsService.recordFlutterError(errorDetails);
  };
  
  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    EasyLocalization(
      supportedLocales: AppConstants.supportedLanguages
          .map((lang) => Locale(lang))
          .toList(),
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const SubTrackerApp(),
    ),
  );
}
