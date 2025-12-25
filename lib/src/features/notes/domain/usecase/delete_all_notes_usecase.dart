import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class DeleteAllNotesUseCase {
  final NotesRepository _notesRepository;
  DeleteAllNotesUseCase(this._notesRepository);
  Future<void> call() async {
    try {
      await _notesRepository.deleteAllNotes();
    } catch (e) {
      rethrow;
    }
  }
}