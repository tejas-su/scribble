import 'package:scribble/src/features/notes/domain/enitities/note.dart';

abstract class NotesRepository {
  /// Add a new note
  Future<void> addNote(Note note);

  /// Update a note
  Future<void> updateNote(int id, Note note);

  /// Soft delete a note (marks as deleted without removing from database)
  Future<void> softDeleteNote(int id);

  /// Permanently delete a note from the database
  Future<void> deleteNotePermanently(int id);

  /// Permanently delete all notes from the database
  Future<void> deleteAllNotes();

  /// Unbookmark a note
  Future<void> unbookmarkNote(int id);

  /// Restore a note
  Future<void> restoreNote(int id, {bool isDeletedNote = false});

  /// Bookmark a note
  Future<void> bookmarkNote(int id);

  /// Make a note readonly
  Future<void> makeNoteReadOnly(int id);

  /// Give write access to a note
  Future<void> giveWriteAccess(int id);

  /// Archive a note
  Future<void> archiveNote(int id);

  /// Get all notes
  Future<List<Note>> getNotes({
    bool sortByModifiedDate = true,
    String? query,
    bool onlyBookmarked = false,
    bool onlyDeleted = false,
    bool onlyArchived = false,
    int limit = 20,
    int offset = 0,
  });
}
