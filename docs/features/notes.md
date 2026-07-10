# Notes

## Overview

Notes are the core feature of Scribble: free-form title + content entries that can be created,
edited, searched, sorted, bookmarked, archived, soft-deleted (trash), permanently deleted, and
marked read-only. Notes are persisted in SQLite and loaded with pagination.

## User-facing behavior

- **Create** — tap the floating action button on the Notes tab to open a blank editor
  ([lib/src/features/notes/presentation/screen/new_notes_screen.dart](../../lib/src/features/notes/presentation/screen/new_notes_screen.dart)).
  The note is saved automatically when the screen is popped, *if* the title or content is
  non-empty.
- **Edit** — tap any note card to open it in
  [UpdateNotesScreen](../../lib/src/features/notes/presentation/screen/update_note_screen.dart).
  Like creation, saving happens on pop (`PopScope.onPopInvokedWithResult`), not via an explicit
  save button.
- **Read-only lock** — tap the lock icon in the editor app bar to toggle a note between editable
  and read-only. Read-only notes render their `TextField`s with `readOnly: true`.
- **Bookmark** — tap the bookmark icon in the editor, or use the long-press context menu on a
  note card. Bookmarked notes show a bookmark badge on their card and are accessible from the
  drawer's "Bookmarks" entry.
- **Archive** — long-press a note card → "Archive". Archived notes are hidden from the main list
  and accessible from the drawer's "Archived" entry, from where they can be restored or deleted.
- **Delete (soft)** — long-press a note card → "Delete". This is a *soft* delete (`isDeleted =
  1`); the note moves to the drawer's "Deleted" (trash) list and can be restored.
- **Delete (permanent)** — from the "Deleted" list, long-press → "Delete Permanently" removes the
  row from SQLite entirely. There is no confirmation dialog on this action.
- **Restore** — from "Archived" or "Deleted" lists, long-press → "Restore" clears the
  `isArchived`/`isDeleted` flag.
- **Search** — type into the search bar at the top of the Notes tab. Matches title and content
  (case-insensitive `LIKE`), and matched substrings are highlighted in yellow in the results.
  Search is debounced by 500 ms and only active on the main list (hidden on
  Deleted/Archived/Bookmarked views).
- **Sort** — tap the filter icon next to the search bar to choose "Modified Date" or "Created
  Date" via a bottom sheet. The preference is persisted in Settings and reused for future loads.
- **Grid / List view** — toggled from Settings, affects the whole notes list (`MasonryGridView`
  with 1 or 2 columns).
- **Share** — share a note's title/content via the platform share sheet (`share_plus`), from the
  editor app bar or the long-press menu.
- **Delete all** — Settings → Danger zone → "Delete" wipes every note (with a confirmation
  dialog). This bypasses soft-delete entirely.
- **Infinite scroll** — scrolling past 80% of the list triggers loading the next page (20 notes
  at a time).

## Data model

### Domain entity — `Note`

[lib/src/features/notes/domain/enitities/note.dart](../../lib/src/features/notes/domain/enitities/note.dart)

```dart
class Note extends Equatable {
  final int? id;
  final String title;
  final String content;
  final String modifiedAt;   // ISO 8601 string
  final String createdAt;    // ISO 8601 string
  final bool isBookMarked;
  final bool isArchived;
  final bool isDeleted;
  final bool isReadOnly;
}
```

This is the framework-agnostic entity used by the domain layer (use cases, repository interface)
and the presentation layer (bloc, screens).

### SQLite schema

Table `notes`, created by `SqfliteNotesDatabaseService._createDB`
([lib/src/features/notes/data/services/sqflite_notes_database_service.dart:35-56](../../lib/src/features/notes/data/services/sqflite_notes_database_service.dart)):

| Column | Type | Notes |
|---|---|---|
| `id` | `INTEGER PRIMARY KEY AUTOINCREMENT` | |
| `title` | `TEXT NOT NULL` | |
| `content` | `TEXT NOT NULL` | |
| `modifiedAt` | `TEXT NOT NULL` | ISO 8601 |
| `createdAt` | `TEXT NOT NULL` | ISO 8601 |
| `isBookMarked` | `INTEGER NOT NULL DEFAULT 0` | boolean as 0/1 |
| `isArchived` | `INTEGER NOT NULL DEFAULT 0` | boolean as 0/1 |
| `isDeleted` | `INTEGER NOT NULL DEFAULT 0` | boolean as 0/1, soft-delete flag |
| `isReadOnly` | `INTEGER NOT NULL DEFAULT 0` | added in schema v2 via `_onUpgrade` |

Indexes: `idx_date` (`modifiedAt`), `idx_createdAt` (`createdAt`), `idx_bookmark`
(`isBookmarked`), `idx_archived` (`isArchived`), `idx_title_content` (`title, content`).

Database file: `notes.db`, current schema `version: 2`. `_onUpgrade` adds the `isReadOnly`
column when upgrading from v1.

### Legacy Hive model — `Notes`

[lib/src/features/notes/data/models/notes/notes.dart](../../lib/src/features/notes/data/models/notes/notes.dart)
— `@HiveType(typeId: 1)`, fields: `title`, `date`, `content`, `isBookmarked`, plus a
UI-only `isSelected` (not persisted, no `@HiveField`). Read via `HiveNotesDatabase`
([lib/src/features/notes/data/services/hive_notes_database.dart](../../lib/src/features/notes/data/services/hive_notes_database.dart),
itself annotated `@Deprecated('Use sqflite instead')`), kept only so any legacy notes still in the
Hive `notes` box can be migrated to SQLite. Not used for new notes.

## Architecture

```
notes/
├── data/
│   ├── models/
│   │   ├── migration_notes/notes_model.dart   # NotesModel — SQLite row <-> Note entity mapper
│   │   └── notes/notes.dart                   # Legacy Hive model (migration source only)
│   ├── repository/notes_repository_impl.dart  # NotesRepositoryImpl
│   └── services/
│       ├── sqflite_notes_database_service.dart  # Raw SQLite access (singleton)
│       └── hive_notes_database.dart             # Reads the legacy Hive box for migration
├── domain/
│   ├── enitities/note.dart                    # Note entity
│   ├── repository/notes_repository.dart        # NotesRepository interface
│   └── usecase/                                # One class per operation (see below)
└── presentation/
    ├── bloc/notes_bloc/                        # NotesBloc, NotesEvent, NotesState
    ├── screen/                                 # notes_screen, new_notes_screen, update_note_screen, notes_loading_screen
    └── widgets/                                # notes_card.dart, empty_placeholder.dart
```

### Use cases

Each wraps a single `NotesRepository` method as a callable class
(`lib/src/features/notes/domain/usecase/`):

`AddNoteUseCase`, `UpdateNoteUseCase`, `SoftDeleteNoteUseCase`, `DeleteNotePermanentlyUseCase`,
`DeleteAllNotesUseCase`, `GetNotesUseCase`, `BookmarkNoteUseCase`, `ArchiveNotesUseCase`,
`RestoreNotesUseCase`, `ReadWriteAccessUsecase`.

### `NotesRepository` interface

[lib/src/features/notes/domain/repository/notes_repository.dart](../../lib/src/features/notes/domain/repository/notes_repository.dart)
declares `addNote`, `updateNote`, `softDeleteNote`, `deleteNotePermanently`, `deleteAllNotes`,
`unbookmarkNote`, `restoreNote`, `bookmarkNote`, `makeNoteReadOnly`, `giveWriteAccess`,
`archiveNote`, and `getNotes(...)` with filter/sort/pagination parameters. Implemented by
`NotesRepositoryImpl`, which delegates every call to `SqfliteNotesDatabaseService`.

### State management — `NotesBloc`

[lib/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart](../../lib/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart)

**Events** (`notes_event.dart`): `LoadNotesEvent`, `AddNotesEvent`, `UpdateNotesEvent`,
`DeleteAllNotesevent`, `BookmarkNotesEvent`, `SearchNotesEvent`, `LoadMoreNotesEvent`,
`LoadDeletedNotesEvent`, `LoadArchivedNotesEvent`, `DeleteNotesEvent` (has a `softDelete` flag),
`RestoreNotesEvent` (has an `isDeletedNote` flag to distinguish trash-restore from
archive-restore), `ArchiveNotesEvent`, `LoadBookmarkedNotesEvent`, `GiveReadWriteAccessEvent`.

**States** (`notes_state.dart`): `NotesLoadingState`, `NotesLoadedState` (carries `notes`,
`searchQuery`, `hasMore`, `isLoadingMore`, and the mutually-relevant `isDeleted` / `isArchived` /
`isBookmarked` view flags), `NotesErrorState`.

**Key behaviors:**

- Pagination: `_pageSize = 20`. `_currentOffset` tracks how many notes are loaded;
  `LoadMoreNotesEvent` fetches the next page and appends it.
- Search debouncing: `SearchNotesEvent` is registered with a custom `EventTransformer` that
  debounces 500 ms and uses `switchMap` (cancels in-flight searches when a new query arrives) —
  see `_searchNotesTransformer`.
- View-aware reload: `_reloadCurrentView` re-fetches the list appropriate to whatever the current
  `NotesLoadedState` represents (archived / bookmarked / normal) after a mutation like bookmark
  toggle or read/write access change, so the visible list stays consistent after an action.
- `NotesBloc` depends on `SettingsCubit` (constructor injection) to read the
  `sortByModifiedDate` preference — see [Settings](settings.md).

### Key widgets

- `NotesCard` ([lib/src/features/notes/presentation/widgets/notes_card.dart](../../lib/src/features/notes/presentation/widgets/notes_card.dart))
  — the note tile. Renders title/content with `buildHighlightedText` (search highlighting), the
  formatted date, and an optional bookmark badge icon.
- `EmptyPlaceholder` — shown when the current list (respecting search/filter) is empty.
- `NotesLoadingScreen` — loading state placeholder (shimmer).
- Long-press on a card opens `showMenuOverlay`
  ([lib/src/core/utils/menu_overlay.dart](../../lib/src/core/utils/menu_overlay.dart)), a custom
  positioned overlay (not a `PopupMenuButton`) offering Delete/Bookmark/Share/Archive, or
  Restore/Delete-permanently when viewing Archived/Deleted lists.

## Edge cases / gotchas

- **Migration runs on every load, not once.** `NotesBloc._onLoadNotes` re-reads the legacy Hive
  `notes` box and calls `SqfliteNotesDatabaseService.migrateNotes` (marked `@Deprecated`) on
  *every* `LoadNotesEvent`, not just the first app launch. Since Hive notes are never deleted
  after migrating, if any legacy notes remain in the box, they'll be re-inserted as **new**
  SQLite rows (duplicates) each time the notes screen reloads (e.g., after navigating back from
  Todos). In practice this only matters for installs upgrading from a pre-v4.0 Hive-only version;
  the box is typically empty for fresh installs.
- **Save-on-pop, not save-on-type.** Both the create and edit screens only persist when the
  screen is popped (back gesture/button), via `PopScope.onPopInvokedWithResult`. There's no
  autosave while typing, and no explicit "Save" button.
- **No confirmation on permanent delete.** "Delete Permanently" from the trash view fires
  immediately with no confirmation dialog (unlike "Delete all notes" in Settings, which does
  confirm).
- **Read-only doesn't block the toolbar.** Marking a note read-only only sets `readOnly: true` on
  the `TextField`s; bookmark/lock/share actions in the app bar remain tappable.
- **`Note.props` excludes `id`, `isDeleted`, and `isReadOnly`.** `Note`'s `Equatable.props`
  ([lib/src/features/notes/domain/enitities/note.dart:34-42](../../lib/src/features/notes/domain/enitities/note.dart))
  omits `id`, `isDeleted`, and `isReadOnly` — two `Note` instances that differ only in those
  fields compare equal. This mainly affects Bloc state-change detection/tests, not persistence.

## Related files

| Purpose | File |
|---|---|
| Entity | [note.dart](../../lib/src/features/notes/domain/enitities/note.dart) |
| Repository interface | [notes_repository.dart](../../lib/src/features/notes/domain/repository/notes_repository.dart) |
| Repository impl | [notes_repository_impl.dart](../../lib/src/features/notes/data/repository/notes_repository_impl.dart) |
| SQLite service | [sqflite_notes_database_service.dart](../../lib/src/features/notes/data/services/sqflite_notes_database_service.dart) |
| Legacy Hive service | [hive_notes_database.dart](../../lib/src/features/notes/data/services/hive_notes_database.dart) |
| Bloc | [notes_bloc.dart](../../lib/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart) |
| List screen | [notes_screen.dart](../../lib/src/features/notes/presentation/screen/notes_screen.dart) |
| Create screen | [new_notes_screen.dart](../../lib/src/features/notes/presentation/screen/new_notes_screen.dart) |
| Edit screen | [update_note_screen.dart](../../lib/src/features/notes/presentation/screen/update_note_screen.dart) |
| Note card widget | [notes_card.dart](../../lib/src/features/notes/presentation/widgets/notes_card.dart) |
| Search highlighting | [text_highlight_util.dart](../../lib/src/core/utils/text_highlight_util.dart) |
| Long-press menu | [menu_overlay.dart](../../lib/src/core/utils/menu_overlay.dart) |
| Sort picker | [sort_modal_bottom_sheet.dart](../../lib/src/core/utils/sort_modal_bottom_sheet.dart) |
| Share helper | [share_plus_util.dart](../../lib/src/core/utils/share_plus_util.dart) |

## Tests

`test/features/notes/` covers: entity (`domain/entities/note_test.dart`), models
(`data/models/notes_model_test.dart`, `notes_test.dart`), repository
(`data/repository/notes_repository_impl_test.dart`), every use case
(`domain/usecase/*_usecase_test.dart`, with `notes_repository_mock.dart` as a `mocktail`-based
fake), and the bloc (`presentation/bloc/notes_bloc_test.dart`).
