import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class ReadWriteAccessUsecase {
  final NotesRepository _notesRepository;
  ReadWriteAccessUsecase(this._notesRepository);
  Future<void> call({required int id, required bool isReadOnly}) async {
    try {
      if (isReadOnly) {
        await _notesRepository.makeNoteReadOnly(id);
      } else {
        await _notesRepository.giveWriteAccess(id);
      }
    } catch (e) {
      rethrow;
    }
  }
}
