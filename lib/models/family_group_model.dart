import 'package:cloud_firestore/cloud_firestore.dart';

enum MemberRole {
  admin,
  member
}

class FamilyMember {
  final String userId;
  final String name;
  final String email;
  final MemberRole role;
  final DateTime joinedAt;

  const FamilyMember({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role.name,
      'joinedAt': Timestamp.fromDate(joinedAt),
    };
  }

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: MemberRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => MemberRole.member,
      ),
      joinedAt: (map['joinedAt'] as Timestamp).toDate(),
    );
  }

  bool get isAdmin => role == MemberRole.admin;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyMember && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}

class FamilyGroupModel {
  final String id;
  final String name;
  final String adminId;
  final List<FamilyMember> members;
  final List<String> sharedSubscriptions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, double> costSplitRules;
  final bool isActive;

  const FamilyGroupModel({
    required this.id,
    required this.name,
    required this.adminId,
    required this.members,
    this.sharedSubscriptions = const [],
    required this.createdAt,
    required this.updatedAt,
    this.costSplitRules = const {},
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'adminId': adminId,
      'members': members.map((member) => member.toMap()).toList(),
      'sharedSubscriptions': sharedSubscriptions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'costSplitRules': costSplitRules,
      'isActive': isActive,
    };
  }

  factory FamilyGroupModel.fromMap(Map<String, dynamic> map) {
    return FamilyGroupModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      adminId: map['adminId'] ?? '',
      members: List<FamilyMember>.from(
        (map['members'] ?? []).map((member) => FamilyMember.fromMap(member)),
      ),
      sharedSubscriptions: List<String>.from(map['sharedSubscriptions'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      costSplitRules: Map<String, double>.from(map['costSplitRules'] ?? {}),
      isActive: map['isActive'] ?? true,
    );
  }

  int get memberCount => members.length;

  List<String> get memberIds => members.map((member) => member.userId).toList();

  FamilyMember? get admin => members.firstWhere(
    (member) => member.userId == adminId,
    orElse: () => members.first,
  );

  List<FamilyMember> get nonAdminMembers => members.where(
    (member) => member.userId != adminId,
  ).toList();

  bool isMember(String userId) => memberIds.contains(userId);

  bool isAdmin(String userId) => adminId == userId;

  double getCostSplitForUser(String userId) {
    if (costSplitRules.containsKey(userId)) {
      return costSplitRules[userId]!;
    }
    
    return 1.0 / memberCount;
  }

  double getTotalSharedCost(List<double> subscriptionCosts) {
    return subscriptionCosts.fold(0, (sum, cost) => sum + cost);
  }

  Map<String, double> calculateCostSplitForSubscription(double subscriptionCost) {
    Map<String, double> splitCosts = {};
    
    for (String memberId in memberIds) {
      double splitRatio = getCostSplitForUser(memberId);
      splitCosts[memberId] = subscriptionCost * splitRatio;
    }
    
    return splitCosts;
  }

  FamilyGroupModel copyWith({
    String? id,
    String? name,
    String? adminId,
    List<FamilyMember>? members,
    List<String>? sharedSubscriptions,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, double>? costSplitRules,
    bool? isActive,
  }) {
    return FamilyGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      adminId: adminId ?? this.adminId,
      members: members ?? this.members,
      sharedSubscriptions: sharedSubscriptions ?? this.sharedSubscriptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      costSplitRules: costSplitRules ?? this.costSplitRules,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'FamilyGroupModel(id: $id, name: $name, adminId: $adminId, memberCount: $memberCount, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FamilyGroupModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}