import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

/// Soft deletes a note (marks as deleted without removing from database)
class SoftDeleteNoteUseCase {
  final NotesRepository _notesRepository;

  SoftDeleteNoteUseCase(this._notesRepository);

  Future<void> call(int id) async {
    try {
      await _notesRepository.softDeleteNote(id);
    } catch (e) {
      rethrow;
    }
  }
}
