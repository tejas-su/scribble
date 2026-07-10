import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/notes/data/services/hive_notes_database.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/repository/notes_repository.dart';
import 'package:scribble/src/features/notes/domain/usecase/add_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/archive_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/bookmark_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_all_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_note_permanently_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_count_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/pin_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/read_write_access_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/restore_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/soft_delete_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/update_note_usecase.dart';
import 'package:scribble/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart';
import 'package:scribble/src/features/notes/presentation/bloc/notes_count_cubit/notes_count_cubit.dart';
import 'package:scribble/src/features/settings/data/models/settings/settings.dart';
import 'package:scribble/src/features/settings/data/services/settings_database.dart';
import 'package:scribble/src/features/settings/presentation/bloc/settings_cubit.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

class MockHiveNotesDatabase extends Mock implements HiveNotesDatabase {}

class MockHiveSettingsDatabase extends Mock implements HiveSettingsDatabase {}

const testNote = Note(
  id: 1,
  title: 'title',
  content: 'content',
  modifiedAt: '2026-01-02',
  createdAt: '2026-01-01',
  isBookMarked: false,
  isPinned: false,
  isArchived: false,
  isDeleted: false,
  isReadOnly: false,
);

void main() {
  late MockNotesRepository repository;
  late MockHiveNotesDatabase hiveDatabase;
  late MockHiveSettingsDatabase settingsDatabase;
  late SettingsCubit settingsCubit;
  late NotesBloc notesBloc;
  late GetNotesCountUseCase getNotesCountUseCase;

  void stubCounts({
    required int notesCount,
    required int archivedCount,
    required int bookmarkedCount,
  }) {
    when(
      () => repository.getNotesCount(
        onlyBookmarked: false,
        onlyDeleted: false,
        onlyArchived: false,
      ),
    ).thenAnswer((_) async => notesCount);
    when(
      () => repository.getNotesCount(
        onlyBookmarked: false,
        onlyDeleted: false,
        onlyArchived: true,
      ),
    ).thenAnswer((_) async => archivedCount);
    when(
      () => repository.getNotesCount(
        onlyBookmarked: true,
        onlyDeleted: false,
        onlyArchived: false,
      ),
    ).thenAnswer((_) async => bookmarkedCount);
  }

  setUp(() {
    repository = MockNotesRepository();
    hiveDatabase = MockHiveNotesDatabase();
    when(() => hiveDatabase.getNotes()).thenReturn([]);

    settingsDatabase = MockHiveSettingsDatabase();
    when(() => settingsDatabase.getInitialSetting()).thenReturn(
      const Settings(isGrid: false, isDarkMode: true, sortByModifiedDate: true),
    );
    settingsCubit = SettingsCubit(settingsDatabase: settingsDatabase);

    notesBloc = NotesBloc(
      addNoteUseCase: AddNoteUseCase(repository),
      updateNoteUseCase: UpdateNoteUseCase(repository),
      softDeleteNoteUseCase: SoftDeleteNoteUseCase(repository),
      deleteNotePermanentlyUseCase: DeleteNotePermanentlyUseCase(repository),
      getNotesUseCase: GetNotesUseCase(repository),
      bookmarkNoteUseCase: BookmarkNoteUseCase(repository),
      pinNoteUseCase: PinNoteUseCase(repository),
      archiveNotesUseCase: ArchiveNotesUseCase(repository),
      restoreNotesUseCase: RestoreNotesUseCase(repository),
      deleteAllNotesUseCase: DeleteAllNotesUseCase(repository),
      readWriteAccessUsecase: ReadWriteAccessUsecase(repository),
      hiveDatabase: hiveDatabase,
      settingsCubit: settingsCubit,
    );

    getNotesCountUseCase = GetNotesCountUseCase(repository);
  });

  tearDown(() async {
    await notesBloc.close();
    await settingsCubit.close();
  });

  test('initial state is all zero counts', () {
    stubCounts(notesCount: 0, archivedCount: 0, bookmarkedCount: 0);
    final cubit = NotesCountCubit(
      getNotesCountUseCase: getNotesCountUseCase,
      notesBloc: notesBloc,
    );
    addTearDown(cubit.close);

    expect(cubit.state.notesCount, 0);
    expect(cubit.state.archivedCount, 0);
    expect(cubit.state.bookmarkedCount, 0);
  });

  test('fetches counts on creation', () async {
    stubCounts(notesCount: 5, archivedCount: 2, bookmarkedCount: 1);
    final cubit = NotesCountCubit(
      getNotesCountUseCase: getNotesCountUseCase,
      notesBloc: notesBloc,
    );
    addTearDown(cubit.close);

    await cubit.stream.firstWhere((s) => s.notesCount == 5);

    expect(cubit.state.notesCount, 5);
    expect(cubit.state.archivedCount, 2);
    expect(cubit.state.bookmarkedCount, 1);
  });

  test('refreshes counts whenever NotesBloc emits a new state', () async {
    stubCounts(notesCount: 5, archivedCount: 2, bookmarkedCount: 1);
    final cubit = NotesCountCubit(
      getNotesCountUseCase: getNotesCountUseCase,
      notesBloc: notesBloc,
    );
    addTearDown(cubit.close);
    await cubit.stream.firstWhere((s) => s.notesCount == 5);

    // Update the underlying counts and trigger a NotesBloc emission.
    stubCounts(notesCount: 6, archivedCount: 3, bookmarkedCount: 1);
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

    notesBloc.add(LoadArchivedNotesEvent());

    await cubit.stream.firstWhere((s) => s.archivedCount == 3);

    expect(cubit.state.notesCount, 6);
    expect(cubit.state.archivedCount, 3);
  });

  test('keeps the previous state when a refresh fails', () async {
    stubCounts(notesCount: 5, archivedCount: 2, bookmarkedCount: 1);
    final cubit = NotesCountCubit(
      getNotesCountUseCase: getNotesCountUseCase,
      notesBloc: notesBloc,
    );
    addTearDown(cubit.close);
    await cubit.stream.firstWhere((s) => s.notesCount == 5);

    when(
      () => repository.getNotesCount(
        onlyBookmarked: any(named: 'onlyBookmarked'),
        onlyDeleted: any(named: 'onlyDeleted'),
        onlyArchived: any(named: 'onlyArchived'),
      ),
    ).thenThrow(Exception('count failed'));

    await cubit.refreshCounts();

    expect(cubit.state.notesCount, 5);
    expect(cubit.state.archivedCount, 2);
    expect(cubit.state.bookmarkedCount, 1);
  });
}
