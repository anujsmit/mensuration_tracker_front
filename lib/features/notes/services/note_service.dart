// ======================================================
// FILE:
// lib/features/notes/services/note_service.dart
// ======================================================

import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';

class NoteService {

  final Dio dio =
      DioClient().dio;

  // ======================================================
  // CREATE NOTE
  // ======================================================

  Future<Response> createNote({

    required String noteDate,

    String? content,

    String? mood,

    List<String>? symptoms,

    bool isPeriodDay = false,

    int padsUsed = 0,

    String? periodIntensity,

  }) async {

    return await dio.post(

      '/notes',

      data: {

        'note_date':
            noteDate,

        'content':
            content,

        'mood':
            mood,

        'symptoms':
            symptoms,

        'is_period_day':
            isPeriodDay,

        'pads_used':
            padsUsed,

        'period_intensity':
            periodIntensity,

      },

    );

  }

  // ======================================================
  // GET NOTES
  // ======================================================

  Future<Response> getNotes()
      async {

    return await dio.get(
      '/notes',
    );

  }

  // ======================================================
  // DELETE NOTE
  // ======================================================

  Future<Response> deleteNote(
    String id,
  ) async {

    return await dio.delete(
      '/notes/$id',
    );

  }

}