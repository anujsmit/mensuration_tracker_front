// ======================================================
// FILE:
// lib/features/notes/providers/note_provider.dart
// ======================================================

import 'package:flutter/material.dart';

import '../models/note_model.dart';

import '../services/note_service.dart';

class NoteProvider
    with ChangeNotifier {

  // ======================================================
  // SERVICE
  // ======================================================

  final NoteService _service =
      NoteService();

  // ======================================================
  // VARIABLES
  // ======================================================

  List<NoteModel> _notes = [];

  bool _isLoading = false;

  String? _error;

  // ======================================================
  // GETTERS
  // ======================================================

  List<NoteModel> get notes =>
      _notes;

  bool get isLoading =>
      _isLoading;

  String? get error =>
      _error;

  // ======================================================
  // SET LOADING
  // ======================================================

  void _setLoading(
    bool value,
  ) {

    _isLoading = value;

    notifyListeners();

  }

  // ======================================================
  // SET ERROR
  // ======================================================

  void _setError(
    String? value,
  ) {

    _error = value;

    notifyListeners();

  }

  // ======================================================
  // FETCH NOTES
  // ======================================================

  Future<void> fetchNotes()
      async {

    try {

      _setLoading(true);

      final response =
          await _service.getNotes();

      final List data =
          response.data['data'];

      _notes =
          data
              .map(
                (e) =>
                    NoteModel
                        .fromJson(e),
              )
              .toList();

      notifyListeners();

    } catch (e) {

      _setError(e.toString());

    } finally {

      _setLoading(false);

    }

  }

  // ======================================================
  // CREATE NOTE
  // ======================================================

  Future<bool> createNote({

    required String noteDate,

    String? content,

    String? mood,

    List<String>? symptoms,

    bool isPeriodDay = false,

    int padsUsed = 0,

    String? periodIntensity,

  }) async {

    try {

      _setLoading(true);

      _setError(null);

      final response =
          await _service.createNote(

        noteDate:
            noteDate,

        content:
            content,

        mood:
            mood,

        symptoms:
            symptoms,

        isPeriodDay:
            isPeriodDay,

        padsUsed:
            padsUsed,

        periodIntensity:
            periodIntensity,

      );

      final note =
          NoteModel.fromJson(
        response.data['data'],
      );

      _notes.insert(0, note);

      notifyListeners();

      return true;

    } catch (e) {

      _setError(e.toString());

      return false;

    } finally {

      _setLoading(false);

    }

  }

  // ======================================================
  // DELETE NOTE
  // ======================================================

  Future<bool> deleteNote(
    String id,
  ) async {

    try {

      _setLoading(true);

      await _service.deleteNote(
        id,
      );

      _notes.removeWhere(
        (e) => e.id == id,
      );

      notifyListeners();

      return true;

    } catch (e) {

      _setError(e.toString());

      return false;

    } finally {

      _setLoading(false);

    }

  }

}