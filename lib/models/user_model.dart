import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String? email;
  final String phone;
  final String preferredLanguage;
  final String currency;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isPremium;
  final String? familyGroupId;

  const UserModel({
    required this.uid,
    required this.name,
    this.email,
    required this.phone,
    this.preferredLanguage = 'hi',
    this.currency = 'INR',
    required this.createdAt,
    required this.lastLogin,
    this.isPremium = false,
    this.familyGroupId,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'preferredLanguage': preferredLanguage,
      'currency': currency,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'isPremium': isPremium,
      'familyGroupId': familyGroupId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'],
      phone: map['phone'] ?? '',
      preferredLanguage: map['preferredLanguage'] ?? 'hi',
      currency: map['currency'] ?? 'INR',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastLogin: (map['lastLogin'] as Timestamp).toDate(),
      isPremium: map['isPremium'] ?? false,
      familyGroupId: map['familyGroupId'],
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? preferredLanguage,
    String? currency,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isPremium,
    String? familyGroupId,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isPremium: isPremium ?? this.isPremium,
      familyGroupId: familyGroupId ?? this.familyGroupId,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email, phone: $phone, preferredLanguage: $preferredLanguage, currency: $currency, createdAt: $createdAt, lastLogin: $lastLogin, isPremium: $isPremium, familyGroupId: $familyGroupId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.phone == phone &&
        other.preferredLanguage == preferredLanguage &&
        other.currency == currency &&
        other.createdAt == createdAt &&
        other.lastLogin == lastLogin &&
        other.isPremium == isPremium &&
        other.familyGroupId == familyGroupId;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        phone.hashCode ^
        preferredLanguage.hashCode ^
        currency.hashCode ^
        createdAt.hashCode ^
        lastLogin.hashCode ^
        isPremium.hashCode ^
        familyGroupId.hashCode;
  }
}