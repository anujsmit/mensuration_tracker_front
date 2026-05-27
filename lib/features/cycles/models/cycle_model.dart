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

  factory CycleModel.fromJson(Map<String, dynamic> json) {
    return CycleModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date']) 
          : DateTime.now(),
      endDate: json['end_date'] != null && json['end_date'].toString().isNotEmpty
          ? DateTime.parse(json['end_date'])
          : null,
      cycleLength: json['cycle_length'] != null 
          ? (json['cycle_length'] as num).toInt() 
          : null,
      periodLength: json['period_length'] != null 
          ? (json['period_length'] as num).toInt() 
          : null,
      notes: json['notes']?.toString(),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  // ======================================================
  // TO JSON
  // ======================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'cycle_length': cycleLength,
      'period_length': periodLength,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // ======================================================
  // COPY WITH
  // ======================================================
  
  CycleModel copyWith({
    String? id,
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    int? periodLength,
    String? notes,
    DateTime? createdAt,
  }) {
    return CycleModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}