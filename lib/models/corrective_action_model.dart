import 'package:cloud_firestore/cloud_firestore.dart';

const String correctiveActionPath = 'correctiveActions';

class CorrectiveAction {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String accountId;
  final String siteId;
  final String areaId;
  final String questionId;
  final String questionTitle;
  late int failureCount;
  late String userId;
  late String action;
  late DateTime actionMonth;

  CorrectiveAction(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.accountId,
      required this.siteId,
      required this.areaId,
      required this.questionId,
      required this.questionTitle,
      required this.failureCount,
      required this.userId,
      required this.action,
      required this.actionMonth});

  factory CorrectiveAction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return CorrectiveAction(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      accountId: data['accountId'],
      siteId: data['siteId'],
      areaId: data['areaId'],
      questionId: data['questionId'],
      questionTitle: data['questionTitle'],
      failureCount: data['failureCount'],
      userId: data['userId'],
      action: data['action'],
      actionMonth: (data['actionMonth'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'accountId': accountId,
      'siteId': siteId,
      'areaId': areaId,
      'questionId': questionId,
      'questionTitle': questionTitle,
      'failureCount': failureCount,
      'userId': userId,
      'action': action,
      'actionMonth': Timestamp.fromDate(actionMonth),
    };
  }
}
