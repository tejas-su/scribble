import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:scribble/src/features/notes/data/services/hive_notes_database.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';
import 'package:scribble/src/features/notes/domain/usecase/add_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/archive_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/bookmark_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_all_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_note_permanently_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/read_write_access_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/restore_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/soft_delete_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/update_note_usecase.dart';
import 'package:scribble/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart';
import 'package:scribble/src/features/settings/data/models/settings/settings.dart';
import 'package:scribble/src/features/settings/data/services/settings_database.dart';
import 'package:scribble/src/features/settings/presentation/bloc/settings_cubit.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

class MockHiveNotesDatabase extends Mock implements HiveNotesDatabase {}

class MockHiveSettingsDatabase extends Mock implements HiveSettingsDatabase {}

class FakeNote extends Fake implements Note {}

const testNote = Note(
  id: 1,
  title: 'title',
  content: 'content',
  modifiedAt: '2026-01-02',
  createdAt: '2026-01-01',
  isBookMarked: false,
  isArchived: false,
  isDeleted: false,
  isReadOnly: false,
);

void main() {
  // NotesBloc._onLoadNotes calls SqfliteNotesDatabaseService.instance.migrateNotes(...)
  // directly (a hardcoded singleton, not injected). That call is fire-and-forget
  // (not awaited), but it still touches the real sqflite plugin, which needs a
  // working database factory even in tests. Point it at an FFI-backed factory so
  // the migration no-ops safely instead of throwing a MissingPluginException.
  // Files land in `.dart_tool/sqflite_common_ffi/databases` (gitignored), never in
  // the app's real data directory.
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    registerFallbackValue(FakeNote());
  });

  late MockNotesRepository repository;
  late MockHiveNotesDatabase hiveDatabase;
  late MockHiveSettingsDatabase settingsDatabase;
  late SettingsCubit settingsCubit;
  late NotesBloc bloc;

  void stubGetNotes(List<Note> notes) {
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
    ).thenAnswer((_) async => notes);
  }

  Future<void> waitForLoaded() =>
      bloc.stream.firstWhere((s) => s is NotesLoadedState);

  /// Fast, singleton-free way to get the bloc into a NotesLoadedState so the
  /// reload-dependent handlers (which only act `if (currentState is
  /// NotesLoadedState)`) have something to work with.
  Future<void> bootstrapDefaultLoaded(List<Note> notes) async {
    when(() => repository.addNote(any())).thenAnswer((_) async {});
    stubGetNotes(notes);
    bloc.add(const AddNotesEvent(note: testNote));
    await waitForLoaded();
  }

  Future<void> bootstrapArchivedLoaded(List<Note> notes) async {
    stubGetNotes(notes);
    bloc.add(LoadArchivedNotesEvent());
    await waitForLoaded();
  }

  Future<void> bootstrapDeletedLoaded(List<Note> notes) async {
    stubGetNotes(notes);
    bloc.add(LoadDeletedNotesEvent());
    await waitForLoaded();
  }

  setUp(() {
    repository = MockNotesRepository();
    hiveDatabase = MockHiveNotesDatabase();
    // Keep the legacy migration a no-op insert of zero rows.
    when(() => hiveDatabase.getNotes()).thenReturn([]);

    settingsDatabase = MockHiveSettingsDatabase();
    when(() => settingsDatabase.getInitialSetting()).thenReturn(
      const Settings(isGrid: false, isDarkMode: true, sortByModifiedDate: true),
    );
    settingsCubit = SettingsCubit(settingsDatabase: settingsDatabase);

    bloc = NotesBloc(
      addNoteUseCase: AddNoteUseCase(repository),
      updateNoteUseCase: UpdateNoteUseCase(repository),
      softDeleteNoteUseCase: SoftDeleteNoteUseCase(repository),
      deleteNotePermanentlyUseCase: DeleteNotePermanentlyUseCase(repository),
      getNotesUseCase: GetNotesUseCase(repository),
      bookmarkNoteUseCase: BookmarkNoteUseCase(repository),
      archiveNotesUseCase: ArchiveNotesUseCase(repository),
      restoreNotesUseCase: RestoreNotesUseCase(repository),
      deleteAllNotesUseCase: DeleteAllNotesUseCase(repository),
      readWriteAccessUsecase: ReadWriteAccessUsecase(repository),
      hiveDatabase: hiveDatabase,
      settingsCubit: settingsCubit,
    );
  });

  tearDown(() async {
    await bloc.close();
    await settingsCubit.close();
  });

  test('initial state is NotesLoadingState', () {
    expect(bloc.state, isA<NotesLoadingState>());
  });

  group('LoadNotesEvent', () {
    test('emits [loading, loaded] with the fetched notes', () async {
      stubGetNotes([testNote]);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadingState>(),
          isA<NotesLoadedState>().having((s) => s.notes, 'notes', [testNote]),
        ]),
      );

      bloc.add(const LoadNotesEvent(sortByModifiedDate: true));
      await expectation;
    });

    test('hasMore is true when a full page is returned', () async {
      stubGetNotes(List.generate(20, (_) => testNote));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadingState>(),
          isA<NotesLoadedState>().having((s) => s.hasMore, 'hasMore', isTrue),
        ]),
      );

      bloc.add(const LoadNotesEvent(sortByModifiedDate: true));
      await expectation;
    });

    test('hasMore is false when fewer than a full page is returned', () async {
      stubGetNotes([testNote]);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadingState>(),
          isA<NotesLoadedState>().having((s) => s.hasMore, 'hasMore', isFalse),
        ]),
      );

      bloc.add(const LoadNotesEvent(sortByModifiedDate: true));
      await expectation;
    });

    test('emits [loading, error] when the legacy hive read fails', () async {
      when(() => hiveDatabase.getNotes()).thenThrow(Exception('hive read failed'));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<NotesLoadingState>(), isA<NotesErrorState>()]),
      );

      bloc.add(const LoadNotesEvent(sortByModifiedDate: true));
      await expectation;
    });

    test('emits [loading, error] when getNotesUseCase fails', () async {
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
      ).thenThrow(Exception('query failed'));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<NotesLoadingState>(), isA<NotesErrorState>()]),
      );

      bloc.add(const LoadNotesEvent(sortByModifiedDate: true));
      await expectation;
    });
  });

  group('AddNotesEvent', () {
    test('adds the note then reloads the list', () async {
      when(() => repository.addNote(any())).thenAnswer((_) async {});
      stubGetNotes([testNote]);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadingState>(),
          isA<NotesLoadedState>().having((s) => s.notes, 'notes', [testNote]),
        ]),
      );

      bloc.add(const AddNotesEvent(note: testNote));
      await expectation;

      verify(() => repository.addNote(testNote)).called(1);
    });

    test('emits an error state when adding fails', () async {
      when(() => repository.addNote(any())).thenThrow(Exception('insert failed'));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([isA<NotesLoadingState>(), isA<NotesErrorState>()]),
      );

      bloc.add(const AddNotesEvent(note: testNote));
      await expectation;
    });
  });

  group('UpdateNotesEvent', () {
    test('when no notes are loaded yet, updates but never reloads (no emit)', () async {
      when(() => repository.updateNote(any(), any())).thenAnswer((_) async {});

      bloc.add(const UpdateNotesEvent(note: testNote, id: 1));
      await Future<void>.delayed(Duration.zero);

      verify(() => repository.updateNote(1, testNote)).called(1);
      expect(bloc.state, isA<NotesLoadingState>());
    });

    test('after notes are loaded, updates then reloads the current view', () async {
      await bootstrapDefaultLoaded([testNote]);
      when(() => repository.updateNote(any(), any())).thenAnswer((_) async {});
      stubGetNotes([testNote, testNote]);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadedState>().having((s) => s.notes.length, 'notes.length', 2),
        ]),
      );

      bloc.add(const UpdateNotesEvent(note: testNote, id: 1));
      await expectation;
    });

    test('emits an error state when the update fails', () async {
      await bootstrapDefaultLoaded([testNote]);
      when(() => repository.updateNote(any(), any())).thenThrow(Exception('fail'));

      final expectation = expectLater(bloc.stream, emitsInOrder([isA<NotesErrorState>()]));

      bloc.add(const UpdateNotesEvent(note: testNote, id: 1));
      await expectation;
    });
  });

  group('DeleteAllNotesevent', () {
    test('emits an empty loaded state', () async {
      when(() => repository.deleteAllNotes()).thenAnswer((_) async {});

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadedState>().having((s) => s.notes, 'notes', isEmpty),
        ]),
      );

      bloc.add(DeleteAllNotesevent());
      await expectation;
    });

    test('emits an error state on failure', () async {
      when(() => repository.deleteAllNotes()).thenThrow(Exception('fail'));

      final expectation = expectLater(bloc.stream, emitsInOrder([isA<NotesErrorState>()]));

      bloc.add(DeleteAllNotesevent());
      await expectation;
    });
  });

  group('BookmarkNotesEvent', () {
    test('bookMark: true calls bookmarkNote and reloads', () async {
      await bootstrapDefaultLoaded([testNote]);
      // Reloading with the exact same notes list would produce a
      // NotesLoadedState equal (via Equatable) to the current one, which
      // Bloc silently skips re-emitting -- so wait on the mocked call
      // itself rather than on a subsequent stream event.
      final bookmarked = Completer<void>();
      when(() => repository.bookmarkNote(any())).thenAnswer((_) async {
        bookmarked.complete();
      });
      stubGetNotes([testNote]);

      bloc.add(const BookmarkNotesEvent(id: 1, bookMark: true));
      await bookmarked.future;

      verify(() => repository.bookmarkNote(1)).called(1);
    });

    test('bookMark: false calls unbookmarkNote and reloads', () async {
      await bootstrapDefaultLoaded([testNote]);
      final unbookmarked = Completer<void>();
      when(() => repository.unbookmarkNote(any())).thenAnswer((_) async {
        unbookmarked.complete();
      });
      stubGetNotes([testNote]);

      bloc.add(const BookmarkNotesEvent(id: 1, bookMark: false));
      await unbookmarked.future;

      verify(() => repository.unbookmarkNote(1)).called(1);
    });
  });

  group('SearchNotesEvent (debounced)', () {
    test('an empty query resets searchQuery to null', () async {
      stubGetNotes([testNote]);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadedState>().having((s) => s.searchQuery, 'searchQuery', isNull),
        ]),
      );

      bloc.add(const SearchNotesEvent(query: ''));
      await expectation;
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('only the latest query in a rapid burst is executed', () async {
      stubGetNotes([testNote]);

      bloc
        ..add(const SearchNotesEvent(query: 'a'))
        ..add(const SearchNotesEvent(query: 'ab'))
        ..add(const SearchNotesEvent(query: 'abc'));

      final state = await bloc.stream.firstWhere((s) => s is NotesLoadedState)
          as NotesLoadedState;

      expect(state.searchQuery, 'abc');
      verify(
        () => repository.getNotes(
          sortByModifiedDate: any(named: 'sortByModifiedDate'),
          query: 'abc',
          onlyBookmarked: any(named: 'onlyBookmarked'),
          onlyDeleted: any(named: 'onlyDeleted'),
          onlyArchived: any(named: 'onlyArchived'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
      verifyNever(
        () => repository.getNotes(
          sortByModifiedDate: any(named: 'sortByModifiedDate'),
          query: 'a',
          onlyBookmarked: any(named: 'onlyBookmarked'),
          onlyDeleted: any(named: 'onlyDeleted'),
          onlyArchived: any(named: 'onlyArchived'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      );
    }, timeout: const Timeout(Duration(seconds: 2)));
  });

  group('LoadMoreNotesEvent', () {
    test('does nothing when there is no loaded state yet', () async {
      bloc.add(const LoadMoreNotesEvent());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, isA<NotesLoadingState>());
      verifyNever(
        () => repository.getNotes(
          sortByModifiedDate: any(named: 'sortByModifiedDate'),
          query: any(named: 'query'),
          onlyBookmarked: any(named: 'onlyBookmarked'),
          onlyDeleted: any(named: 'onlyDeleted'),
          onlyArchived: any(named: 'onlyArchived'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      );
    });

    test('does nothing when hasMore is already false', () async {
      // Fewer than a page => hasMore is false.
      await bootstrapDefaultLoaded([testNote]);
      clearInteractions(repository);

      bloc.add(const LoadMoreNotesEvent());
      await Future<void>.delayed(Duration.zero);

      verifyNever(
        () => repository.getNotes(
          sortByModifiedDate: any(named: 'sortByModifiedDate'),
          query: any(named: 'query'),
          onlyBookmarked: any(named: 'onlyBookmarked'),
          onlyDeleted: any(named: 'onlyDeleted'),
          onlyArchived: any(named: 'onlyArchived'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      );
    });

    test('appends the next page and accumulates the offset', () async {
      await bootstrapDefaultLoaded(List.generate(20, (_) => testNote));
      stubGetNotes(List.generate(5, (_) => testNote));

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadedState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
          isA<NotesLoadedState>()
              .having((s) => s.notes.length, 'notes.length', 25)
              .having((s) => s.hasMore, 'hasMore', isFalse)
              .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse),
        ]),
      );

      bloc.add(const LoadMoreNotesEvent());
      await expectation;
    });

    test('turns off isLoadingMore and keeps prior notes when the next page fails', () async {
      await bootstrapDefaultLoaded(List.generate(20, (_) => testNote));
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

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadedState>().having((s) => s.isLoadingMore, 'isLoadingMore', isTrue),
          isA<NotesLoadedState>()
              .having((s) => s.isLoadingMore, 'isLoadingMore', isFalse)
              .having((s) => s.notes.length, 'notes.length', 20),
        ]),
      );

      bloc.add(const LoadMoreNotesEvent());
      await expectation;
    });
  });

  group('LoadDeletedNotesEvent / LoadArchivedNotesEvent / LoadBookmarkedNotesEvent', () {
    test('LoadDeletedNotesEvent requests onlyDeleted and flags isDeleted', () async {
      stubGetNotes([testNote]);

      bloc.add(LoadDeletedNotesEvent());
      final loaded = await bloc.stream.firstWhere((s) => s is NotesLoadedState)
          as NotesLoadedState;

      expect(loaded.isDeleted, isTrue);
      verify(
        () => repository.getNotes(
          sortByModifiedDate: any(named: 'sortByModifiedDate'),
          query: any(named: 'query'),
          onlyBookmarked: any(named: 'onlyBookmarked'),
          onlyDeleted: true,
          onlyArchived: any(named: 'onlyArchived'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(greaterThanOrEqualTo(1));
    });

    test('LoadArchivedNotesEvent requests onlyArchived and flags isArchived', () async {
      stubGetNotes([testNote]);

      bloc.add(LoadArchivedNotesEvent());
      final loaded = await bloc.stream.firstWhere((s) => s is NotesLoadedState)
          as NotesLoadedState;

      expect(loaded.isArchived, isTrue);
    });

    test('LoadBookmarkedNotesEvent requests onlyBookmarked and flags isBookmarked', () async {
      stubGetNotes([testNote]);

      bloc.add(LoadBookmarkedNotesEvent());
      final loaded = await bloc.stream.firstWhere((s) => s is NotesLoadedState)
          as NotesLoadedState;

      expect(loaded.isBookmarked, isTrue);
      expect(loaded.isDeleted, isFalse);
      expect(loaded.isArchived, isFalse);
    });

    test('LoadDeletedNotesEvent emits an error state on failure', () async {
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

      final expectation = expectLater(bloc.stream, emitsInOrder([isA<NotesErrorState>()]));
      bloc.add(LoadDeletedNotesEvent());
      await expectation;
    });
  });

  group('DeleteNotesEvent', () {
    test('softDelete: true calls softDeleteNoteUseCase', () async {
      await bootstrapDefaultLoaded([testNote]);
      when(() => repository.softDeleteNote(any())).thenAnswer((_) async {});
      stubGetNotes([]);

      bloc.add(const DeleteNotesEvent(id: 1, softDelete: true));
      await bloc.stream.first;

      verify(() => repository.softDeleteNote(1)).called(1);
      verifyNever(() => repository.deleteNotePermanently(any()));
    });

    test('softDelete: false calls deleteNotePermanentlyUseCase', () async {
      await bootstrapDefaultLoaded([testNote]);
      when(() => repository.deleteNotePermanently(any())).thenAnswer((_) async {});
      stubGetNotes([]);

      bloc.add(const DeleteNotesEvent(id: 1, softDelete: false));
      await bloc.stream.first;

      verify(() => repository.deleteNotePermanently(1)).called(1);
      verifyNever(() => repository.softDeleteNote(any()));
    });

    test('reloads the deleted list when currently viewing deleted notes', () async {
      await bootstrapDeletedLoaded([testNote]);
      clearInteractions(repository); // drop the getNotes call made by the bootstrap itself
      when(() => repository.deleteNotePermanently(any())).thenAnswer((_) async {});
      stubGetNotes([]);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadedState>().having((s) => s.isDeleted, 'isDeleted', isTrue),
        ]),
      );

      bloc.add(const DeleteNotesEvent(id: 1, softDelete: false));
      await expectation;

      verify(
        () => repository.getNotes(
          sortByModifiedDate: any(named: 'sortByModifiedDate'),
          query: any(named: 'query'),
          onlyBookmarked: any(named: 'onlyBookmarked'),
          onlyDeleted: true,
          onlyArchived: any(named: 'onlyArchived'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).called(1);
    });

    test('reloads the archived list when currently viewing archived notes', () async {
      await bootstrapArchivedLoaded([testNote]);
      when(() => repository.softDeleteNote(any())).thenAnswer((_) async {});
      stubGetNotes([]);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotesLoadedState>().having((s) => s.isArchived, 'isArchived', isTrue),
        ]),
      );

      bloc.add(const DeleteNotesEvent(id: 1, softDelete: true));
      await expectation;
    });

    test('does nothing when there is no loaded state yet', () async {
      when(() => repository.softDeleteNote(any())).thenAnswer((_) async {});

      bloc.add(const DeleteNotesEvent(id: 1, softDelete: true));
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state, isA<NotesLoadingState>());
    });
  });

  group('RestoreNotesEvent', () {
    test('isDeletedNote: true restores from the deleted list', () async {
      await bootstrapDeletedLoaded([testNote]);
      when(() => repository.restoreNote(any(), isDeletedNote: any(named: 'isDeletedNote')))
          .thenAnswer((_) async {});
      stubGetNotes([]);

      bloc.add(const RestoreNotesEvent(id: 1, isDeletedNote: true));
      await bloc.stream.first;

      verify(() => repository.restoreNote(1, isDeletedNote: true)).called(1);
    });

    test('isDeletedNote: false restores from the archived list', () async {
      await bootstrapArchivedLoaded([testNote]);
      when(() => repository.restoreNote(any(), isDeletedNote: any(named: 'isDeletedNote')))
          .thenAnswer((_) async {});
      stubGetNotes([]);

      bloc.add(const RestoreNotesEvent(id: 1, isDeletedNote: false));
      await bloc.stream.first;

      verify(() => repository.restoreNote(1, isDeletedNote: false)).called(1);
    });
  });

  group('ArchiveNotesEvent', () {
    test('archives the note and reloads the current (default) view', () async {
      await bootstrapDefaultLoaded([testNote]);
      when(() => repository.archiveNote(any())).thenAnswer((_) async {});
      stubGetNotes([]);

      bloc.add(const ArchiveNotesEvent(id: 1));
      final loaded = await bloc.stream.firstWhere((s) => s is NotesLoadedState)
          as NotesLoadedState;

      verify(() => repository.archiveNote(1)).called(1);
      expect(loaded.isArchived, isFalse);
      expect(loaded.isDeleted, isFalse);
    });
  });

  group('GiveReadWriteAccessEvent', () {
    test('isReadOnly: true makes the note read-only then reloads', () async {
      await bootstrapDefaultLoaded([testNote]);
      // Same equal-state caveat as BookmarkNotesEvent above: wait on the
      // mocked call instead of a subsequent stream event.
      final readOnlySet = Completer<void>();
      when(() => repository.makeNoteReadOnly(any())).thenAnswer((_) async {
        readOnlySet.complete();
      });
      stubGetNotes([testNote]);

      bloc.add(const GiveReadWriteAccessEvent(id: 1, isReadOnly: true));
      await readOnlySet.future;

      verify(() => repository.makeNoteReadOnly(1)).called(1);
    });

    test('isReadOnly: false gives write access then reloads', () async {
      await bootstrapDefaultLoaded([testNote]);
      final writeAccessGiven = Completer<void>();
      when(() => repository.giveWriteAccess(any())).thenAnswer((_) async {
        writeAccessGiven.complete();
      });
      stubGetNotes([testNote]);

      bloc.add(const GiveReadWriteAccessEvent(id: 1, isReadOnly: false));
      await writeAccessGiven.future;

      verify(() => repository.giveWriteAccess(1)).called(1);
    });

    test(
      'documents a real gap: from the deleted view, _reloadCurrentView falls back '
      'to the default (non-deleted) query instead of preserving the deleted filter',
      () async {
        await bootstrapDeletedLoaded([testNote]);
        when(() => repository.makeNoteReadOnly(any())).thenAnswer((_) async {});
        stubGetNotes([testNote]);

        bloc.add(const GiveReadWriteAccessEvent(id: 1, isReadOnly: true));
        final loaded = await bloc.stream.firstWhere((s) => s is NotesLoadedState)
            as NotesLoadedState;

        // Unlike _onDeleteNotes/_onRestoreNotes/_onArchiveNotes (which check
        // isDeleted explicitly), the shared _reloadCurrentView helper used here
        // only branches on isArchived/isBookmarked, so isDeleted is silently lost.
        expect(loaded.isDeleted, isFalse);
        verify(
          () => repository.getNotes(
            sortByModifiedDate: any(named: 'sortByModifiedDate'),
            query: any(named: 'query'),
            onlyBookmarked: any(named: 'onlyBookmarked'),
            onlyDeleted: false,
            onlyArchived: any(named: 'onlyArchived'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).called(1);
      },
    );
  });
}
