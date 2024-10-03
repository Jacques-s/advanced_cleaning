import 'package:advancedcleaning/models/enum_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String userPath = 'users';

class AppUser {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String firstName;
  final String surname;
  final String email;
  final String? cellNumber;
  final UserRole role;
  final Status status;
  final String? accountId;
  final List<String> siteIds;
  final DateTime? lastSynced;

  AppUser(
      {required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.firstName,
      required this.surname,
      required this.email,
      required this.role,
      required this.status,
      this.cellNumber,
      this.accountId,
      required this.siteIds,
      this.lastSynced});

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      firstName: data['firstName'],
      surname: data['surname'],
      email: data['email'],
      cellNumber: data['cellNumber'],
      role: UserRole.values
          .firstWhere((e) => e.toString() == 'UserRole.${data['role']}'),
      status: Status.values
          .firstWhere((e) => e.toString() == 'Status.${data['status']}'),
      accountId: data['accountId'],
      siteIds:
          data['siteIds'] != null ? List<String>.from(data['siteIds']) : [],
      lastSynced: data['lastSynced'] != null
          ? (data['lastSynced'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'firstName': firstName,
      'surname': surname,
      'email': email,
      'cellNumber': cellNumber,
      'role': role.toString().split('.').last,
      'status': status.toString().split('.').last,
      'accountId': accountId,
      'siteIds': siteIds,
      'lastSynced': lastSynced != null ? Timestamp.fromDate(lastSynced!) : null,
    };
  }

  String get fullName => '$firstName $surname';
}
