import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_note_permanently_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late DeleteNotePermanentlyUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = DeleteNotePermanentlyUseCase(repository);
  });

  test('delegates to repository.deleteNotePermanently with the given id', () async {
    when(() => repository.deleteNotePermanently(any())).thenAnswer((_) async {});

    await useCase(9);

    verify(() => repository.deleteNotePermanently(9)).called(1);
  });

  test('propagates errors from the repository', () async {
    when(() => repository.deleteNotePermanently(any())).thenThrow(Exception('fail'));

    expect(() => useCase(1), throwsException);
  });
}
