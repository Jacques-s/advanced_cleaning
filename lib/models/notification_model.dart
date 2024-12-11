import 'package:cloud_firestore/cloud_firestore.dart';

const String notificationPath = 'notifications';

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String eventId;
  final DateTime createdAt;
  final bool read;
  final String type;
  final String accountId;
  final String siteId;

  AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.eventId,
    required this.createdAt,
    required this.read,
    required this.type,
    required this.accountId,
    required this.siteId,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      message: data['message'],
      eventId: data['eventId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      read: data['read'],
      type: data['type'],
      accountId: data['accountId'],
      siteId: data['siteId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'message': message,
      'eventId': eventId,
      'createdAt': Timestamp.fromDate(createdAt),
      'read': read,
      'type': type,
      'accountId': accountId,
      'siteId': siteId,
    };
  }
}
