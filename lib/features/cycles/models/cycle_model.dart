class CycleModel {

  final String id;

  final String userId;

  final DateTime startDate;

  final DateTime? endDate;

  final int? cycleLength;

  final int? periodLength;

  final String? notes;

  final DateTime createdAt;

  CycleModel({

    required this.id,

    required this.userId,

    required this.startDate,

    this.endDate,

    this.cycleLength,

    this.periodLength,

    this.notes,

    required this.createdAt,

  });

  // ======================================================
  // FROM JSON
  // ======================================================

  factory CycleModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return CycleModel(

      id: json['id'] ?? '',

      userId: json['user_id'] ?? '',

      startDate: DateTime.parse(
        json['start_date'],
      ),

      endDate:
          json['end_date'] != null
              ? DateTime.parse(
                  json['end_date'],
                )
              : null,

      cycleLength:
          json['cycle_length'],

      periodLength:
          json['period_length'],

      notes: json['notes'],

      createdAt: DateTime.parse(
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

      'start_date':
          startDate.toIso8601String(),

      'end_date':
          endDate?.toIso8601String(),

      'cycle_length': cycleLength,

      'period_length': periodLength,

      'notes': notes,

      'created_at':
          createdAt.toIso8601String(),

    };

  }

}