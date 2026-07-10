import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';

class GetNotesCountUseCase {
  final NotesRepository _notesRepository;
  GetNotesCountUseCase(this._notesRepository);
  Future<int> call({
    bool onlyBookmarked = false,
    bool onlyDeleted = false,
    bool onlyArchived = false,
  }) async {
    try {
      return await _notesRepository.getNotesCount(
        onlyBookmarked: onlyBookmarked,
        onlyDeleted: onlyDeleted,
        onlyArchived: onlyArchived,
      );
    } catch (e) {
      rethrow;
    }
  }
}
