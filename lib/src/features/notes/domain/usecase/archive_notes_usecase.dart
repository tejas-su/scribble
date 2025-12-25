import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class ArchiveNotesUseCase {
  final NotesRepository _notesRepository;
  ArchiveNotesUseCase(this._notesRepository);
  Future<void> call(int id) async {
    try {
      return await _notesRepository.archiveNote(id);
    } catch (e) {
      rethrow;
    }
  }
}
