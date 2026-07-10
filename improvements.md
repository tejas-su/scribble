# Notes UX/UI Improvement Plan

## Context

Scribble's notes feature (SQLite-backed, `flutter_bloc` state management, feature-first architecture under `lib/src/features/notes/`) already covers the core loop well: create/edit, soft/hard delete with restore, archive, bookmark, search, sort, grid/list view, share, infinite scroll, and a recently-merged notes-count badge in the drawer. Reading through the actual screens (`notes_screen.dart`, `new_notes_screen.dart`, `notes_card.dart`, `menu_overlay.dart`) surfaced a set of concrete, unaddressed UX gaps: destructive actions have no confirmation or undo, saving is invisible (only happens silently on back-navigation), there's no way to visually distinguish or prioritize notes (no pin, no color), and some dependencies already in `pubspec.yaml` (`flutter_slidable`) sit unused. Separately, the current branch is named `feat/pin-to-top` but contains zero code toward it — it's the clearly-intended next feature and has no data model support yet.

The goal of this plan is to turn those observations into a prioritized, actionable roadmap: quick low-risk wins first, then the schema-touching additions (pin, color), then larger structural investments (multi-select, autosave). This is a planning/design deliverable — implementation happens in follow-up sessions, PR by PR, in the order below.

Two things verified directly in code that correct/ground the plan:
- `Note.props` (`lib/src/features/notes/domain/enitities/note.dart:34`) excludes `id` and `isDeleted` from equality — a real Bloc-diffing bug, fixed alongside the entity changes in Tier B.
- `NotesModel.toMap()` (`lib/src/features/notes/data/models/migration_notes/notes_model.dart:16`) silently drops `isReadOnly` when writing to SQLite — a preexisting bug. Any new field added to `Note`/`NotesModel` (pin, color) must be added to `toMap()` explicitly, or it will suffer the same silent-drop failure.
- Reusable utilities already exist and should anchor Tier A instead of building from scratch: `showAlertDialog` (`lib/src/core/utils/alert_dialog.dart`, already used for "Delete all notes" in Settings) and `showSnackBar` (`lib/src/core/utils/custom_snackbar.dart`, currently has no action-button support — needs a small extension for undo).

---

## Tier A — Quick wins (no schema changes, ship first)

1. **Delete confirmation dialog (S)** — In `menu_overlay.dart`'s `_MenuOption` for `Delete`/`Delete Permanently`, wrap `deletePermanently!()` (not the soft `onDelete!()` — that stays one-tap since it's recoverable via restore) in `showAlertDialog` (same pattern as `settings_screen.dart`'s existing delete-all confirmation).
2. **Undo snackbar after delete/archive (S/M)** — Extend `showSnackBar` to accept an optional action label + callback (`SnackBarAction`). After `onDelete`/`onArchive` fire in `notes_screen.dart`, show a snackbar whose action dispatches the existing `RestoreNotesEvent` — no new bloc event needed, `_onRestoreNotes` already restores from both archived and deleted states.
3. **Visible title character counter (S)** — Delete the `buildCounter: (...) => null` override in `new_notes_screen.dart:118` and `update_note_screen.dart` so the default Material counter renders against the existing `maxLength: 55`.
4. **Search inside Archived/Deleted/Bookmarked views (M)** — Remove the `isDeleted || isArchived || isBookmarked` branch that hides the search bar in `notes_screen.dart`. Requires extending `SearchNotesEvent` (or refactoring `_onSearchNotes` to delegate into the existing `_reloadCurrentView`) so search respects the currently-open filtered view instead of always querying the default list.
5. **Wire up `flutter_slidable` for swipe actions (M)** — This dependency is already in `pubspec.yaml` and unused. Wrap `NotesCard`'s content in a `Slidable` with swipe actions calling the *same* `onArchive`/`onDelete`/`onBookmark` closures already passed into `showMenuOverlay` (hoist them to named functions in `notes_screen.dart` so long-press-menu and swipe stay in sync). Long-press menu remains for Share/Restore/Delete-Permanently. Test carefully against the existing `onTapDown`/`onLongPress` gesture used for overlay-menu positioning.
6. **Shared `TextTheme` (M)** — Add named text styles to `lib/src/core/themes/themes.dart`'s `lightTheme`/`darkTheme` and replace the ad hoc inline `TextStyle(...)` calls in `notes_card.dart`, `new_notes_screen.dart`, `update_note_screen.dart` with theme references + `.copyWith()` for color only. Do this last in Tier A to avoid conflicting with A1–A5's edits to the same files.
7. **"Follow system" theme mode (S/M)** — Replace `Settings.isDarkMode` (bool, Hive-generated) with a 3-state `themeMode` string, regenerate the Hive adapter, update `SettingsCubit` and `main.dart`'s `themeMode:` wiring, and turn the single toggle in Settings into a 3-way choice (mirror `sort_modal_bottom_sheet.dart`'s pattern).

**Sequencing:** ship A1–A3 as one "safety net" PR, A4–A7 as a second "polish" PR.

---

## Tier B — Schema-touching additions (one migration, one PR)

Batch these together since all three touch `note.dart`, `notes_model.dart`, and `sqflite_notes_database_service.dart` — one v2→v3 SQLite migration and one Equatable fix, reviewed as a single unit.

2. **Note color labels (M/L)**
   - `note.dart`: add nullable `color` (hex string or fixed swatch enum) to constructor + `props`.
   - `notes_model.dart`: same 4 touch points as pin, `fromMap` must handle `null`.
   - `sqflite_notes_database_service.dart`: `ALTER TABLE notes ADD COLUMN color TEXT` (nullable), batched into the same v3 migration.
   - No new usecase needed — color is just another field on `UpdateNotesEvent`'s `Note`.
   - `new_notes_screen.dart`/`update_note_screen.dart`: small swatch-picker row near the app bar actions, same `ValueNotifier` pattern as the existing bookmark/read-only toggles.
   - `notes_card.dart`: tint the card `Container`'s background using the swatch color blended at low opacity over `surfaceContainer` (not a flat replacement, to preserve light/dark contrast).

3. **Fix `Note.props` Equatable bug (S)** — add `id` and `isDeleted` to `props` (`note.dart:34`) in the same PR, since the entity is already being touched for pin/color.

---

## Tier C — Larger investment (separate PRs)

1. **Multi-select / bulk actions (L)** — Long-press an unselected card enters selection mode (local `_selectionMode`/`_selectedIds` state in `notes_screen.dart`); subsequent taps toggle selection instead of navigating; a contextual app bar replaces the search row while active (Archive/Delete/Bookmark icons + "N selected"). `notes_card.dart` gets an optional selected/checkbox overlay reusing the existing `Badge`/`Stack` pattern. Bloc gets bulk events (`BulkArchiveNotesEvent`, etc.) that loop the existing single-id usecases and reload once — no new batched SQL needed for v1. Apply Tier A's confirmation dialog and undo snackbar to bulk actions too.

2. **Autosave-while-typing + "Saved" indicator (L)** — Add a debounced (~800ms–1s, same pattern as the existing 500ms search debounce in `notes_bloc.dart`) listener on `titleController`/`contentController` in `update_note_screen.dart` that dispatches the existing `UpdateNotesEvent` automatically. For `new_notes_screen.dart`, the tricky part: the first debounced save must insert (getting an `id`), and every subsequent debounced save must update that same row rather than re-inserting — gate this by only inserting once on first non-empty content, then treating the screen as an update-screen for the rest of its session. Add a small `ValueNotifier<SaveStatus>` (`idle|saving|saved`) driving a subtle "Saved" text/checkmark near the app bar. **Keep the existing `PopScope` save as a fallback** (final flush on exit), don't remove it. Highest correctness risk in this plan (duplicate-insert risk, debounce-vs-navigation races) — needs an explicit manual test pass (via the `verify` skill) covering: typing then backgrounding the app, typing then immediately popping, and rapid navigation in/out.

3. **Tags/folders (L, backlog)** — New `Tag` entity, either a proper join table or a denormalized CSV column (batched into the v3 migration family if pursued alongside B1/B2). Largest and most speculative item — defer as a future epic gated on whether pin (B1) + color (B2) already satisfy users' grouping needs, rather than scheduling it in the same milestone.

---

## Suggested sequencing

1. Tier A, PR 1: items 1–3 (confirmation + undo + counter).
2. Tier A, PR 2: items 4–7 (search-in-filtered-views, swipe actions, shared TextTheme, system theme mode).
3. Tier B: single PR/migration covering pin, color, and the Equatable fix.
4. Tier C: multi-select and autosave as two separate PRs (different risk profiles); tags deferred to backlog.

## Verification

- After each Tier A/B change, manually exercise the affected flow in the running app (`flutter run`): delete a note and confirm the dialog + undo snackbar work; check the title counter appears near the 55-char limit; search while in the Archived/Deleted/Bookmarked views; swipe a card left/right and confirm it matches the long-press menu's behavior; toggle system/light/dark theme.
- After Tier B, verify the SQLite migration on a device/emulator with an existing v2 database (upgrade path), not just a fresh install — confirm pinned notes sort to the top and colors persist across app restarts.
- After Tier C's autosave, explicitly test: type in a new note then kill the app before popping (data should persist), type then immediately navigate back (no duplicate rows), rapid create → edit → back-navigate cycles.
- Run existing test suite (`flutter test`) after each tier — `notes_bloc_test` and repository tests likely need updates wherever new events/fields are introduced.
