import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_count_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late GetNotesCountUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = GetNotesCountUseCase(repository);
  });

  test('returns the count from the repository', () async {
    when(
      () => repository.getNotesCount(
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
      ),
    ).thenAnswer((_) async => 7);

    final result = await useCase();

    expect(result, 7);
  });

  test('forwards all filter parameters unchanged', () async {
    when(
      () => repository.getNotesCount(
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
      ),
    ).thenAnswer((_) async => 0);

    await useCase(onlyBookmarked: true, onlyDeleted: true, onlyArchived: true);

    verify(
      () => repository.getNotesCount(
        onlyBookmarked: true,
        onlyDeleted: true,
        onlyArchived: true,
      ),
    ).called(1);
  });

  test('propagates errors from the repository', () async {
    when(
      () => repository.getNotesCount(
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
      ),
    ).thenThrow(Exception('fail'));

    expect(() => useCase(), throwsException);
  });
}
