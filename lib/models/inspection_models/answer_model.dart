import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String inspectionAnswerPath = 'inspectionAnswers';

class InspectionAnswer {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final InspectionResult status;
  final String? failureReason;
  final String? correctiveAction;
  final String accountId;
  final String siteId;
  final String areaId;
  final String inspectionId;
  final String questionId;
  final String? questionTitle;
  final InspectionFrequency questionFrequency;

  InspectionAnswer(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.status,
      this.failureReason,
      this.correctiveAction,
      required this.accountId,
      required this.siteId,
      required this.areaId,
      required this.inspectionId,
      required this.questionId,
      this.questionTitle,
      required this.questionFrequency});

  factory InspectionAnswer.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InspectionAnswer(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      status: InspectionResult.values.firstWhere(
          (e) => e.toString() == 'InspectionResult.${data['status']}'),
      failureReason: data['failureReason'],
      correctiveAction: data['correctiveAction'],
      accountId: data['accountId'],
      siteId: data['siteId'],
      areaId: data['areaId'],
      inspectionId: data['inspectionId'],
      questionId: data['questionId'],
      questionTitle: data['questionTitle'],
      questionFrequency: InspectionFrequency.values.firstWhere(
        (e) =>
            e.toString() == 'InspectionFrequency.${data['questionFrequency']}',
        orElse: () => InspectionFrequency.daily,
      ),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status.name,
      'failureReason': failureReason,
      'correctiveAction': correctiveAction,
      'accountId': accountId,
      'siteId': siteId,
      'areaId': areaId,
      'inspectionId': inspectionId,
      'questionId': questionId,
      'questionTitle': questionTitle,
      'questionFrequency': questionFrequency.name
    };
  }

  factory InspectionAnswer.fromDB(Map<String, dynamic> data) {
    return InspectionAnswer(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      status: InspectionResult.values.firstWhere(
          (e) => e.toString() == 'InspectionResult.${data['status']}'),
      failureReason: data['failureReason'],
      correctiveAction: data['correctiveAction'],
      accountId: data['accountId'],
      siteId: data['siteId'],
      areaId: data['areaId'],
      inspectionId: data['inspectionId'],
      questionId: data['questionId'],
      questionTitle: data['questionTitle'],
      questionFrequency: InspectionFrequency.values.firstWhere((e) =>
          e.toString() == 'InspectionFrequency.${data['questionFrequency']}'),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'status': status.name,
      'failureReason': failureReason,
      'correctiveAction': correctiveAction,
      'accountId': accountId,
      'siteId': siteId,
      'areaId': areaId,
      'inspectionId': inspectionId,
      'questionId': questionId,
      'questionTitle': questionTitle,
      'questionFrequency': questionFrequency.name
    };
  }
}
