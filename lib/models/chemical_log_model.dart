import 'package:cloud_firestore/cloud_firestore.dart';

const String chemicalLogPath = 'chemicalLogs';

class ChemicalLog {
  final String id;
  final DateTime createdAt;
  final String createdById;
  final String createdName;
  final String accountId;
  final String siteId;
  final String chemicalId;
  final String chemicalName;
  final String chemicalAmount;
  final String batchNumber;
  final String expiryDate;
  final String testKitExpiryDate;
  final String waterAmount;
  final String issuedTo;
  final String? numberOfDrops;
  final String? factor;
  final String? verification;
  final String? correctiveAction;

  ChemicalLog(
      {required this.id,
      required this.createdAt,
      required this.createdById,
      required this.createdName,
      required this.accountId,
      required this.siteId,
      required this.chemicalId,
      required this.chemicalName,
      required this.chemicalAmount,
      required this.batchNumber,
      required this.expiryDate,
      required this.testKitExpiryDate,
      required this.waterAmount,
      required this.issuedTo,
      this.numberOfDrops,
      this.factor,
      this.verification,
      this.correctiveAction});

  factory ChemicalLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ChemicalLog(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdById: data['createdById'],
      createdName: data['createdName'],
      accountId: data['accountId'],
      siteId: data['siteId'],
      chemicalId: data['chemicalId'],
      chemicalName: data['chemicalName'],
      chemicalAmount: data['chemicalAmount'],
      batchNumber: data['batchNumber'],
      expiryDate: data['expiryDate'],
      testKitExpiryDate: data['testKitExpiryDate'],
      waterAmount: data['waterAmount'],
      issuedTo: data['issuedTo'],
      numberOfDrops: data['numberOfDrops'],
      factor: data['factor'],
      verification: data['verification'],
      correctiveAction: data['correctiveAction'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'accountId': accountId,
      'siteId': siteId,
      'chemicalId': chemicalId,
      'chemicalName': chemicalName,
      'chemicalAmount': chemicalAmount,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate,
      'testKitExpiryDate': testKitExpiryDate,
      'waterAmount': waterAmount,
      'issuedTo': issuedTo,
      'numberOfDrops': numberOfDrops,
      'factor': factor,
      'verification': verification,
      'correctiveAction': correctiveAction,
    };
  }

  factory ChemicalLog.fromDB(Map<String, dynamic> data) {
    return ChemicalLog(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      createdById: data['createdById'],
      createdName: data['createdName'],
      accountId: data['accountId'],
      siteId: data['siteId'],
      chemicalId: data['chemicalId'],
      chemicalName: data['chemicalName'],
      chemicalAmount: data['chemicalAmount'],
      batchNumber: data['batchNumber'],
      expiryDate: data['expiryDate'],
      testKitExpiryDate: data['testKitExpiryDate'],
      waterAmount: data['waterAmount'],
      issuedTo: data['issuedTo'],
      numberOfDrops: data['numberOfDrops'],
      factor: data['factor'],
      verification: data['verification'],
      correctiveAction: data['correctiveAction'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'createdById': createdById,
      'createdName': createdName,
      'accountId': accountId,
      'siteId': siteId,
      'chemicalId': chemicalId,
      'chemicalName': chemicalName,
      'chemicalAmount': chemicalAmount,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate,
      'testKitExpiryDate': testKitExpiryDate,
      'waterAmount': waterAmount,
      'issuedTo': issuedTo,
      'numberOfDrops': numberOfDrops,
      'factor': factor,
      'verification': verification,
      'correctiveAction': correctiveAction,
    };
  }
}
