import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';
import '../../models/subscription_model.dart';
import '../../models/notification_model.dart';
import '../../models/family_group_model.dart';
import '../constants/app_constants.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? get currentUserId => _auth.currentUser?.uid;

  // User operations
  static Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  static Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(uid)
          .get();
      
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  static Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Subscription operations
  static Future<String> addSubscription(SubscriptionModel subscription) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .add(subscription.toMap());
      
      // Update the subscription with the generated ID
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add subscription: $e');
    }
  }

  static Future<void> updateSubscription(SubscriptionModel subscription) async {
    try {
      await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .doc(subscription.id)
          .update(subscription.toMap());
    } catch (e) {
      throw Exception('Failed to update subscription: $e');
    }
  }

  static Future<void> deleteSubscription(String subscriptionId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .doc(subscriptionId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete subscription: $e');
    }
  }

  static Future<SubscriptionModel?> getSubscription(String subscriptionId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .doc(subscriptionId)
          .get();
      
      if (doc.exists) {
        return SubscriptionModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get subscription: $e');
    }
  }

  static Stream<List<SubscriptionModel>> getUserSubscriptions(String userId) {
    return _firestore
        .collection(FirebaseConstants.subscriptionsCollection)
        .where('userId', isEqualTo: userId)
        .where('isActive', isEqualTo: true)
        .orderBy('nextBilling')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data()))
          .toList();
    });
  }

  static Stream<List<SubscriptionModel>> getUserSubscriptionsByCategory(
      String userId, String category) {
    return _firestore
        .collection(FirebaseConstants.subscriptionsCollection)
        .where('userId', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .where('isActive', isEqualTo: true)
        .orderBy('nextBilling')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data()))
          .toList();
    });
  }

  static Future<List<SubscriptionModel>> getUpcomingRenewals(
      String userId, int daysAhead) async {
    try {
      final endDate = DateTime.now().add(Duration(days: daysAhead));
      
      final snapshot = await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .where('nextBilling', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('nextBilling')
          .get();
      
      return snapshot.docs
          .map((doc) => SubscriptionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get upcoming renewals: $e');
    }
  }

  static Future<Map<String, double>> getCostAnalytics(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      Map<String, double> analytics = {
        'totalMonthlyCost': 0.0,
        'totalYearlyCost': 0.0,
      };
      
      for (var doc in snapshot.docs) {
        final subscription = SubscriptionModel.fromMap(doc.data());
        analytics['totalMonthlyCost'] = 
            (analytics['totalMonthlyCost'] ?? 0.0) + subscription.monthlyCost;
        analytics['totalYearlyCost'] = 
            (analytics['totalYearlyCost'] ?? 0.0) + subscription.yearlyCost;
      }
      
      return analytics;
    } catch (e) {
      throw Exception('Failed to get cost analytics: $e');
    }
  }

  static Future<Map<String, double>> getCategoryWiseSpending(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      Map<String, double> categorySpending = {};
      
      for (var doc in snapshot.docs) {
        final subscription = SubscriptionModel.fromMap(doc.data());
        categorySpending[subscription.category] = 
            (categorySpending[subscription.category] ?? 0.0) + subscription.monthlyCost;
      }
      
      return categorySpending;
    } catch (e) {
      throw Exception('Failed to get category-wise spending: $e');
    }
  }

  // Notification operations
  static Future<String> addNotification(NotificationModel notification) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.notificationsCollection)
          .add(notification.toMap());
      
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(FirebaseConstants.notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  static Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _firestore
        .collection(FirebaseConstants.notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data()))
          .toList();
    });
  }

  static Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get unread notification count: $e');
    }
  }

  // Family Group operations
  static Future<String> createFamilyGroup(FamilyGroupModel familyGroup) async {
    try {
      final docRef = await _firestore
          .collection(FirebaseConstants.familyGroupsCollection)
          .add(familyGroup.toMap());
      
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create family group: $e');
    }
  }

  static Future<void> updateFamilyGroup(FamilyGroupModel familyGroup) async {
    try {
      await _firestore
          .collection(FirebaseConstants.familyGroupsCollection)
          .doc(familyGroup.id)
          .update(familyGroup.toMap());
    } catch (e) {
      throw Exception('Failed to update family group: $e');
    }
  }

  static Future<FamilyGroupModel?> getFamilyGroup(String groupId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.familyGroupsCollection)
          .doc(groupId)
          .get();
      
      if (doc.exists) {
        return FamilyGroupModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get family group: $e');
    }
  }

  static Stream<FamilyGroupModel?> getFamilyGroupStream(String groupId) {
    return _firestore
        .collection(FirebaseConstants.familyGroupsCollection)
        .doc(groupId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return FamilyGroupModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  static Future<List<FamilyGroupModel>> getUserFamilyGroups(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConstants.familyGroupsCollection)
          .where('members', arrayContains: userId)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => FamilyGroupModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get user family groups: $e');
    }
  }

  static Future<void> addMemberToFamilyGroup(
      String groupId, FamilyMember member) async {
    try {
      await _firestore
          .collection(FirebaseConstants.familyGroupsCollection)
          .doc(groupId)
          .update({
        'members': FieldValue.arrayUnion([member.toMap()]),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to add member to family group: $e');
    }
  }

  static Future<void> removeMemberFromFamilyGroup(
      String groupId, String userId) async {
    try {
      final groupDoc = await _firestore
          .collection(FirebaseConstants.familyGroupsCollection)
          .doc(groupId)
          .get();
      
      if (groupDoc.exists) {
        final group = FamilyGroupModel.fromMap(groupDoc.data()!);
        final updatedMembers = group.members
            .where((member) => member.userId != userId)
            .map((member) => member.toMap())
            .toList();
        
        await _firestore
            .collection(FirebaseConstants.familyGroupsCollection)
            .doc(groupId)
            .update({
          'members': updatedMembers,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      throw Exception('Failed to remove member from family group: $e');
    }
  }

  // Utility operations
  static Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      WriteBatch batch = _firestore.batch();
      
      for (var operation in operations) {
        switch (operation['type']) {
          case 'set':
            batch.set(operation['ref'], operation['data']);
            break;
          case 'update':
            batch.update(operation['ref'], operation['data']);
            break;
          case 'delete':
            batch.delete(operation['ref']);
            break;
        }
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to execute batch write: $e');
    }
  }

  static Future<void> cleanupOldNotifications(String userId) async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));
      
      final snapshot = await _firestore
          .collection(FirebaseConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: true)
          .where('scheduledAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();
      
      WriteBatch batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cleanup old notifications: $e');
    }
  }

  static Future<Map<String, dynamic>> getAppAnalytics() async {
    try {
      // This would typically be restricted to admin users
      final usersSnapshot = await _firestore
          .collection(FirebaseConstants.usersCollection)
          .get();
      
      final subscriptionsSnapshot = await _firestore
          .collection(FirebaseConstants.subscriptionsCollection)
          .where('isActive', isEqualTo: true)
          .get();
      
      return {
        'totalUsers': usersSnapshot.docs.length,
        'totalActiveSubscriptions': subscriptionsSnapshot.docs.length,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get app analytics: $e');
    }
  }
}