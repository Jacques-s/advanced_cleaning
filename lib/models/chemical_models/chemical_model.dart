import 'package:cloud_firestore/cloud_firestore.dart';

const String chemicalPath = 'chemicals';

class Chemical {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String? description;
  final String dilutionRange;
  final String accountId;

  String get chemicalId {
    String slug =
        '${accountId}__${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}';
    return slug.trim();
  }

  Chemical(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      this.description,
      required this.dilutionRange,
      required this.accountId});

  factory Chemical.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Chemical(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      title: data['title'],
      description: data['description'],
      dilutionRange: data['dilutionRange'],
      accountId: data['accountId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'title': title,
      'description': description,
      'dilutionRange': dilutionRange,
      'accountId': accountId,
    };
  }

  factory Chemical.fromDB(Map<String, dynamic> data) {
    return Chemical(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      title: data['title'],
      description: data['description'],
      dilutionRange: data['dilutionRange'],
      accountId: data['accountId'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'title': title,
      'description': description,
      'dilutionRange': dilutionRange,
      'accountId': accountId,
    };
  }
}
