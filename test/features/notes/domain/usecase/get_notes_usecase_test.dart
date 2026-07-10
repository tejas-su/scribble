import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_usecase.dart';
import 'notes_repository_mock.dart';

void main() {
  late MockNotesRepository repository;
  late GetNotesUseCase useCase;

  setUp(() {
    repository = MockNotesRepository();
    useCase = GetNotesUseCase(repository);
  });

  test('returns the notes from the repository', () async {
    when(
      () => repository.getNotes(
        sortByModifiedDate: any(named: 'sortByModifiedDate'),
        query: any(named: 'query'),
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => [testNote]);

    final result = await useCase();

    expect(result, [testNote]);
  });

  test('returns an empty list when the repository has no notes', () async {
    when(
      () => repository.getNotes(
        sortByModifiedDate: any(named: 'sortByModifiedDate'),
        query: any(named: 'query'),
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => []);

    final result = await useCase();

    expect(result, isEmpty);
  });

  test('forwards all filter parameters unchanged', () async {
    when(
      () => repository.getNotes(
        sortByModifiedDate: any(named: 'sortByModifiedDate'),
        query: any(named: 'query'),
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => []);

    await useCase(
      sortByModifiedDate: false,
      query: 'search term',
      onlyBookmarked: true,
      onlyDeleted: true,
      onlyArchived: true,
      limit: 5,
      offset: 10,
    );

    verify(
      () => repository.getNotes(
        sortByModifiedDate: false,
        query: 'search term',
        onlyBookmarked: true,
        onlyDeleted: true,
        onlyArchived: true,
        limit: 5,
        offset: 10,
      ),
    ).called(1);
  });

  test('propagates errors from the repository', () async {
    when(
      () => repository.getNotes(
        sortByModifiedDate: any(named: 'sortByModifiedDate'),
        query: any(named: 'query'),
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenThrow(Exception('fail'));

    expect(() => useCase(), throwsException);
  });
}
