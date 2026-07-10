import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/archive_notes_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late ArchiveNotesUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = ArchiveNotesUseCase(repository);
  });

  test('delegates to repository.archiveNote with the given id', () async {
    when(() => repository.archiveNote(any())).thenAnswer((_) async {});

    await useCase(42);

    verify(() => repository.archiveNote(42)).called(1);
  });

  test('propagates errors from the repository', () async {
    when(() => repository.archiveNote(any())).thenThrow(Exception('boom'));

    expect(() => useCase(1), throwsException);
  });
}
