import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class UpdateNoteUseCase {
  final NotesRepository _notesRepository;
  UpdateNoteUseCase(this._notesRepository);
  Future<void> call(int id, Note note) {
    try {
      return _notesRepository.updateNote(id, note);
    } catch (e) {
      rethrow;
    }
  }
}
