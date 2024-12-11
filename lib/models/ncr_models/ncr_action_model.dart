import 'package:cloud_firestore/cloud_firestore.dart';

class NcrAction {
  final DateTime createdAt;
  final String submittedById;
  final String submittedBy;
  final String action;

  NcrAction({
    required this.createdAt,
    required this.submittedById,
    required this.submittedBy,
    required this.action,
  });

  factory NcrAction.fromMap(Map<String, dynamic> data) {
    return NcrAction(
      createdAt: DateTime.parse(data['createdAt']),
      submittedById: data['submittedById'],
      submittedBy: data['submittedBy'],
      action: data['action'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': createdAt.toString(),
      'submittedById': submittedById,
      'submittedBy': submittedBy,
      'action': action,
    };
  }
}
