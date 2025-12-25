import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class BookmarkNoteUseCase {
  final NotesRepository _notesRepository;
  BookmarkNoteUseCase(this._notesRepository);
  Future<void> call({required int id, required bool bookMark}) async {
    try {
      if (bookMark) {
        await _notesRepository.bookmarkNote(id);
      } else {
        await _notesRepository.unbookmarkNote(id);
      }
    } catch (e) {
      rethrow;
    }
  }
}
