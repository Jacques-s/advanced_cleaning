import 'package:cloud_firestore/cloud_firestore.dart';

const String inspectionPath = 'inspections';

class Inspection {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime conductedDate;
  double? score;
  double? pass;
  double? fail;
  final String accountId;
  final String siteId;
  final String siteTitle;
  final String userId;
  final String userFullName;
  Map<String, dynamic>? areaScores;

  Inspection({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.conductedDate,
    this.score,
    this.pass,
    this.fail,
    required this.accountId,
    required this.siteId,
    required this.siteTitle,
    required this.userId,
    required this.userFullName,
    this.areaScores,
  });

  factory Inspection.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Inspection(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      conductedDate: (data['conductedDate'] as Timestamp).toDate(),
      score: data['score'],
      pass: data['pass'] ?? 0,
      fail: data['fail'] ?? 0,
      areaScores: data['areaScores'],
      accountId: data['accountId'],
      siteId: data['siteId'],
      siteTitle: data['siteTitle'],
      userId: data['userId'],
      userFullName: data['userFullName'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'conductedDate': Timestamp.fromDate(conductedDate),
      'score': score,
      'pass': pass,
      'fail': fail,
      'accountId': accountId,
      'siteId': siteId,
      'siteTitle': siteTitle,
      'userId': userId,
      'userFullName': userFullName,
      'areaScores': areaScores
    };
  }

  factory Inspection.fromDB(Map<String, dynamic> data) {
    return Inspection(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      conductedDate: DateTime.parse(data['conductedDate']),
      score: data['score'] ?? 0,
      pass: data['pass'] ?? 0,
      fail: data['fail'] ?? 0,
      accountId: data['accountId'],
      siteId: data['siteId'],
      siteTitle: data['siteTitle'],
      userId: data['userId'],
      userFullName: data['userFullName'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'conductedDate': conductedDate.toString(),
      'score': score ?? 0,
      'pass': pass ?? 0,
      'fail': fail ?? 0,
      'accountId': accountId,
      'siteId': siteId,
      'siteTitle': siteTitle,
      'userId': userId,
      'userFullName': userFullName,
    };
  }
}
