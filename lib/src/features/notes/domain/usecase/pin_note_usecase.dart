import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class PinNoteUseCase {
  final NotesRepository _notesRepository;
  PinNoteUseCase(this._notesRepository);
  Future<void> call({required int id, required bool pin}) async {
    try {
      if (pin) {
        await _notesRepository.pinNote(id);
      } else {
        await _notesRepository.unpinNote(id);
      }
    } catch (e) {
      rethrow;
    }
  }
}
