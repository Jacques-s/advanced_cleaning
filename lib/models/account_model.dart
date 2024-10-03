import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String accountPath = 'accounts';

// Account Model
class Account {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final Status status;

  Account({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.status,
  });

  factory Account.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      title: data['title'],
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'title': title,
      'status': status.name,
    };
  }

  factory Account.fromDB(Map<String, dynamic> data) {
    return Account(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      title: data['title'],
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'title': title,
      'status': status.name,
    };
  }
}
