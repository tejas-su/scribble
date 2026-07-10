# Architecture

## Overview

Scribble is organized **feature-first**: each top-level capability (`notes`, `todos`, `settings`,
`home`) owns its own `data`, `domain`, and `presentation` folders rather than the codebase being
split into global `models/`, `blocs/`, `screens/` folders. This keeps everything related to one
feature close together.

```
lib/src/features/<feature>/
├── data/
│   ├── models/           # Persistence-layer models (Hive @HiveType, or DB row mappers)
│   ├── repository/       # Repository implementations (notes only)
│   └── services/         # Database access (Hive box / sqflite)
├── domain/
│   ├── enitities/         # Framework-agnostic entities (notes only) [sic — folder is spelled "enitities"]
│   ├── repository/       # Repository interfaces (notes only)
│   └── usecase/          # One class per operation (notes only)
└── presentation/
    ├── bloc/              # Bloc or Cubit + events/states
    ├── screen/            # Full-page widgets
    └── widgets/           # Reusable feature-local widgets
```

**Notes** is the only feature with a full domain layer (entities, repository interface, use
cases) — it's the most complex feature and the one that migrated from Hive to SQLite, so the
extra indirection paid for itself. **Todos** and **Settings** talk to their Hive database service
directly from their Bloc/Cubit, skipping the domain layer, since they're single-table, low-complexity
features.

## State management: flutter_bloc

Every feature exposes state via `flutter_bloc`:

| Feature | State holder | Type |
|---|---|---|
| Notes | `NotesBloc` ([lib/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart](../lib/src/features/notes/presentation/bloc/notes_bloc/notes_bloc.dart)) | `Bloc<NotesEvent, NotesState>` |
| Notes count (drawer badges) | `NotesCountCubit` ([lib/src/features/notes/presentation/bloc/notes_count_cubit/notes_count_cubit.dart](../lib/src/features/notes/presentation/bloc/notes_count_cubit/notes_count_cubit.dart)) | `Cubit<NotesCountState>` |
| Todos | `TodosBloc` ([lib/src/features/todos/presentation/bloc/todos_bloc/todos_bloc.dart](../lib/src/features/todos/presentation/bloc/todos_bloc/todos_bloc.dart)) | `Bloc<TodosEvent, TodosState>` |
| Settings | `SettingsCubit` ([lib/src/features/settings/presentation/bloc/settings_cubit.dart](../lib/src/features/settings/presentation/bloc/settings_cubit.dart)) | `Cubit<Settings>` |
| Home page switching | `PageViewCubit` ([lib/src/features/home/presentation/bloc/page_view_cubit.dart](../lib/src/features/home/presentation/bloc/page_view_cubit.dart)) | `Cubit<int>` |

All blocs/cubits are provided once at the app root via `MultiBlocProvider` in
[lib/main.dart](../lib/main.dart), so any screen can reach them with `context.read<T>()` /
`context.watch<T>()`. `SettingsCubit` is provided first because `NotesBloc` reads the initial
sort preference from it at construction time. `NotesCountCubit` is provided right after
`NotesBloc` because it reads `context.read<NotesBloc>()` at construction and subscribes to its
stream to keep the drawer's count badges live.

Sealed classes (`sealed class NotesEvent`, `sealed class NotesState`) are used for events/states
so `switch` expressions in the UI are exhaustive and compiler-checked.

## Local storage

Two different local databases are used, split by data shape and history:

- **SQLite (`sqflite`)** — used only for **notes** (`SqfliteNotesDatabaseService`,
  [lib/src/features/notes/data/services/sqflite_notes_database_service.dart](../lib/src/features/notes/data/services/sqflite_notes_database_service.dart)).
  Notes moved from Hive to SQLite in v4.0 to support full-text-ish search (`LIKE` queries),
  pagination (`LIMIT`/`OFFSET`), and indexed sorting/filtering. See
  [Notes → Data model](features/notes.md#data-model) for the schema.
- **Hive (`hive_flutter`)** — used for **todos** and **settings**, and also kept around for notes
  as a one-time migration source (see below). Hive is a fast key-value/object box store; it fits
  todos/settings well because they're small, simple, and don't need querying.

All Hive boxes are opened once in `main()` before `runApp`:

```dart
await Hive.initFlutter(directory.path);
Hive.registerAdapter(NotesAdapter());
Hive.registerAdapter(SettingsAdapter());
Hive.registerAdapter(TodosAdapter());
Box<Notes> notesBox = await HiveNotesDatabase.openBox('notes');
Box<Todos> todosBox = await HiveTodosDatabase.openBox('todos');
Box<Settings> settingsBox = await HiveSettingsDatabase.openBox('settings');
```

([lib/main.dart:30-44](../lib/main.dart))

### One-time Notes migration (Hive → SQLite)

Legacy installs had notes stored in Hive (`Notes` model,
[lib/src/features/notes/data/models/notes/notes.dart](../lib/src/features/notes/data/models/notes/notes.dart)).
On every `LoadNotesEvent`, `NotesBloc` reads whatever is left in the Hive `notes` box and
re-inserts it into the SQLite `notes` table via the `@Deprecated` `migrateNotes()` batch insert
(`SqfliteNotesDatabaseService.migrateNotes`). This is effectively a repeated best-effort backfill
rather than a one-shot migration with a completion flag — see
[Notes → Edge cases](features/notes.md#edge-cases--gotchas) for the implications.

## Navigation

There is no named-route table or router package. Navigation is plain `Navigator.push` with
`MaterialPageRoute` (e.g. opening `NewNotesScreen`, `UpdateNotesScreen`, `SettingsScreen`). The
two main tabs (Notes, Todos) are not separate routes — they're pages inside a single
non-swipeable `PageView` on `HomeScreen`, switched programmatically via `PageController` +
`PageViewCubit`. See [Home & Navigation](features/home-navigation.md).

## Theming

Light/dark themes are defined in
[lib/src/core/themes/themes.dart](../lib/src/core/themes/themes.dart) using Material 3
`ColorScheme.fromSeed`. `SettingsCubit.state.isDarkMode` drives `MaterialApp.themeMode`.

## Cross-feature utilities (`lib/src/core`)

| File | Purpose |
|---|---|
| `utils/extensions.dart` | `String.yMMMEdFormat` — formats ISO date strings for display |
| `utils/text_highlight_util.dart` | Builds a `TextSpan` that highlights search-query matches |
| `utils/menu_overlay.dart` | Custom long-press context menu (delete/bookmark/share/archive/restore) |
| `utils/sort_modal_bottom_sheet.dart` | Bottom sheet for choosing sort order (modified vs. created date) |
| `utils/share_plus_util.dart` | Wraps `share_plus` to share a note's title/content |
| `utils/alert_dialog.dart` | Reusable confirmation dialog (used by Settings' danger zone) |
| `utils/custom_snackbar.dart` | Reusable snackbar helper |
| `utils/constants.dart` | Shared constant values |

## Testing

Tests live under `test/`, mirroring the `lib/src/features/...` structure. Coverage is heaviest
for **notes**: entities, models, repository, all use cases, and the bloc are all tested (with
`mocktail` for mocking and `sqflite_common_ffi` for an in-memory SQLite implementation in tests).
Settings and todos have model + bloc tests; home has a `PageViewCubit` test. There are no widget
or integration tests — coverage is unit-level (domain/data/bloc), not UI-level.

## Dependency injection

There is no DI framework (no `get_it`, `provider` service locator, etc.). Wiring happens by hand
in `MyApp.build()` in [lib/main.dart](../lib/main.dart): repositories and use cases are
constructed inline and passed into each Bloc's constructor via `BlocProvider`.
