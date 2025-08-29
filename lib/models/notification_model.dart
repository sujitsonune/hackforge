import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  reminder,
  renewal,
  suggestion,
  familyAlert,
  festivalOffer
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String titleHi;
  final String body;
  final String bodyHi;
  final NotificationType type;
  final String? subscriptionId;
  final bool isRead;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.titleHi,
    required this.body,
    required this.bodyHi,
    required this.type,
    this.subscriptionId,
    this.isRead = false,
    required this.scheduledAt,
    this.sentAt,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'titleHi': titleHi,
      'body': body,
      'bodyHi': bodyHi,
      'type': type.name,
      'subscriptionId': subscriptionId,
      'isRead': isRead,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
      'data': data,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      titleHi: map['titleHi'] ?? '',
      body: map['body'] ?? '',
      bodyHi: map['bodyHi'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.reminder,
      ),
      subscriptionId: map['subscriptionId'],
      isRead: map['isRead'] ?? false,
      scheduledAt: (map['scheduledAt'] as Timestamp).toDate(),
      sentAt: map['sentAt'] != null ? (map['sentAt'] as Timestamp).toDate() : null,
      data: map['data'],
    );
  }

  String getLocalizedTitle(String language) {
    return language == 'hi' ? titleHi : title;
  }

  String getLocalizedBody(String language) {
    return language == 'hi' ? bodyHi : body;
  }

  bool get isSent => sentAt != null;

  bool get isPending => !isSent && scheduledAt.isAfter(DateTime.now());

  bool get isOverdue => !isSent && scheduledAt.isBefore(DateTime.now());

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? titleHi,
    String? body,
    String? bodyHi,
    NotificationType? type,
    String? subscriptionId,
    bool? isRead,
    DateTime? scheduledAt,
    DateTime? sentAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      titleHi: titleHi ?? this.titleHi,
      body: body ?? this.body,
      bodyHi: bodyHi ?? this.bodyHi,
      type: type ?? this.type,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      isRead: isRead ?? this.isRead,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      sentAt: sentAt ?? this.sentAt,
      data: data ?? this.data,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead, scheduledAt: $scheduledAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}