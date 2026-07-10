import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/restore_notes_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late RestoreNotesUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = RestoreNotesUseCase(repository);
  });

  test('defaults isDeletedNote to false when not supplied', () async {
    when(
      () => repository.restoreNote(any(), isDeletedNote: any(named: 'isDeletedNote')),
    ).thenAnswer((_) async {});

    await useCase(3);

    verify(() => repository.restoreNote(3, isDeletedNote: false)).called(1);
  });

  test('forwards isDeletedNote: true', () async {
    when(
      () => repository.restoreNote(any(), isDeletedNote: any(named: 'isDeletedNote')),
    ).thenAnswer((_) async {});

    await useCase(3, isDeletedNote: true);

    verify(() => repository.restoreNote(3, isDeletedNote: true)).called(1);
  });

  test('propagates errors from the repository', () async {
    when(
      () => repository.restoreNote(any(), isDeletedNote: any(named: 'isDeletedNote')),
    ).thenThrow(Exception('fail'));

    expect(() => useCase(1), throwsException);
  });
}
