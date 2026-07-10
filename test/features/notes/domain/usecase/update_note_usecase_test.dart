import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/update_note_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late UpdateNoteUseCase useCase;

  setUpAll(() {
    registerFallbackValue(FakeNote());
  });

  setUp(() {
    repository = MockNotesRepository();
    useCase = UpdateNoteUseCase(repository);
  });

  test('delegates to repository.updateNote with id and note', () async {
    when(() => repository.updateNote(any(), any())).thenAnswer((_) async {});

    await useCase(4, testNote);

    verify(() => repository.updateNote(4, testNote)).called(1);
  });

  test('propagates errors from the repository', () async {
    when(() => repository.updateNote(any(), any())).thenThrow(Exception('fail'));

    expect(() => useCase(1, testNote), throwsException);
  });
}
