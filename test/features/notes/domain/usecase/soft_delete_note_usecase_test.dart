import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/soft_delete_note_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late SoftDeleteNoteUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = SoftDeleteNoteUseCase(repository);
  });

  test('delegates to repository.softDeleteNote with the given id', () async {
    when(() => repository.softDeleteNote(any())).thenAnswer((_) async {});

    await useCase(11);

    verify(() => repository.softDeleteNote(11)).called(1);
  });

  test('propagates errors from the repository', () async {
    when(() => repository.softDeleteNote(any())).thenThrow(Exception('fail'));

    expect(() => useCase(1), throwsException);
  });
}
