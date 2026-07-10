import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/bookmark_note_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late BookmarkNoteUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = BookmarkNoteUseCase(repository);
  });

  test('calls bookmarkNote when bookMark is true', () async {
    when(() => repository.bookmarkNote(any())).thenAnswer((_) async {});

    await useCase(id: 1, bookMark: true);

    verify(() => repository.bookmarkNote(1)).called(1);
    verifyNever(() => repository.unbookmarkNote(any()));
  });

  test('calls unbookmarkNote when bookMark is false', () async {
    when(() => repository.unbookmarkNote(any())).thenAnswer((_) async {});

    await useCase(id: 1, bookMark: false);

    verify(() => repository.unbookmarkNote(1)).called(1);
    verifyNever(() => repository.bookmarkNote(any()));
  });

  test('propagates errors from the repository', () async {
    when(() => repository.bookmarkNote(any())).thenThrow(Exception('fail'));

    expect(() => useCase(id: 1, bookMark: true), throwsException);
  });
}
