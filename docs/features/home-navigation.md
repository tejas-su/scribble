# Home & Navigation

## Overview

The "home" feature isn't user-facing content on its own — it's the app shell that hosts the
Notes and Todos features: the top app bar, the navigation drawer, and the tab-switching
mechanism between them. It also owns the one piece of navigation-related state
(`PageViewCubit`).

## User-facing behavior

- **App bar** — persistent across both tabs, shows a menu icon (opens the drawer) and the
  "scribble" title.
- **Tabs (Notes / Todos)** — the two primary sections are pages in a `PageView`, not separate
  routes. The `PageView` itself is *not* swipeable
  (`physics: NeverScrollableScrollPhysics`); switching is done only via the drawer.
- **Drawer** — opened from the app bar's menu icon. Entries:
  - **Notes** — switches to page 0 and dispatches `LoadNotesEvent` (resets to the default,
    unfiltered notes list — important if the user was previously viewing Deleted/Archived/
    Bookmarks). Shows a count badge (total non-deleted, non-archived notes).
  - **Todos** — switches to page 1.
  - **Deleted** — switches to page 0 and dispatches `LoadDeletedNotesEvent`. No count badge.
  - **Archived** — switches to page 0 and dispatches `LoadArchivedNotesEvent`. Shows a count
    badge.
  - **Bookmarks** — switches to page 0 and dispatches `LoadBookmarkedNotesEvent`. Shows a count
    badge.
  - **Settings** — pushes `SettingsScreen` as a new route (the only drawer item that navigates
    away from the home shell rather than switching pages/state).

  The count badges are pill widgets (`_CountBadge`, private to `scribble_drawer.dart`) driven by
  `context.watch<NotesCountCubit>().state` — see
  [Notes → State management — `NotesCountCubit`](notes.md#state-management--notescountcubit).
  Each badge is hidden when its count is 0.

**Important:** Deleted, Archived, and Bookmarks are *not* separate screens — they're all
rendered by the same `NotesScreen` widget on page 0, with `NotesBloc`'s current state
(`NotesLoadedState.isDeleted` / `.isArchived` / `.isBookmarked`) determining what's shown (e.g.
hiding the search bar and FAB, changing the long-press menu to offer Restore instead of
Archive). See [Notes](notes.md) for what changes in each view.

## Architecture

```
home/
└── presentation/
    ├── bloc/page_view_cubit.dart          # PageViewCubit
    ├── home_screen.dart                   # HomeScreen — the shell
    └── widgets/
        ├── scribble_appbar.dart           # scribbleAppBar()
        └── scribble_drawer.dart           # ScribbleDrawer
```

No `data/` or `domain/` layer — home has no persisted state of its own.

### `HomeScreen`

[lib/src/features/home/presentation/home_screen.dart](../../lib/src/features/home/presentation/home_screen.dart) —
a `StatefulWidget` holding the `PageController` and a `ValueNotifier<int>` (`pageNotifier`,
used purely to drive the drawer's selected-item highlighting — kept separate from
`PageViewCubit` for that UI-only concern). `PageView.onPageChanged` forwards to
`context.read<PageViewCubit>().togglePage(value)`.

### `PageViewCubit`

[lib/src/features/home/presentation/bloc/page_view_cubit.dart](../../lib/src/features/home/presentation/bloc/page_view_cubit.dart) —
a trivial `Cubit<int>` tracking the current page index (0 = Notes, 1 = Todos). Nothing else in
the app currently reads this cubit's state — it exists for future consumers (e.g. a bottom nav
bar) more than for present behavior, since the drawer drives page changes directly via
`PageController.animateToPage` rather than through this cubit.

### Navigation model

There's no router package (`go_router`, `auto_route`, etc.) — plain
`Navigator.of(context).push(MaterialPageRoute(builder: ...))` is used for anything that isn't a
Notes/Todos tab switch: `SettingsScreen`, `NewNotesScreen`, `UpdateNotesScreen`.

## Edge cases / gotchas

- **Drawer items that "navigate" to Deleted/Archived/Bookmarks don't set `pageNotifier`/page
  correctly if you're already on Todos** — they call `pageController.animateToPage(0, ...)`
  directly and dispatch the corresponding `NotesBloc` event, but do so regardless of current
  page, so the transition is always animated back to page 0.
- **Two sources of "current page" truth.** `pageNotifier` (`ValueNotifier<int>`, UI-only, used by
  the drawer for highlighting) and `PageViewCubit` (app-wide `Cubit<int>`) are updated
  independently — `pageNotifier` is set explicitly in each drawer `onTap`, while
  `PageViewCubit.togglePage` only fires from `PageView.onPageChanged`. They can briefly disagree
  during a programmatic `animateToPage` call.

## Related files

| Purpose | File |
|---|---|
| Shell screen | [home_screen.dart](../../lib/src/features/home/presentation/home_screen.dart) |
| Page-index cubit | [page_view_cubit.dart](../../lib/src/features/home/presentation/bloc/page_view_cubit.dart) |
| App bar | [scribble_appbar.dart](../../lib/src/features/home/presentation/widgets/scribble_appbar.dart) |
| Drawer | [scribble_drawer.dart](../../lib/src/features/home/presentation/widgets/scribble_drawer.dart) |

## Tests

`test/features/home/presentation/bloc/page_view_cubit_test.dart` covers `PageViewCubit`. No
widget tests for `HomeScreen`, `ScribbleDrawer`, or `scribbleAppBar`.
