import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/read_write_access_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late ReadWriteAccessUsecase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = ReadWriteAccessUsecase(repository);
  });

  test('makes the note read-only when isReadOnly is true', () async {
    when(() => repository.makeNoteReadOnly(any())).thenAnswer((_) async {});

    await useCase(id: 1, isReadOnly: true);

    verify(() => repository.makeNoteReadOnly(1)).called(1);
    verifyNever(() => repository.giveWriteAccess(any()));
  });

  test('gives write access when isReadOnly is false', () async {
    when(() => repository.giveWriteAccess(any())).thenAnswer((_) async {});

    await useCase(id: 1, isReadOnly: false);

    verify(() => repository.giveWriteAccess(1)).called(1);
    verifyNever(() => repository.makeNoteReadOnly(any()));
  });

  test('propagates errors from the repository', () async {
    when(() => repository.makeNoteReadOnly(any())).thenThrow(Exception('fail'));

    expect(() => useCase(id: 1, isReadOnly: true), throwsException);
  });
}
