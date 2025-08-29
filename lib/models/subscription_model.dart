import 'package:cloud_firestore/cloud_firestore.dart';

enum BillingCycle {
  weekly,
  monthly,
  quarterly,
  halfYearly,
  yearly
}

enum PaymentMethod {
  upi,
  card,
  netBanking,
  wallet,
  emi
}

enum Platform {
  android,
  ios,
  web,
  unknown
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double cost;
  final String currency;
  final BillingCycle billingCycle;
  final DateTime nextBilling;
  final bool isActive;
  final PaymentMethod paymentMethod;
  final Platform platform;
  final bool reminderEnabled;
  final List<int> reminderDays;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? description;
  final String? logoUrl;

  const SubscriptionModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.cost,
    this.currency = 'INR',
    required this.billingCycle,
    required this.nextBilling,
    this.isActive = true,
    this.paymentMethod = PaymentMethod.upi,
    this.platform = Platform.android,
    this.reminderEnabled = true,
    this.reminderDays = const [7, 3, 1],
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.description,
    this.logoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'cost': cost,
      'currency': currency,
      'billingCycle': billingCycle.name,
      'nextBilling': Timestamp.fromDate(nextBilling),
      'isActive': isActive,
      'paymentMethod': paymentMethod.name,
      'platform': platform.name,
      'reminderEnabled': reminderEnabled,
      'reminderDays': reminderDays,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'description': description,
      'logoUrl': logoUrl,
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      cost: (map['cost'] ?? 0.0).toDouble(),
      currency: map['currency'] ?? 'INR',
      billingCycle: BillingCycle.values.firstWhere(
        (e) => e.name == map['billingCycle'],
        orElse: () => BillingCycle.monthly,
      ),
      nextBilling: (map['nextBilling'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['paymentMethod'],
        orElse: () => PaymentMethod.upi,
      ),
      platform: Platform.values.firstWhere(
        (e) => e.name == map['platform'],
        orElse: () => Platform.android,
      ),
      reminderEnabled: map['reminderEnabled'] ?? true,
      reminderDays: List<int>.from(map['reminderDays'] ?? [7, 3, 1]),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      tags: List<String>.from(map['tags'] ?? []),
      description: map['description'],
      logoUrl: map['logoUrl'],
    );
  }

  double get monthlyCost {
    switch (billingCycle) {
      case BillingCycle.weekly:
        return cost * 4.33;
      case BillingCycle.monthly:
        return cost;
      case BillingCycle.quarterly:
        return cost / 3;
      case BillingCycle.halfYearly:
        return cost / 6;
      case BillingCycle.yearly:
        return cost / 12;
    }
  }

  double get yearlyCost {
    switch (billingCycle) {
      case BillingCycle.weekly:
        return cost * 52;
      case BillingCycle.monthly:
        return cost * 12;
      case BillingCycle.quarterly:
        return cost * 4;
      case BillingCycle.halfYearly:
        return cost * 2;
      case BillingCycle.yearly:
        return cost;
    }
  }

  int get daysUntilRenewal {
    return nextBilling.difference(DateTime.now()).inDays;
  }

  bool get isRenewalDue {
    return daysUntilRenewal <= 0;
  }

  bool get shouldSendReminder {
    return reminderEnabled && 
           reminderDays.contains(daysUntilRenewal) && 
           daysUntilRenewal >= 0;
  }

  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    double? cost,
    String? currency,
    BillingCycle? billingCycle,
    DateTime? nextBilling,
    bool? isActive,
    PaymentMethod? paymentMethod,
    Platform? platform,
    bool? reminderEnabled,
    List<int>? reminderDays,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? description,
    String? logoUrl,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      currency: currency ?? this.currency,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBilling: nextBilling ?? this.nextBilling,
      isActive: isActive ?? this.isActive,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      platform: platform ?? this.platform,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDays: reminderDays ?? this.reminderDays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
    );
  }

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, name: $name, cost: $cost, billingCycle: $billingCycle, nextBilling: $nextBilling, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubscriptionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}