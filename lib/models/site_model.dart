import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String sitePath = 'sites';

class Site {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String? address;
  final Status status;
  final String accountId;
  final DateTime? appChanges;

  Site(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      this.address,
      required this.status,
      required this.accountId,
      this.appChanges});

  factory Site.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Site(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      title: data['title'],
      address: data['address'],
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      accountId: data['accountId'],
      appChanges: data['appChanges'] != null
          ? (data['appChanges'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'title': title,
      'address': address,
      'status': status.name,
      'accountId': accountId,
      'appChanges': appChanges != null ? Timestamp.fromDate(appChanges!) : null,
    };
  }

  factory Site.fromDB(Map<String, dynamic> data) {
    return Site(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      title: data['title'],
      address: data['address'],
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      accountId: data['accountId'],
      appChanges: data['appChanges'] != null
          ? DateTime.parse(data['appChanges'])
          : null,
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'title': title,
      'address': address,
      'status': status.name,
      'accountId': accountId,
      'appChanges': appChanges?.toString(),
    };
  }
}
