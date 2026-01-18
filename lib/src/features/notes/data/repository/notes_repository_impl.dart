import 'package:scribble/src/features/notes/data/models/migration_notes/notes_model.dart';
import 'package:scribble/src/features/notes/data/services/sqflite_notes_database_service.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class NotesRepositoryImpl implements NotesRepository {
  final SqfliteNotesDatabaseService _sqfliteNotesDatabaseService;
  NotesRepositoryImpl(this._sqfliteNotesDatabaseService);
  @override
  Future<void> addNote(Note note) async {
    try {
      await _sqfliteNotesDatabaseService.insertNote(
        NotesModel.fromEntity(note),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> archiveNote(int id) async {
    try {
      await _sqfliteNotesDatabaseService.archiveNote(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> softDeleteNote(int id) async {
    try {
      await _sqfliteNotesDatabaseService.softDeleteNote(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteNotePermanently(int id) async {
    try {
      await _sqfliteNotesDatabaseService.deleteNote(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteAllNotes() async {
    try {
      await _sqfliteNotesDatabaseService.deleteAllNotes();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Note>> getNotes({
    bool sortByModifiedDate = true,
    bool onlyDeleted = false,
    bool onlyArchived = false,
    String? query,
    bool onlyBookmarked = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final notes = await _sqfliteNotesDatabaseService.getNotes(
        sortByModifiedDate: sortByModifiedDate,
        query: query,
        onlyBookmarked: onlyBookmarked,
        onlyDeleted: onlyDeleted,
        onlyArchived: onlyArchived,
        limit: limit,
        offset: offset,
      );
      return notes;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateNote(int id, Note note) async {
    try {
      await _sqfliteNotesDatabaseService.updateNote(
        id,
        NotesModel.fromEntity(note),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> bookmarkNote(int id) async {
    try {
      await _sqfliteNotesDatabaseService.bookmarkNote(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unbookmarkNote(int id) async {
    try {
      await _sqfliteNotesDatabaseService.unbookmarkNote(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> giveWriteAccess(int id) async {
    try {
      await _sqfliteNotesDatabaseService.giveWriteAccess(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> makeNoteReadOnly(int id) async {
    try {
      await _sqfliteNotesDatabaseService.makeNoteReadOnly(id);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> restoreNote(int id, {bool isDeletedNote = false}) {
    try {
      if (isDeletedNote) {
        return _sqfliteNotesDatabaseService.restoreDeletedNote(id);
      } else {
        return _sqfliteNotesDatabaseService.restoreArchivedNote(id);
      }
    } catch (e) {
      rethrow;
    }
  }
}
