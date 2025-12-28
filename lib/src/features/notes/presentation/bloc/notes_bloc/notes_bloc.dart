import 'dart:async';
import 'package:scribble/src/features/notes/domain/usecase/delete_all_notes_usecase.dart';
import 'package:stream_transform/stream_transform.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:scribble/src/features/notes/data/models/migration_notes/notes_model.dart';
import 'package:scribble/src/features/notes/data/services/sqflite_notes_database_service.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';
import 'package:scribble/src/features/notes/domain/usecase/add_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/bookmark_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/soft_delete_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/delete_note_permanently_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/get_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/update_note_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/archive_notes_usecase.dart';
import 'package:scribble/src/features/notes/domain/usecase/restore_notes_usecase.dart';
import 'package:scribble/src/features/settings/presentation/bloc/settings_cubit.dart';
import '../../../data/models/notes/notes.dart';
import '../../../data/services/hive_notes_database.dart';
part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final AddNoteUseCase addNoteUseCase;
  final UpdateNoteUseCase updateNoteUseCase;
  final SoftDeleteNoteUseCase softDeleteNoteUseCase;
  final DeleteNotePermanentlyUseCase deleteNotePermanentlyUseCase;
  final GetNotesUseCase getNotesUseCase;
  final BookmarkNoteUseCase bookmarkNoteUseCase;
  final ArchiveNotesUseCase archiveNotesUseCase;
  final RestoreNotesUseCase restoreNotesUseCase;
  final DeleteAllNotesUseCase deleteAllNotesUseCase;
  final HiveNotesDatabase hiveDatabase;
  final SettingsCubit settingsCubit;

  // Pagination tracking
  int _currentOffset = 0;
  String? _currentQuery;
  static const int _pageSize = 20;

  NotesBloc({
    required this.addNoteUseCase,
    required this.updateNoteUseCase,
    required this.softDeleteNoteUseCase,
    required this.deleteNotePermanentlyUseCase,
    required this.getNotesUseCase,
    required this.bookmarkNoteUseCase,
    required this.archiveNotesUseCase,
    required this.restoreNotesUseCase,
    required this.deleteAllNotesUseCase,
    required this.hiveDatabase,
    required this.settingsCubit,
  }) : super(NotesLoadingState()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNotesEvent>(_onAddNotes);
    on<UpdateNotesEvent>(_onUpdateNotes);
    on<DeleteAllNotesevent>(_deleteAllNotes);
    on<BookmarkNotesEvent>(_onBookmarkNotes);
    on<SearchNotesEvent>(_onSearchNotes, transformer: _searchNotesTransformer);
    on<LoadMoreNotesEvent>(_onLoadMoreNotes);
    on<LoadDeletedNotesEvent>(_onLoadDeletedNotes);
    on<LoadArchivedNotesEvent>(_onLoadArchivedNotes);
    on<DeleteNotesEvent>(_onDeleteNotes);
    on<RestoreNotesEvent>(_onRestoreNotes);
    on<ArchiveNotesEvent>(_onArchiveNotes);
    on<LoadBookmarkedNotesEvent>(_onLoadBookmarkedNotes);
  }
  //load the notes
  Future<void> _onLoadNotes(
    LoadNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    emit(NotesLoadingState());
    _currentOffset = 0;
    _currentQuery = null;

    try {
      final List<Notes> notesToMigrate = hiveDatabase.getNotes();

      //Migrate the notes to sql database
      SqfliteNotesDatabaseService.instance.migrateNotes(
        notesToMigrate
            .map(
              (note) => NotesModel(
                content: note.content,
                title: note.title,
                modifiedAt: note.date,
                createdAt: note.date,
                isBookMarked: note.isBookmarked,
                isArchived: false,
                isDeleted: false,
              ),
            )
            .toList(),
      );

      //Get the notes from sql database with pagination
      final List<Note> notes = await getNotesUseCase(
        limit: _pageSize,
        offset: _currentOffset,
        sortByModifiedDate: event.sortByModifiedDate,
      );

      _currentOffset += notes.length;

      emit(
        NotesLoadedState(
          notes: notes,
          searchQuery: _currentQuery,
          hasMore: notes.length == _pageSize,
          isDeleted: false,
          isArchived: false,
        ),
      );
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //add the notes
  void _onAddNotes(AddNotesEvent event, Emitter<NotesState> emit) async {
    emit(NotesLoadingState());
    _currentOffset = 0;
    _currentQuery = null;

    try {
      await addNoteUseCase(event.note);
      final bool sortByModifiedDate = settingsCubit.state.sortByModifiedDate;
      final List<Note> notes = await getNotesUseCase(
        limit: _pageSize,
        offset: 0,
        sortByModifiedDate: sortByModifiedDate,
      );
      _currentOffset = notes.length;
      emit(
        NotesLoadedState(
          notes: notes,
          searchQuery: _currentQuery,
          hasMore: notes.length == _pageSize,
        ),
      );
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //update the notes
  void _onUpdateNotes(UpdateNotesEvent event, Emitter<NotesState> emit) async {
    try {
      await updateNoteUseCase(event.id, event.note);
      await _reloadCurrentView(emit);
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //Delete all notes from the database
  Future<void> _deleteAllNotes(
    NotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await deleteAllNotesUseCase();
      emit(const NotesLoadedState(notes: [], searchQuery: null));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //Bookmark the notes
  FutureOr<void> _onBookmarkNotes(
    BookmarkNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await bookmarkNoteUseCase(id: event.id, bookMark: event.bookMark);
      await _reloadCurrentView(emit);
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  Future<void> _onSearchNotes(
    SearchNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    // Reset pagination when search query changes
    _currentOffset = 0;
    _currentQuery = event.query.isEmpty ? null : event.query;

    try {
      final bool sortByModifiedDate = settingsCubit.state.sortByModifiedDate;
      final List<Note> notes = await getNotesUseCase(
        query: _currentQuery,
        limit: _pageSize,
        offset: 0,
        sortByModifiedDate: sortByModifiedDate,
      );

      _currentOffset = notes.length;
      emit(
        NotesLoadedState(
          notes: notes,
          searchQuery: _currentQuery,
          hasMore: notes.length == _pageSize,
        ),
      );
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  // Load more notes for pagination
  Future<void> _onLoadMoreNotes(
    LoadMoreNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    final currentState = state;
    if (currentState is! NotesLoadedState) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    // Show loading indicator
    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final bool sortByModifiedDate = settingsCubit.state.sortByModifiedDate;
      final List<Note> moreNotes = await getNotesUseCase(
        query: event.query,
        limit: _pageSize,
        offset: _currentOffset,
        sortByModifiedDate: sortByModifiedDate,
      );

      _currentOffset += moreNotes.length;

      emit(
        NotesLoadedState(
          notes: [...currentState.notes, ...moreNotes],
          searchQuery: _currentQuery,
          hasMore: moreNotes.length == _pageSize,
          isLoadingMore: false,
        ),
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  FutureOr<void> _onLoadDeletedNotes(
    LoadDeletedNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    _currentOffset = 0; // Reset offset when loading deleted notes
    try {
      final List<Note> moreNotes = await getNotesUseCase(
        onlyDeleted: true,
        limit: _pageSize,
        offset: 0,
      );
      _currentOffset = moreNotes.length;
      emit(
        NotesLoadedState(
          isDeleted: true,
          notes: moreNotes,
          searchQuery: _currentQuery,
          hasMore: moreNotes.length == _pageSize,
        ),
      );
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onLoadArchivedNotes(
    LoadArchivedNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    _currentOffset = 0; // Reset offset when loading archived notes
    try {
      final List<Note> moreNotes = await getNotesUseCase(
        onlyArchived: true,
        limit: _pageSize,
        offset: 0,
      );
      _currentOffset = moreNotes.length;
      emit(
        NotesLoadedState(
          isArchived: true,
          notes: moreNotes,
          searchQuery: _currentQuery,
          hasMore: moreNotes.length == _pageSize,
        ),
      );
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //Debounce the search notes
  Stream<SearchNotesEvent> _searchNotesTransformer(
    Stream<SearchNotesEvent> events,
    EventMapper<SearchNotesEvent> mapper,
  ) {
    return events.debounce(const Duration(milliseconds: 500)).switchMap(mapper);
  }

  /// Reloads notes based on current view state (archived, bookmarked, or regular)
  Future<void> _reloadCurrentView(
    Emitter<NotesState> emit, {
    bool? sortByModifiedDate,
  }) async {
    final currentState = state;
    if (currentState is! NotesLoadedState) return;

    final bool sort =
        sortByModifiedDate ?? settingsCubit.state.sortByModifiedDate;
    final int limit = _currentOffset > 0 ? _currentOffset : _pageSize;

    try {
      if (currentState.isArchived) {
        final notes = await getNotesUseCase(
          onlyArchived: true,
          limit: limit,
          offset: 0,
          sortByModifiedDate: sort,
        );
        emit(
          NotesLoadedState(
            notes: notes,
            searchQuery: _currentQuery,
            hasMore:
                _currentOffset > notes.length || notes.length % _pageSize == 0,
            isArchived: true,
          ),
        );
      } else if (currentState.isBookmarked) {
        final notes = await getNotesUseCase(
          onlyBookmarked: true,
          limit: limit,
          offset: 0,
          sortByModifiedDate: sort,
        );
        emit(
          NotesLoadedState(
            notes: notes,
            searchQuery: _currentQuery,
            hasMore:
                _currentOffset > notes.length || notes.length % _pageSize == 0,
            isBookmarked: true,
          ),
        );
      } else {
        final notes = await getNotesUseCase(
          query: _currentQuery,
          limit: limit,
          offset: 0,
          sortByModifiedDate: sort,
        );
        emit(
          NotesLoadedState(
            notes: notes,
            searchQuery: _currentQuery,
            hasMore:
                _currentOffset > notes.length || notes.length % _pageSize == 0,
          ),
        );
      }
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  ///Delete the notes, soft delete or hard delete
  FutureOr<void> _onDeleteNotes(
    DeleteNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    final currentState = state;
    try {
      if (event.softDelete) {
        await softDeleteNoteUseCase(event.id);
      } else {
        await deleteNotePermanentlyUseCase(event.id);
      }

      // Reload the appropriate list based on current state
      if (currentState is NotesLoadedState) {
        final bool sortByModifiedDate = settingsCubit.state.sortByModifiedDate;
        //The notes loaded state has the isDeleted and isArchived flags
        //So we can reload the appropriate list based on the current state
        if (currentState.isDeleted) {
          final List<Note> notes = await getNotesUseCase(
            onlyDeleted: true,
            limit: _pageSize,
            offset: 0,
            sortByModifiedDate: sortByModifiedDate,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
              isDeleted: true,
            ),
          );
        } else if (currentState.isArchived) {
          final List<Note> notes = await getNotesUseCase(
            onlyArchived: true,
            limit: _pageSize,
            offset: 0,
            sortByModifiedDate: sortByModifiedDate,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
              isArchived: true,
            ),
          );
        } else {
          final List<Note> notes = await getNotesUseCase(
            limit: _pageSize,
            offset: 0,
            sortByModifiedDate: sortByModifiedDate,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
            ),
          );
        }
      }
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onRestoreNotes(
    RestoreNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    final currentState = state;
    try {
      await restoreNotesUseCase(event.id, isDeletedNote: event.isDeletedNote);

      // Reload the appropriate list based on current state
      if (currentState is NotesLoadedState) {
        if (currentState.isDeleted) {
          final List<Note> notes = await getNotesUseCase(
            onlyDeleted: true,
            limit: _pageSize,
            offset: 0,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
              isDeleted: true,
            ),
          );
        } else if (currentState.isArchived) {
          final List<Note> notes = await getNotesUseCase(
            onlyArchived: true,
            limit: _pageSize,
            offset: 0,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
              isArchived: true,
            ),
          );
        } else {
          final List<Note> notes = await getNotesUseCase(
            limit: _pageSize,
            offset: 0,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
            ),
          );
        }
      }
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onArchiveNotes(
    ArchiveNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    final currentState = state;
    try {
      await archiveNotesUseCase(event.id);

      // Reload the appropriate list based on current state
      if (currentState is NotesLoadedState) {
        if (currentState.isDeleted) {
          final List<Note> notes = await getNotesUseCase(
            onlyDeleted: true,
            limit: _pageSize,
            offset: 0,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
              isDeleted: true,
            ),
          );
        } else if (currentState.isArchived) {
          final List<Note> notes = await getNotesUseCase(
            onlyArchived: true,
            limit: _pageSize,
            offset: 0,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
              isArchived: true,
            ),
          );
        } else {
          final List<Note> notes = await getNotesUseCase(
            limit: _pageSize,
            offset: 0,
          );
          emit(
            NotesLoadedState(
              notes: notes,
              searchQuery: _currentQuery,
              hasMore: notes.length == _pageSize,
            ),
          );
        }
      }
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  FutureOr<void> _onLoadBookmarkedNotes(
    LoadBookmarkedNotesEvent event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final List<Note> notes = await getNotesUseCase(
        onlyBookmarked: true,
        limit: _pageSize,
        offset: 0,
      );
      emit(
        NotesLoadedState(
          notes: notes,
          searchQuery: _currentQuery,
          hasMore: notes.length == _pageSize,
          isBookmarked: true,
          isDeleted: false,
          isArchived: false,
        ),
      );
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }
}
