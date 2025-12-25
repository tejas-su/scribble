import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class AddNoteUseCase {
  final NotesRepository _notesRepository;
  AddNoteUseCase(this._notesRepository);
  Future<void> call(Note note) {
    return _notesRepository.addNote(note);
  }
}
