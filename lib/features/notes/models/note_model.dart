class NoteModel {

  final String id;

  final String userId;

  final DateTime noteDate;

  final String? content;

  final String? mood;

  final List<dynamic>? symptoms;

  final bool isPeriodDay;

  final int padsUsed;

  final String? periodIntensity;

  final DateTime createdAt;

  NoteModel({

    required this.id,

    required this.userId,

    required this.noteDate,

    this.content,

    this.mood,

    this.symptoms,

    required this.isPeriodDay,

    required this.padsUsed,

    this.periodIntensity,

    required this.createdAt,

  });

  // ======================================================
  // FROM JSON
  // ======================================================

  factory NoteModel.fromJson(
    Map<String, dynamic> json,
  ) {

    return NoteModel(

      id: json['id'] ?? '',

      userId: json['user_id'] ?? '',

      noteDate: DateTime.parse(
        json['note_date'],
      ),

      content: json['content'],

      mood: json['mood'],

      symptoms:
          json['symptoms'] ?? [],

      isPeriodDay:
          json['is_period_day'] ??
              false,

      padsUsed:
          json['pads_used'] ?? 0,

      periodIntensity:
          json['period_intensity'],

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

      'note_date':
          noteDate.toIso8601String(),

      'content': content,

      'mood': mood,

      'symptoms': symptoms,

      'is_period_day':
          isPeriodDay,

      'pads_used': padsUsed,

      'period_intensity':
          periodIntensity,

      'created_at':
          createdAt.toIso8601String(),

    };

  }

}