import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_all_notes_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late DeleteAllNotesUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = DeleteAllNotesUseCase(repository);
  });

  test('delegates to repository.deleteAllNotes', () async {
    when(() => repository.deleteAllNotes()).thenAnswer((_) async {});

    await useCase();

    verify(() => repository.deleteAllNotes()).called(1);
  });

  test('propagates errors from the repository', () async {
    when(() => repository.deleteAllNotes()).thenThrow(Exception('fail'));

    expect(() => useCase(), throwsException);
  });
}
