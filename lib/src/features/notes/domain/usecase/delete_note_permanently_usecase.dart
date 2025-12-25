import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

/// Permanently deletes a note from the database
class DeleteNotePermanentlyUseCase {
  final NotesRepository _notesRepository;

  DeleteNotePermanentlyUseCase(this._notesRepository);

  Future<void> call(int id) async {
    try {
      await _notesRepository.deleteNotePermanently(id);
    } catch (e) {
      rethrow;
    }
  }
}
