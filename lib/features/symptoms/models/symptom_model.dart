// ======================================================
// FILE:
// lib/features/symptoms/models/symptom_model.dart
// ======================================================

class SymptomModel {

  final String id;

  final String userId;

  final String symptomType;

  final String severity;

  final String? notes;

  final DateTime symptomDate;

  final DateTime createdAt;

  SymptomModel({

    required this.id,

    required this.userId,

    required this.symptomType,

    required this.severity,

    this.notes,

    required this.symptomDate,

    required this.createdAt,

  });

  // ======================================================
  // FROM JSON
  // ======================================================

  factory SymptomModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return SymptomModel(

      id: json['id'] ?? '',

      userId:
          json['user_id'] ?? '',

      symptomType:
          json['symptom_type'] ?? '',

      severity:
          json['severity'] ?? '',

      notes:
          json['notes'],

      symptomDate:
          DateTime.parse(
        json['symptom_date'],
      ),

      createdAt:
          DateTime.parse(
        json['created_at'],
      ),

    );

  }

  // ======================================================
  // TO JSON
  // ======================================================

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'user_id': userId,

      'symptom_type':
          symptomType,

      'severity':
          severity,

      'notes':
          notes,

      'symptom_date':
          symptomDate
              .toIso8601String(),

      'created_at':
          createdAt
              .toIso8601String(),

    };

  }

}