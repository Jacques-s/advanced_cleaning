import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String questionPath = 'inspectionQuestions';

class InspectionQuestion {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final InspectionFrequency frequency;
  final Status status;
  final DateTime? nextInspectionDate;
  final DateTime? lastInspectionDate;
  final InspectionResult? lastInspectionResult;
  final String accountId;
  final String siteId;
  final String areaId;

  InspectionQuestion({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.frequency,
    required this.status,
    this.nextInspectionDate,
    this.lastInspectionDate,
    this.lastInspectionResult,
    required this.accountId,
    required this.siteId,
    required this.areaId,
  });

  factory InspectionQuestion.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InspectionQuestion(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      title: data['title'],
      frequency: InspectionFrequency.values.firstWhere(
          (e) => e.toString() == 'InspectionFrequency.${data['frequency']}'),
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      nextInspectionDate: data['nextInspectionDate'] != null
          ? (data['nextInspectionDate'] as Timestamp).toDate()
          : null,
      lastInspectionDate: data['lastInspectionDate'] != null
          ? (data['lastInspectionDate'] as Timestamp).toDate()
          : null,
      lastInspectionResult: data['lastInspectionResult'] != null
          ? InspectionResult.values.firstWhere((e) =>
              e.toString() ==
              'InspectionResult.${data['lastInspectionResult']}')
          : null,
      accountId: data['accountId'],
      siteId: data['siteId'],
      areaId: data['areaId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'title': title,
      'frequency': frequency.name,
      'status': status.name,
      'nextInspectionDate': nextInspectionDate != null
          ? Timestamp.fromDate(nextInspectionDate!)
          : null,
      'lastInspectionDate': lastInspectionDate != null
          ? Timestamp.fromDate(lastInspectionDate!)
          : null,
      'lastInspectionResult': lastInspectionResult?.name,
      'accountId': accountId,
      'siteId': siteId,
      'areaId': areaId,
    };
  }

  factory InspectionQuestion.fromDB(Map<String, dynamic> data) {
    return InspectionQuestion(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      title: data['title'],
      frequency: InspectionFrequency.values.firstWhere(
          (e) => e.toString() == 'InspectionFrequency.${data['frequency']}'),
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      nextInspectionDate: data['nextInspectionDate'] != null
          ? DateTime.parse(data['nextInspectionDate'])
          : null,
      lastInspectionDate: data['lastInspectionDate'] != null
          ? DateTime.parse(data['lastInspectionDate'])
          : null,
      lastInspectionResult: data['lastInspectionResult'] != null
          ? InspectionResult.values.firstWhere((e) =>
              e.toString() ==
              'InspectionResult.${data['lastInspectionResult']}')
          : null,
      accountId: data['accountId'],
      siteId: data['siteId'],
      areaId: data['areaId'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'title': title,
      'frequency': frequency.name,
      'status': status.name,
      'nextInspectionDate': nextInspectionDate?.toString(),
      'lastInspectionDate': lastInspectionDate?.toString(),
      'lastInspectionResult': lastInspectionResult?.name,
      'accountId': accountId,
      'siteId': siteId,
      'areaId': areaId,
    };
  }
}
