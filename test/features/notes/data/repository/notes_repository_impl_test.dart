import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/data/models/migration_notes/notes_model.dart';
import 'package:scribble/src/features/notes/data/repository/notes_repository_impl.dart';
import 'package:scribble/src/features/notes/data/services/sqflite_notes_database_service.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';

class MockSqfliteNotesDatabaseService extends Mock
    implements SqfliteNotesDatabaseService {}

class FakeNotesModel extends Fake implements NotesModel {}

void main() {
  late MockSqfliteNotesDatabaseService service;
  late NotesRepositoryImpl repository;

  const note = Note(
    id: 1,
    title: 'title',
    content: 'content',
    modifiedAt: '2026-01-01',
    createdAt: '2026-01-01',
    isBookMarked: false,
    isPinned: false,
    isArchived: false,
    isDeleted: false,
    isReadOnly: false,
  );

  setUpAll(() {
    registerFallbackValue(FakeNotesModel());
  });

  setUp(() {
    service = MockSqfliteNotesDatabaseService();
    repository = NotesRepositoryImpl(service);
  });

  test('addNote converts the entity and inserts it', () async {
    when(() => service.insertNote(any())).thenAnswer((_) async => 1);

    await repository.addNote(note);

    final captured = verify(() => service.insertNote(captureAny())).captured;
    final inserted = captured.single as NotesModel;
    expect(inserted.title, note.title);
    expect(inserted.id, note.id);
  });

  test('addNote propagates errors from the service', () async {
    when(() => service.insertNote(any())).thenThrow(Exception('insert failed'));

    expect(() => repository.addNote(note), throwsException);
  });

  test('updateNote converts the entity and forwards the id', () async {
    when(() => service.updateNote(any(), any())).thenAnswer((_) async => 1);

    await repository.updateNote(2, note);

    verify(() => service.updateNote(2, any())).called(1);
  });

  test('archiveNote forwards the id', () async {
    when(() => service.archiveNote(any())).thenAnswer((_) async => 1);
    await repository.archiveNote(5);
    verify(() => service.archiveNote(5)).called(1);
  });

  test('softDeleteNote forwards the id', () async {
    when(() => service.softDeleteNote(any())).thenAnswer((_) async => 1);
    await repository.softDeleteNote(5);
    verify(() => service.softDeleteNote(5)).called(1);
  });

  test('deleteNotePermanently forwards the id', () async {
    when(() => service.deleteNote(any())).thenAnswer((_) async => 1);
    await repository.deleteNotePermanently(5);
    verify(() => service.deleteNote(5)).called(1);
  });

  test('deleteAllNotes delegates to the service', () async {
    when(() => service.deleteAllNotes()).thenAnswer((_) async {});
    await repository.deleteAllNotes();
    verify(() => service.deleteAllNotes()).called(1);
  });

  test('bookmarkNote forwards the id', () async {
    when(() => service.bookmarkNote(any())).thenAnswer((_) async => 1);
    await repository.bookmarkNote(5);
    verify(() => service.bookmarkNote(5)).called(1);
  });

  test('unbookmarkNote forwards the id', () async {
    when(() => service.unbookmarkNote(any())).thenAnswer((_) async => 1);
    await repository.unbookmarkNote(5);
    verify(() => service.unbookmarkNote(5)).called(1);
  });

  test('pinNote forwards the id', () async {
    when(() => service.pinNote(any())).thenAnswer((_) async => 1);
    await repository.pinNote(5);
    verify(() => service.pinNote(5)).called(1);
  });

  test('unpinNote forwards the id', () async {
    when(() => service.unpinNote(any())).thenAnswer((_) async => 1);
    await repository.unpinNote(5);
    verify(() => service.unpinNote(5)).called(1);
  });

  test('makeNoteReadOnly forwards the id', () async {
    when(() => service.makeNoteReadOnly(any())).thenAnswer((_) async => 1);
    await repository.makeNoteReadOnly(5);
    verify(() => service.makeNoteReadOnly(5)).called(1);
  });

  test('giveWriteAccess forwards the id', () async {
    when(() => service.giveWriteAccess(any())).thenAnswer((_) async => 1);
    await repository.giveWriteAccess(5);
    verify(() => service.giveWriteAccess(5)).called(1);
  });

  test('restoreNote calls restoreDeletedNote when isDeletedNote is true', () async {
    when(() => service.restoreDeletedNote(any())).thenAnswer((_) async => 1);

    await repository.restoreNote(5, isDeletedNote: true);

    verify(() => service.restoreDeletedNote(5)).called(1);
    verifyNever(() => service.restoreArchivedNote(any()));
  });

  test('restoreNote calls restoreArchivedNote when isDeletedNote is false', () async {
    when(() => service.restoreArchivedNote(any())).thenAnswer((_) async => 1);

    await repository.restoreNote(5);

    verify(() => service.restoreArchivedNote(5)).called(1);
    verifyNever(() => service.restoreDeletedNote(any()));
  });

  test('getNotes forwards all filter parameters and maps results', () async {
    when(
      () => service.getNotes(
        sortByModifiedDate: any(named: 'sortByModifiedDate'),
        query: any(named: 'query'),
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => [NotesModel.fromEntity(note)]);

    final result = await repository.getNotes(
      sortByModifiedDate: false,
      query: 'q',
      onlyBookmarked: true,
      onlyDeleted: true,
      onlyArchived: true,
      limit: 3,
      offset: 6,
    );

    expect(result.length, 1);
    expect(result.first.title, note.title);
    verify(
      () => service.getNotes(
        sortByModifiedDate: false,
        query: 'q',
        onlyBookmarked: true,
        onlyDeleted: true,
        onlyArchived: true,
        limit: 3,
        offset: 6,
      ),
    ).called(1);
  });

  test('getNotes propagates errors from the service', () async {
    when(
      () => service.getNotes(
        sortByModifiedDate: any(named: 'sortByModifiedDate'),
        query: any(named: 'query'),
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenThrow(Exception('query failed'));

    expect(() => repository.getNotes(), throwsException);
  });

  test('getNotesCount forwards all filter parameters and returns the count', () async {
    when(
      () => service.getNotesCount(
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
      ),
    ).thenAnswer((_) async => 4);

    final result = await repository.getNotesCount(
      onlyBookmarked: true,
      onlyDeleted: true,
      onlyArchived: true,
    );

    expect(result, 4);
    verify(
      () => service.getNotesCount(
        onlyBookmarked: true,
        onlyDeleted: true,
        onlyArchived: true,
      ),
    ).called(1);
  });

  test('getNotesCount propagates errors from the service', () async {
    when(
      () => service.getNotesCount(
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
      ),
    ).thenThrow(Exception('count failed'));

    expect(() => repository.getNotesCount(), throwsException);
  });
}
