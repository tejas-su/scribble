import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class RestoreNotesUseCase {
  final NotesRepository _notesRepository;
  RestoreNotesUseCase(this._notesRepository);
  Future<void> call(int id,{bool isDeletedNote = false}) async {
    try {
      return await _notesRepository.restoreNote(id,isDeletedNote : isDeletedNote);
    } catch (e) {
      rethrow;
    }
  }
}
