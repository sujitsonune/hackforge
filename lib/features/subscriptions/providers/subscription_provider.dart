import 'package:flutter/foundation.dart';

import '../../../models/subscription_model.dart';
import '../../../core/services/subscription_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService();

  List<SubscriptionModel> _subscriptions = [];
  Map<String, dynamic> _analytics = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<SubscriptionModel> get subscriptions => _subscriptions;
  List<SubscriptionModel> get activeSubscriptions => 
      _subscriptions.where((s) => s.isActive).toList();
  List<SubscriptionModel> get pausedSubscriptions => 
      _subscriptions.where((s) => !s.isActive).toList();
  Map<String, dynamic> get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream subscription
  Stream<List<SubscriptionModel>>? _subscriptionStream;

  void startListening() {
    _subscriptionStream = _subscriptionService.getSubscriptions();
    _subscriptionStream!.listen(
      (subscriptions) {
        _subscriptions = subscriptions;
        _error = null;
        notifyListeners();
        _loadAnalytics();
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );
  }

  // Add subscription
  Future<void> addSubscription(SubscriptionModel subscription) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _subscriptionService.addSubscription(subscription);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update subscription
  Future<void> updateSubscription(SubscriptionModel subscription) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _subscriptionService.updateSubscription(subscription);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete subscription
  Future<void> deleteSubscription(String subscriptionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _subscriptionService.deleteSubscription(subscriptionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle subscription status
  Future<void> toggleSubscriptionStatus(String subscriptionId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _subscriptionService.toggleSubscriptionStatus(subscriptionId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load analytics
  Future<void> _loadAnalytics() async {
    try {
      _analytics = await _subscriptionService.getSubscriptionAnalytics();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading analytics: $e');
      }
    }
  }

  // Get subscriptions by category
  List<SubscriptionModel> getSubscriptionsByCategory(String category) {
    return _subscriptions
        .where((subscription) => subscription.category == category)
        .toList();
  }

  // Get subscriptions needing renewal soon
  List<SubscriptionModel> getSubscriptionsNeedingRenewal([int days = 7]) {
    return _subscriptions
        .where((subscription) => 
            subscription.isActive && 
            subscription.daysUntilRenewal <= days &&
            subscription.daysUntilRenewal >= 0)
        .toList();
  }

  // Get overdue subscriptions
  List<SubscriptionModel> getOverdueSubscriptions() {
    return _subscriptions
        .where((subscription) => 
            subscription.isActive && subscription.daysUntilRenewal < 0)
        .toList();
  }

  // Search subscriptions
  Future<List<SubscriptionModel>> searchSubscriptions(String query) async {
    try {
      return await _subscriptionService.searchSubscriptions(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Calculate total spending
  double getTotalMonthlySpending() {
    return activeSubscriptions.fold(0, (sum, subscription) => sum + subscription.monthlyCost);
  }

  double getTotalYearlySpending() {
    return activeSubscriptions.fold(0, (sum, subscription) => sum + subscription.yearlyCost);
  }

  // Get spending by category
  Map<String, double> getMonthlySpendingByCategory() {
    final Map<String, double> categorySpending = {};
    
    for (final subscription in activeSubscriptions) {
      categorySpending[subscription.category] = 
          (categorySpending[subscription.category] ?? 0) + subscription.monthlyCost;
    }
    
    return categorySpending;
  }

  // Get billing cycle distribution
  Map<BillingCycle, int> getBillingCycleDistribution() {
    final Map<BillingCycle, int> distribution = {};
    
    for (final subscription in activeSubscriptions) {
      distribution[subscription.billingCycle] = 
          (distribution[subscription.billingCycle] ?? 0) + 1;
    }
    
    return distribution;
  }

  // Refresh data
  Future<void> refresh() async {
    await _loadAnalytics();
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}