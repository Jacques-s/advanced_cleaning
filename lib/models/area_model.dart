import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String areaPath = 'inspectionAreas';

class InspectionArea {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String barcode;
  final Status status;
  final String accountId;
  final String siteId;
  bool isCompeletd; // Only used for the app

  InspectionArea(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      required this.barcode,
      required this.status,
      required this.accountId,
      required this.siteId,
      this.isCompeletd = false});

  factory InspectionArea.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return InspectionArea(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      title: data['title'],
      barcode: data['barcode'],
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      accountId: data['accountId'],
      siteId: data['siteId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'title': title,
      'barcode': barcode,
      'status': status.name,
      'accountId': accountId,
      'siteId': siteId,
    };
  }

  factory InspectionArea.fromDB(Map<String, dynamic> data) {
    return InspectionArea(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      title: data['title'],
      barcode: data['barcode'],
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      accountId: data['accountId'],
      siteId: data['siteId'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'title': title,
      'barcode': barcode,
      'status': status.name,
      'accountId': accountId,
      'siteId': siteId,
    };
  }
}
