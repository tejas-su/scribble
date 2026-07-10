# Scribble Documentation

Scribble is a minimalist, offline-first note-taking app built with Flutter. It also includes a
lightweight todo list. This directory documents the app feature by feature for contributors and
maintainers.

## Contents

- [Architecture](architecture.md) — project structure, layering, state management, and storage
- Features
  - [Notes](features/notes.md) — create, edit, search, sort, bookmark, archive, delete, read-only, share
  - [Todos](features/todos.md) — a simple daily checklist
  - [Settings](features/settings.md) — theme, layout, sort preference, danger-zone actions
  - [Home & Navigation](features/home-navigation.md) — app shell, drawer, page switching

## Quick facts

| | |
|---|---|
| Framework | Flutter (Dart SDK `>=3.10.0 <4.0.0`) |
| State management | [flutter_bloc](https://pub.dev/packages/flutter_bloc) (Bloc + Cubit) |
| Local storage | SQLite (`sqflite`) for notes, [Hive](https://pub.dev/packages/hive_flutter) for todos and settings |
| Architecture style | Feature-first, layered (`data` / `domain` / `presentation`) per feature |
| Package name | `com.widgetsandco.scribble` |
| Current version | See [pubspec.yaml](../pubspec.yaml) |

## Where things live

```
lib/
├── main.dart                      # App entry point, DI wiring, Hive setup
└── src/
    ├── core/                      # Cross-feature utilities, themes
    └── features/
        ├── home/                  # App shell: app bar, drawer, page switching
        ├── notes/                 # Note CRUD, search, filters, sharing
        ├── settings/              # Theme/layout/sort preferences
        └── todos/                 # Simple todo list
```

Each feature under `lib/src/features/` follows the same internal layout:

```
<feature>/
├── data/           # Models, database services, repository implementations
├── domain/         # Entities, repository interfaces, use cases (notes only)
└── presentation/   # Bloc/Cubit, screens, widgets
```

For details on why notes uses full clean-architecture layering while todos and settings are
simpler, see [Architecture](architecture.md).

## Conventions used in these docs

Each feature doc follows the same shape: **Overview → User-facing behavior → Data model →
Architecture → Key files → Edge cases / gotchas → Tests**. File references use the form
`path/to/file.dart:line` so you can jump straight to the source.
