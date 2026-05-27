// ======================================================
// FILE:
// lib/features/reports/models/report_model.dart
// ======================================================

class ReportModel {

  final int totalCycles;

  final double averageCycleLength;

  final double averagePeriodLength;

  final int totalSymptoms;

  final int totalNotes;

  final DateTime? nextPredictedPeriod;

  final List<dynamic>? symptomStats;

  final List<dynamic>? moodStats;

  ReportModel({

    required this.totalCycles,

    required this.averageCycleLength,

    required this.averagePeriodLength,

    required this.totalSymptoms,

    required this.totalNotes,

    this.nextPredictedPeriod,

    this.symptomStats,

    this.moodStats,

  });

  // ======================================================
  // FROM JSON
  // ======================================================

  factory ReportModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return ReportModel(

      totalCycles:
          json['total_cycles'] ?? 0,

      averageCycleLength:

          double.tryParse(
            json[
                    'average_cycle_length']
                .toString(),
          ) ??
              0,

      averagePeriodLength:

          double.tryParse(
            json[
                    'average_period_length']
                .toString(),
          ) ??
              0,

      totalSymptoms:
          json['total_symptoms'] ??
              0,

      totalNotes:
          json['total_notes'] ?? 0,

      nextPredictedPeriod:

          json['next_predicted_period'] !=
                  null

              ? DateTime.parse(
                  json[
                      'next_predicted_period'],
                )

              : null,

      symptomStats:
          json['symptom_stats'] ??
              [],

      moodStats:
          json['mood_stats'] ?? [],

    );

  }

}