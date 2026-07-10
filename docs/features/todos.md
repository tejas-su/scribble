# Todos

## Overview

A lightweight, single-list todo/checklist feature living on the second tab of the home
`PageView`. Simpler than Notes: no domain layer, no soft-delete, no search — just create, toggle
complete, edit, and delete, backed directly by a Hive box.

## User-facing behavior

- **Add** — type into the input field at the bottom of the Todos tab
  ([lib/src/features/todos/presentation/screen/todo_screen.dart](../../lib/src/features/todos/presentation/screen/todo_screen.dart))
  and press enter/done. Empty input is ignored.
- **Complete/uncomplete** — tap the checkbox on a todo card to toggle `isCompleted`.
- **Edit** — tap a todo card (not the checkbox) to enter edit mode: the whole screen swaps the
  list for a single `TodoField` pre-filled with the todo's text.
- **Delete** — swipe a todo (via `flutter_slidable`) or dismiss it to delete.
- **Delete all** — Settings → Danger zone → "Delete all todos" (with confirmation dialog).
- **Empty state** — a Lottie animation (`assets/lottie/empty_list.json`) plus "Everything looks
  empty here!" when there are no todos.

There is no bookmark, archive, priority, due date, or reminder concept — a todo is just
`{ todo: String, date: String, isCompleted: bool }`.

## Data model

`Todos` — [lib/src/features/todos/data/models/todos/todos.dart](../../lib/src/features/todos/data/models/todos/todos.dart),
`@HiveType(typeId: 3)`:

```dart
class Todos extends Equatable {
  final bool isCompleted;
  final String date;   // formatted display string, set at creation time (yMMMEd)
  final String todo;   // the todo text
}
```

Unlike `Note`, `Todos.date` is stored as an already-formatted display string
(`DateFormat.yMMMEd().format(...)`), not an ISO 8601 string — it's set once at creation and never
recomputed on edit.

Persistence: a single Hive box (`todos`), opened in
[lib/main.dart](../../lib/main.dart). Todos are identified by their **positional index in the
box**, not a stable ID — `updateTodo(index, todo)` / `deleteTodo(index)` operate on
`box.putAt(index, ...)` / `box.deleteAt(index)`.

## Architecture

```
todos/
├── data/
│   ├── models/todos/todos.dart              # Todos Hive model
│   └── services/hive_todos_database.dart    # HiveTodosDatabase — direct box access
└── presentation/
    ├── bloc/todos_bloc/                     # TodosBloc, TodosEvent, TodosState
    ├── screen/todo_screen.dart
    └── widgets/todo_card.dart, todo_field.dart
```

There is no `domain/` layer or repository abstraction for todos — `TodosBloc` calls
`HiveTodosDatabase` directly. This mirrors how Settings is structured, and is intentionally
simpler than Notes (see [Architecture](../architecture.md)).

### `HiveTodosDatabase`

[lib/src/features/todos/data/services/hive_todos_database.dart](../../lib/src/features/todos/data/services/hive_todos_database.dart) —
thin wrapper over a Hive `Box`: `getTodos()`, `createTodo(todos)` (`box.add`), `updateTodo(index,
todo)` (`box.putAt`), `deleteTodo(index)` (`box.deleteAt`), `deleteAllTodos()`
(`box.deleteAll(box.keys)`).

### State management — `TodosBloc`

[lib/src/features/todos/presentation/bloc/todos_bloc/todos_bloc.dart](../../lib/src/features/todos/presentation/bloc/todos_bloc/todos_bloc.dart)

**Events**: `LoadTodoEvent`, `AddtodoEvent`, `UpdateTodoEvent` (`{todo, index}`),
`DeleteTodoEvent` (`{index}`), `DeleteAllTodoEvent`, `EditTodoEvent` (`{todo, index}` — enters
edit mode), plus an unused `CancelUpdateTodoEvent` (declared but never dispatched/handled — see
[Edge cases](#edge-cases--gotchas)).

**States** (`todos_state.dart`): `TodosLoadingState`, `TodosLoadedState` (`{todo: List<Todos>}`),
`TodoErrorState` (`{errorMessage}`), `TodosEditingstate` (`{todo, index}` — drives the
edit-mode UI swap).

Every mutating event (`Add`, `Update`, `Delete`, `DeleteAll`) re-fetches the full list from Hive
and emits a fresh `TodosLoadedState` — there's no in-memory list manipulation or optimistic
update.

## Edge cases / gotchas

- **Index-based identity is fragile.** Because todos are addressed by list position rather than a
  stable key, any operation that changes ordering (which doesn't currently happen, but would if
  sorting/filtering were added) would silently corrupt `update`/`delete` targeting.
- **`CancelUpdateTodoEvent` is dead code.** It's defined in `todos_event.dart` but never added as
  a handler in `TodosBloc` and never dispatched from the UI — editing is only exited by
  submitting an edit (which returns to `TodosLoadedState`), not by an explicit cancel action.
- **No per-todo date update.** `date` is set once at creation (`DateFormat.yMMMEd().format(...)`
  in `todo_screen.dart`) and is not refreshed when a todo is edited.

## Related files

| Purpose | File |
|---|---|
| Model | [todos.dart](../../lib/src/features/todos/data/models/todos/todos.dart) |
| Hive service | [hive_todos_database.dart](../../lib/src/features/todos/data/services/hive_todos_database.dart) |
| Bloc | [todos_bloc.dart](../../lib/src/features/todos/presentation/bloc/todos_bloc/todos_bloc.dart) |
| Screen | [todo_screen.dart](../../lib/src/features/todos/presentation/screen/todo_screen.dart) |
| Card widget | [todo_card.dart](../../lib/src/features/todos/presentation/widgets/todo_card.dart) |
| Input field widget | [todo_field.dart](../../lib/src/features/todos/presentation/widgets/todo_field.dart) |

## Tests

`test/features/todos/` covers the model (`data/models/todos_test.dart`) and the bloc
(`presentation/bloc/todos_bloc_test.dart`). No repository/use-case tests exist, matching the
feature's simpler architecture.
