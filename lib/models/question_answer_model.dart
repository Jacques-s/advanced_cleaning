import 'package:advancedcleaning/models/enum_model.dart';

//Only used for inspection question build on app side
class QuestionAnswer {
  final String title;
  final InspectionFrequency frequency;
  final DateTime? nextInspectionDate;
  final DateTime? lastInspectionDate;
  final InspectionResult? lastInspectionResult;
  final String accountId;
  final String siteId;
  final String areaId;

  InspectionResult passStatus;
  String? failureReason;
  String? correctiveAction;
  final String questionId;
  final String? inspectionId;

  QuestionAnswer({
    required this.title,
    required this.frequency,
    this.nextInspectionDate,
    this.lastInspectionDate,
    this.lastInspectionResult,
    required this.accountId,
    required this.siteId,
    required this.areaId,
    this.passStatus = InspectionResult.notSet,
    this.failureReason,
    this.correctiveAction,
    required this.questionId,
    this.inspectionId,
  });

  String? overdueStatus() {
    final now = DateTime.now();
    switch (frequency) {
      case InspectionFrequency.daily:
        return null;
      case InspectionFrequency.weekly:
        {
          final weekAgo = DateTime(now.year, now.month, now.day, 23, 59, 59)
              .subtract(const Duration(days: 7));

          if (lastInspectionDate == null ||
              lastInspectionDate!.isBefore(weekAgo)) {
            return 'Overdue';
          }
        }
      case InspectionFrequency.monthly:
        {
          final monthAgo = DateTime(now.year, now.month, now.day, 23, 59, 59)
              .subtract(const Duration(days: 30));
          if (lastInspectionDate == null ||
              lastInspectionDate!.isBefore(monthAgo)) {
            return 'Overdue';
          }
        }
      case InspectionFrequency.quarterly:
        {
          final quarterAgo = DateTime(now.year, now.month, now.day, 23, 59, 59)
              .subtract(const Duration(days: 90));
          if (lastInspectionDate == null ||
              lastInspectionDate!.isBefore(quarterAgo)) {
            return 'Overdue';
          }
        }
      case InspectionFrequency.annually:
        {
          final yearAgo = DateTime(now.year, now.month, now.day, 23, 59, 59)
              .subtract(const Duration(days: 365));
          if (lastInspectionDate == null ||
              lastInspectionDate!.isBefore(yearAgo)) {
            return 'Overdue';
          }
        }

        return null;
    }
    return null;
  }
}
