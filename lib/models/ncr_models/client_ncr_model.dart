import 'package:advancedcleaning/models/ncr_models/ncr_action_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String clientNcrPath = 'clientNcr';

class ClientNCR {
  final String id;
  final String deviation;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String accountId;
  final String siteId;
  final String areaId;
  final String? areaTitle;
  final String submittedById;
  final String? submittedBy;
  final String? userRole;
  String status;
  List<String> responsibleIds;
  List<String> deviationImages;
  List<NcrAction> ncrActions;
  List<String> actionImages;
  String problemStatement;
  String whyOne;
  String whyTwo;
  String whyThree;
  String whyFour;
  String whyFive;
  String findings;

  ClientNCR({
    required this.id,
    required this.deviation,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.accountId,
    required this.siteId,
    required this.areaId,
    required this.submittedById,
    required this.submittedBy,
    required this.userRole,
    required this.status,
    this.areaTitle,
    this.responsibleIds = const [],
    this.deviationImages = const [],
    this.ncrActions = const [],
    this.actionImages = const [],
    this.problemStatement = '',
    this.whyOne = '',
    this.whyTwo = '',
    this.whyThree = '',
    this.whyFour = '',
    this.whyFive = '',
    this.findings = '',
  });

  factory ClientNCR.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ClientNCR(
      id: doc.id,
      deviation: data['deviation'] ?? '',
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      accountId: data['accountId'],
      siteId: data['siteId'],
      areaId: data['areaId'],
      submittedById: data['submittedById'],
      areaTitle: data['areaTitle'] ?? '',
      submittedBy: data['submittedBy'] ?? '',
      userRole: data['userRole'] ?? '',
      status: data['status'] ?? 'pending',
      responsibleIds: (data['responsibleIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      deviationImages: data['deviationImages'] == null
          ? []
          : (data['deviationImages'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      ncrActions: (data['ncrAction'] as List<dynamic>?)
              ?.map((action) => NcrAction.fromMap(action))
              .toList() ??
          [],
      actionImages: data['actionImages'] == null
          ? []
          : (data['actionImages'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      problemStatement: data['problemStatement'] ?? '',
      whyOne: data['whyOne'] ?? '',
      whyTwo: data['whyTwo'] ?? '',
      whyThree: data['whyThree'] ?? '',
      whyFour: data['whyFour'] ?? '',
      whyFive: data['whyFive'] ?? '',
      findings: data['findings'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'deviation': deviation,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'accountId': accountId,
      'siteId': siteId,
      'areaId': areaId,
      'areaTitle': areaTitle,
      'submittedById': submittedById,
      'submittedBy': submittedBy,
      'status': status,
      'responsibleIds': responsibleIds,
      'deviationImages': deviationImages,
      'ncrAction': ncrActions.map((action) => action.toFirestore()).toList(),
      'actionImages': actionImages,
      'problemStatement': problemStatement,
      'whyOne': whyOne,
      'whyTwo': whyTwo,
      'whyThree': whyThree,
      'whyFour': whyFour,
      'whyFive': whyFive,
      'findings': findings,
    };
  }
}
