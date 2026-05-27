class HealthProfileModel {

  final String id;

  final String userId;

  final int? age;

  final int? cycleLength;

  final DateTime? lastPeriodDate;

  final int? bleedingDuration;

  final String? flowRegularity;

  const HealthProfileModel({

    required this.id,

    required this.userId,

    this.age,

    this.cycleLength,

    this.lastPeriodDate,

    this.bleedingDuration,

    this.flowRegularity,
  });

  factory HealthProfileModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return HealthProfileModel(

      id: json['id'],

      userId:
          json['user_id'],

      age:
          json['age'],

      cycleLength:
          json['cycle_length'],

      bleedingDuration:
          json['bleeding_duration'],

      flowRegularity:
          json['flow_regularity'],

      lastPeriodDate:
          json['last_period_date'] != null

              ? DateTime.parse(
                  json['last_period_date'],
                )

              : null,
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'id': id,

      'user_id': userId,

      'age': age,

      'cycle_length':
          cycleLength,

      'bleeding_duration':
          bleedingDuration,

      'flow_regularity':
          flowRegularity,

      'last_period_date':
          lastPeriodDate
              ?.toIso8601String(),
    };
  }
}