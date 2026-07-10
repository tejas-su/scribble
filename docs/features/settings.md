# Settings

## Overview

App-wide preferences: theme, notes layout, notes sort order, plus "danger zone" bulk-delete
actions for notes and todos. Backed by a single-record Hive box — there's exactly one `Settings`
object for the whole app (no per-user or per-device profiles).

## User-facing behavior

Reached via the drawer's "Settings" entry
([ScribbleDrawer](../../lib/src/features/home/presentation/widgets/scribble_drawer.dart), pushed
as a `MaterialPageRoute`).

- **Theme** — tap the "Theme" row to toggle between light and dark. There is no "follow system"
  option; `MaterialApp.themeMode` is always explicitly `ThemeMode.light` or `ThemeMode.dark` based
  on `Settings.isDarkMode`.
- **Toggle Layout** — tap to switch the Notes list between grid (2-column masonry) and list
  (1-column) view.
- **Danger zone → Delete all notes** — shows a confirmation dialog
  ([showAlertDialog](../../lib/src/core/utils/alert_dialog.dart)); on confirm, dispatches
  `DeleteAllNotesevent` to `NotesBloc`, which calls `DeleteAllNotesUseCase` → wipes the entire
  SQLite `notes` table. This bypasses soft-delete — notes are not recoverable afterward.
- **Danger zone → Delete all todos** — same confirmation pattern, dispatches
  `DeleteAllTodoEvent` to `TodosBloc`, clearing the Hive `todos` box.
- **About → Version** — a static label. **Note:** as of this writing it's hardcoded to `v4.0.0`
  in the widget tree rather than read from `pubspec.yaml`/package info, so it can drift out of
  sync with the actual app version (currently `4.1.0`, per [pubspec.yaml](../../pubspec.yaml)).

Sort-by preference (Modified Date vs. Created Date) is also stored in `Settings`, but it's set
from the Notes screen's filter bottom sheet, not from the Settings screen itself — see
[Notes → Sort](notes.md#user-facing-behavior).

## Data model

`Settings` — [lib/src/features/settings/data/models/settings/settings.dart](../../lib/src/features/settings/data/models/settings/settings.dart),
`@HiveType(typeId: 2)`:

```dart
class Settings extends Equatable {
  final bool isGrid;               // false = list view, true = grid view
  final bool isDarkMode;
  final bool sortByModifiedDate;   // defaults to true
}
```

Stored as a single record at index `0` in the Hive box `settings`
(`HiveSettingsDatabase.initializeSettings()` seeds `Settings(isGrid: false, isDarkMode: true,
sortByModifiedDate: true)` the first time the box is empty).

## Architecture

```
settings/
├── data/
│   ├── models/settings/settings.dart        # Settings Hive model
│   └── services/settings_database.dart      # HiveSettingsDatabase — direct box access
└── presentation/
    ├── bloc/settings_cubit.dart             # SettingsCubit
    └── screen/settings_screen.dart
```

No `domain/` layer — same pattern as Todos (see [Architecture](../architecture.md)).

### `HiveSettingsDatabase`

[lib/src/features/settings/data/services/settings_database.dart](../../lib/src/features/settings/data/services/settings_database.dart) —
`initializeSettings()` (seed default if box empty), `getInitialSetting()` (read record 0),
`putSettingsToBox({isGrid, isDarkMode, sortByModifiedDate})` (overwrite record 0). All three
fields must be passed on every write — there's no partial-update method, so each `SettingsCubit`
method reads the current `Settings` first and passes through the two unrelated fields unchanged.

### State management — `SettingsCubit`

[lib/src/features/settings/presentation/bloc/settings_cubit.dart](../../lib/src/features/settings/presentation/bloc/settings_cubit.dart) —
a `Cubit<Settings>` (no events/states split, since it's simple enough for direct methods):
`toggleTheme(bool isDarkMode)`, `toggleLayout(bool isGrid)`, `toggleSortPreference(bool
sortByModifiedDate)`. Each method persists to Hive first, then emits the new `Settings`.

`SettingsCubit` is provided **first** in the root `MultiBlocProvider`
([lib/main.dart](../../lib/main.dart)) because `NotesBloc` reads
`settingsCubit.state.sortByModifiedDate` at construction time to know which order to load the
initial page of notes in.

## Edge cases / gotchas

- **Version label is stale/hardcoded.** `SettingsScreen`'s "About → Version" row shows a literal
  `Text('v4.0.0')` rather than reading `pubspec.yaml`'s `version:` (currently `4.1.0`) or using a
  package-info plugin. Update it manually when releasing, or wire it to
  `package_info_plus`/similar.
- **No "system theme" option.** Only light/dark are supported; there's no
  `ThemeMode.system` toggle.
- **Danger-zone deletes are asymmetric with Notes' own delete flow.** "Delete all notes" here
  performs a hard delete of every row (via `DeleteAllNotesUseCase`), unlike the per-note swipe/
  long-press delete which soft-deletes into the trash first.

## Related files

| Purpose | File |
|---|---|
| Model | [settings.dart](../../lib/src/features/settings/data/models/settings/settings.dart) |
| Hive service | [settings_database.dart](../../lib/src/features/settings/data/services/settings_database.dart) |
| Cubit | [settings_cubit.dart](../../lib/src/features/settings/presentation/bloc/settings_cubit.dart) |
| Screen | [settings_screen.dart](../../lib/src/features/settings/presentation/screen/settings_screen.dart) |
| Confirmation dialog | [alert_dialog.dart](../../lib/src/core/utils/alert_dialog.dart) |

## Tests

`test/features/settings/` covers the model (`data/models/settings_test.dart`) and the cubit
(`presentation/bloc/settings_cubit_test.dart`). No widget test for `SettingsScreen`.
