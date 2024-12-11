import 'package:advancedcleaning/models/chemical_models/chemical_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const String procedurePath = 'procedures';

class Procedure {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime effectiveDate;
  final String documentNumber;
  final String amendmentNumber;
  final String title;
  final String areaTitle;
  final String accountId;
  final String cleaningRecord;
  final String maintenanceAssistance;
  final List<String> frequencies;
  final String responsibility;
  final String inspectedBy;
  final List<Chemical> chemicals;
  final List<String> safetyRequirements;
  final List<String> colourCodes;
  final List<String> equipmentRequired;
  final List<String> dailyInstructions;
  final List<String> weeklyInstructions;
  final List<String> monthlyInstructions;
  final List<String> quarterlyInstructions;
  final List<String> yearlyInstructions;
  final List<String> imageUrls;

  Procedure({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.effectiveDate,
    required this.documentNumber,
    required this.amendmentNumber,
    required this.title,
    required this.areaTitle,
    required this.accountId,
    required this.cleaningRecord,
    required this.maintenanceAssistance,
    required this.frequencies,
    required this.responsibility,
    required this.inspectedBy,
    required this.chemicals,
    required this.safetyRequirements,
    required this.colourCodes,
    required this.equipmentRequired,
    required this.dailyInstructions,
    required this.weeklyInstructions,
    required this.monthlyInstructions,
    required this.quarterlyInstructions,
    required this.yearlyInstructions,
    required this.imageUrls,
  });

  factory Procedure.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    List<Chemical> chemicals = [];

    if (data['chemicals'] != null) {
      data['chemicals'].forEach((key, value) {
        chemicals.add(Chemical(
          id: key,
          createdAt: (value['createdAt'] as Timestamp).toDate(),
          updatedAt: (value['updatedAt'] as Timestamp).toDate(),
          title: value['title'],
          description: value['description'],
          dilutionRange: value['dilutionRange'],
          accountId: value['accountId'],
        ));
      });
    }

    return Procedure(
      id: doc.id,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      effectiveDate: (data['effectiveDate'] as Timestamp).toDate(),
      documentNumber: data['documentNumber'],
      amendmentNumber: data['amendmentNumber'],
      title: data['title'],
      areaTitle: data['areaTitle'],
      accountId: data['accountId'],
      cleaningRecord: data['cleaningRecord'],
      maintenanceAssistance: data['maintenanceAssistance'],
      frequencies: List<String>.from(data['frequencies'] ?? []),
      responsibility: data['responsibility'] ?? '',
      inspectedBy: data['inspectedBy'] ?? '',
      chemicals: chemicals,
      safetyRequirements: List<String>.from(data['safetyRequirements'] ?? []),
      colourCodes: List<String>.from(data['colourCodes'] ?? []),
      equipmentRequired: List<String>.from(data['equipmentRequired'] ?? []),
      dailyInstructions: List<String>.from(data['dailyInstructions'] ?? []),
      weeklyInstructions: List<String>.from(data['weeklyInstructions'] ?? []),
      monthlyInstructions: List<String>.from(data['monthlyInstructions'] ?? []),
      quarterlyInstructions:
          List<String>.from(data['quarterlyInstructions'] ?? []),
      yearlyInstructions: List<String>.from(data['yearlyInstructions'] ?? []),
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'effectiveDate': Timestamp.fromDate(effectiveDate),
      'documentNumber': documentNumber,
      'amendmentNumber': amendmentNumber,
      'title': title,
      'areaTitle': areaTitle,
      'accountId': accountId,
      'cleaningRecord': cleaningRecord,
      'maintenanceAssistance': maintenanceAssistance,
      'frequencies': frequencies,
      'responsibility': responsibility,
      'inspectedBy': inspectedBy,
      'chemicals': {for (var c in chemicals) c.chemicalId: c.toFirestore()},
      'safetyRequirements': safetyRequirements,
      'colourCodes': colourCodes,
      'equipmentRequired': equipmentRequired,
      'dailyInstructions': dailyInstructions,
      'weeklyInstructions': weeklyInstructions,
      'monthlyInstructions': monthlyInstructions,
      'quarterlyInstructions': quarterlyInstructions,
      'yearlyInstructions': yearlyInstructions,
      'imageUrls': imageUrls,
    };
  }

  factory Procedure.fromDB(Map<String, dynamic> data) {
    return Procedure(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      effectiveDate: DateTime.parse(data['effectiveDate']),
      documentNumber: data['documentNumber'],
      amendmentNumber: data['amendmentNumber'],
      title: data['title'],
      areaTitle: data['areaTitle'],
      accountId: data['accountId'],
      cleaningRecord: data['cleaningRecord'],
      maintenanceAssistance: data['maintenanceAssistance'],
      frequencies: List<String>.from(data['frequencies'] ?? []),
      responsibility: data['responsibility'],
      inspectedBy: data['inspectedBy'],
      chemicals: List<Chemical>.from(data['chemicals'] ?? []),
      safetyRequirements: List<String>.from(data['safetyRequirements'] ?? []),
      colourCodes: List<String>.from(data['colourCodes'] ?? []),
      equipmentRequired: List<String>.from(data['equipmentRequired'] ?? []),
      dailyInstructions: List<String>.from(data['dailyInstructions'] ?? []),
      weeklyInstructions: List<String>.from(data['weeklyInstructions'] ?? []),
      monthlyInstructions: List<String>.from(data['monthlyInstructions'] ?? []),
      quarterlyInstructions:
          List<String>.from(data['quarterlyInstructions'] ?? []),
      yearlyInstructions: List<String>.from(data['yearlyInstructions'] ?? []),
      imageUrls: data['imageUrls'],
    );
  }

  Map<String, dynamic> toDB() {
    return {
      'id': id,
      'createdAt': createdAt.toString(),
      'updatedAt': updatedAt.toString(),
      'effectiveDate': effectiveDate.toString(),
      'documentNumber': documentNumber,
      'amendmentNumber': amendmentNumber,
      'title': title,
      'areaTitle': areaTitle,
      'accountId': accountId,
      'cleaningRecord': cleaningRecord,
      'maintenanceAssistance': maintenanceAssistance,
      'frequencies': frequencies,
      'responsibility': responsibility,
      'inspectedBy': inspectedBy,
      'safetyRequirements': safetyRequirements,
      'colourCodes': colourCodes,
      'equipmentRequired': equipmentRequired,
      'dailyInstructions': dailyInstructions,
      'weeklyInstructions': weeklyInstructions,
      'monthlyInstructions': monthlyInstructions,
      'quarterlyInstructions': quarterlyInstructions,
      'yearlyInstructions': yearlyInstructions,
      'imageUrls': imageUrls,
    };
  }
}

const Map<String, String> ppe = {
  'boots': 'Boots',
  'clothing': 'Clothing',
  'ear_protection': 'Ear Protection',
  'face_shield': 'Face Protection',
  'glasses': 'Eye Protection',
  'gloves': 'Gloves',
  'hair_net': 'Hair Net',
  'hard_hat': 'Hard Hat',
  'mask': 'Mask',
  'respirator': 'Respirator',
  'reflector': 'Reflector',
};
