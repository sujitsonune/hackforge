import 'package:flutter/material.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/subscriptions/screens/subscriptions_screen.dart';
import '../features/subscriptions/screens/add_subscription_screen.dart';

class AppRoutes {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Route names
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String subscriptions = '/subscriptions';
  static const String addSubscription = '/add-subscription';
  static const String subscriptionDetails = '/subscription-details';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String family = '/family';
  static const String analytics = '/analytics';

  // Route definitions
  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    dashboard: (context) => const DashboardScreen(),
    subscriptions: (context) => const SubscriptionsScreen(),
    addSubscription: (context) => const AddSubscriptionScreen(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
          settings: settings,
        );
    }
  }

  // Navigation helpers
  static Future<void> pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  static Future<void> pushReplacementNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  static void pop([Object? result]) {
    return navigatorKey.currentState!.pop(result);
  }

  static Future<void> pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}