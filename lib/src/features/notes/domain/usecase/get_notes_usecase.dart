import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class GetNotesUseCase {
  final NotesRepository _notesRepository;
  GetNotesUseCase(this._notesRepository);
  Future<List<Note>> call({
    bool sortByModifiedDate = true,
    String? query,
    bool onlyBookmarked = false,
    bool onlyDeleted = false,
    bool onlyArchived = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await _notesRepository.getNotes(
        sortByModifiedDate: sortByModifiedDate,
        onlyDeleted: onlyDeleted,
        onlyArchived: onlyArchived,
        query: query,
        onlyBookmarked: onlyBookmarked,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }
}
