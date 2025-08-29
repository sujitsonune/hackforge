import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/subscription_model.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId => _auth.currentUser?.uid ?? '';

  // Collection reference
  CollectionReference get _subscriptionsCollection =>
      _firestore.collection('users').doc(_userId).collection('subscriptions');

  // Add a new subscription
  Future<void> addSubscription(SubscriptionModel subscription) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      await _subscriptionsCollection.doc(subscription.id).set(subscription.toMap());
    } catch (e) {
      throw Exception('Failed to add subscription: $e');
    }
  }

  // Update an existing subscription
  Future<void> updateSubscription(SubscriptionModel subscription) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      await _subscriptionsCollection.doc(subscription.id).update(
        subscription.copyWith(updatedAt: DateTime.now()).toMap(),
      );
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  // Delete a subscription
  Future<void> deleteSubscription(String subscriptionId) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      await _subscriptionsCollection.doc(subscriptionId).delete();
    } catch (e) {
      throw Exception('Failed to delete subscription: $e');
    }
  }

  // Get all subscriptions for the current user
  Stream<List<SubscriptionModel>> getSubscriptions() {
    if (_userId.isEmpty) return Stream.value([]);

    return _subscriptionsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionModel.fromMap(data);
      }).toList();
    });
  }

  // Get active subscriptions only
  Stream<List<SubscriptionModel>> getActiveSubscriptions() {
    if (_userId.isEmpty) return Stream.value([]);

    return _subscriptionsCollection
        .where('isActive', isEqualTo: true)
        .orderBy('nextBilling')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionModel.fromMap(data);
      }).toList();
    });
  }

  // Get subscriptions by category
  Stream<List<SubscriptionModel>> getSubscriptionsByCategory(String category) {
    if (_userId.isEmpty) return Stream.value([]);

    return _subscriptionsCollection
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionModel.fromMap(data);
      }).toList();
    });
  }

  // Get subscriptions that need renewal reminders
  Future<List<SubscriptionModel>> getSubscriptionsNeedingReminders() async {
    if (_userId.isEmpty) return [];

    try {
      final now = DateTime.now();
      final snapshot = await _subscriptionsCollection
          .where('isActive', isEqualTo: true)
          .where('reminderEnabled', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SubscriptionModel.fromMap(data);
          })
          .where((subscription) => subscription.shouldSendReminder)
          .toList();
    } catch (e) {
      throw Exception('Failed to get subscriptions needing reminders: $e');
    }
  }

  // Get subscription analytics
  Future<Map<String, dynamic>> getSubscriptionAnalytics() async {
    if (_userId.isEmpty) return {};

    try {
      final snapshot = await _subscriptionsCollection.get();
      final subscriptions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionModel.fromMap(data);
      }).toList();

      final activeSubscriptions = subscriptions.where((s) => s.isActive).toList();
      
      double totalMonthlySpend = 0;
      double totalYearlySpend = 0;
      Map<String, int> categoryCounts = {};
      Map<BillingCycle, int> billingCycleCounts = {};

      for (final subscription in activeSubscriptions) {
        totalMonthlySpend += subscription.monthlyCost;
        totalYearlySpend += subscription.yearlyCost;

        categoryCounts[subscription.category] = 
            (categoryCounts[subscription.category] ?? 0) + 1;

        billingCycleCounts[subscription.billingCycle] = 
            (billingCycleCounts[subscription.billingCycle] ?? 0) + 1;
      }

      return {
        'totalSubscriptions': subscriptions.length,
        'activeSubscriptions': activeSubscriptions.length,
        'pausedSubscriptions': subscriptions.length - activeSubscriptions.length,
        'totalMonthlySpend': totalMonthlySpend,
        'totalYearlySpend': totalYearlySpend,
        'categoryCounts': categoryCounts,
        'billingCycleCounts': billingCycleCounts,
        'averageMonthlySpend': activeSubscriptions.isNotEmpty 
            ? totalMonthlySpend / activeSubscriptions.length 
            : 0,
      };
    } catch (e) {
      throw Exception('Failed to get subscription analytics: $e');
    }
  }

  // Toggle subscription active status
  Future<void> toggleSubscriptionStatus(String subscriptionId) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      final doc = await _subscriptionsCollection.doc(subscriptionId).get();
      if (!doc.exists) throw Exception('Subscription not found');

      final subscription = SubscriptionModel.fromMap(doc.data() as Map<String, dynamic>);
      await updateSubscription(subscription.copyWith(isActive: !subscription.isActive));
    } catch (e) {
      throw Exception('Failed to toggle subscription status: $e');
    }
  }

  // Batch operations for better performance
  Future<void> batchUpdateSubscriptions(List<SubscriptionModel> subscriptions) async {
    if (_userId.isEmpty) throw Exception('User not authenticated');

    try {
      final batch = _firestore.batch();
      
      for (final subscription in subscriptions) {
        final docRef = _subscriptionsCollection.doc(subscription.id);
        batch.update(docRef, subscription.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update subscriptions: $e');
    }
  }

  // Search subscriptions
  Future<List<SubscriptionModel>> searchSubscriptions(String query) async {
    if (_userId.isEmpty) return [];

    try {
      final snapshot = await _subscriptionsCollection.get();
      final subscriptions = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return SubscriptionModel.fromMap(data);
      }).toList();

      return subscriptions.where((subscription) =>
          subscription.name.toLowerCase().contains(query.toLowerCase()) ||
          subscription.category.toLowerCase().contains(query.toLowerCase()) ||
          (subscription.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    } catch (e) {
      throw Exception('Failed to search subscriptions: $e');
    }
  }
}