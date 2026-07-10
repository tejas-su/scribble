import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/add_note_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late AddNoteUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeNote());
  });

  setUp(() {
    repository = MockNotesRepository();
    useCase = AddNoteUseCase(repository);
  });

  test('delegates to repository.addNote with the given note', () async {
    when(() => repository.addNote(any())).thenAnswer((_) async {});

    await useCase(testNote);

    verify(() => repository.addNote(testNote)).called(1);
  });

  test('propagates errors from the repository', () async {
    when(() => repository.addNote(any())).thenThrow(Exception('db error'));

    expect(() => useCase(testNote), throwsException);
  });
}
