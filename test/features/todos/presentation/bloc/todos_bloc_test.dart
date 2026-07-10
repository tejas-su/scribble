import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scribble/src/features/todos/data/models/todos/todos.dart';
import 'package:scribble/src/features/todos/data/services/hive_todos_database.dart';
import 'package:scribble/src/features/todos/presentation/bloc/todos_bloc/todos_bloc.dart';

class MockHiveTodosDatabase extends Mock implements HiveTodosDatabase {}

class FakeTodos extends Fake implements Todos {}

void main() {
  late MockHiveTodosDatabase database;

  const todo1 = Todos(isCompleted: false, date: '2026-01-01', todo: 'first');
  const todo2 = Todos(isCompleted: true, date: '2026-01-02', todo: 'second');

  setUpAll(() {
    registerFallbackValue(FakeTodos());
  });

  setUp(() {
    database = MockHiveTodosDatabase();
  });

  TodosBloc buildBloc() => TodosBloc(hiveDatabase: database);

  group('LoadTodoEvent', () {
    test('emits [loading, loaded] with the todos from the database', () async {
      when(() => database.getTodos()).thenReturn([todo1, todo2]);
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodosLoadedState>().having((s) => s.todo, 'todo', [todo1, todo2]),
        ]),
      );

      bloc.add(LoadTodoEvent());
      await expectation;
    });

    test('emits [loading, loaded] with an empty list when there are no todos', () async {
      when(() => database.getTodos()).thenReturn([]);
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodosLoadedState>().having((s) => s.todo, 'todo', isEmpty),
        ]),
      );

      bloc.add(LoadTodoEvent());
      await expectation;
    });

    test('emits [loading, error] when the database throws', () async {
      when(() => database.getTodos()).thenThrow(Exception('read failed'));
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodoErrorState>(),
        ]),
      );

      bloc.add(LoadTodoEvent());
      await expectation;
    });
  });

  group('AddtodoEvent', () {
    test('creates the todo then reloads the list', () async {
      when(() => database.createTodo(any())).thenAnswer((_) async {});
      when(() => database.getTodos()).thenReturn([todo1]);
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodosLoadedState>().having((s) => s.todo, 'todo', [todo1]),
        ]),
      );

      bloc.add(const AddtodoEvent(todo: todo1));
      await expectation;

      verify(() => database.createTodo(todo1)).called(1);
    });

    test('emits an error state when creation fails', () async {
      when(() => database.createTodo(any())).thenThrow(Exception('write failed'));
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodoErrorState>(),
        ]),
      );

      bloc.add(const AddtodoEvent(todo: todo1));
      await expectation;
    });
  });

  group('UpdateTodoEvent', () {
    test('updates the todo at the given index and reloads (no loading state first)', () async {
      when(() => database.updateTodo(any(), any())).thenAnswer((_) async {});
      when(() => database.getTodos()).thenReturn([todo2]);
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadedState>().having((s) => s.todo, 'todo', [todo2]),
        ]),
      );

      bloc.add(const UpdateTodoEvent(todo: todo2, index: 0));
      await expectation;

      verify(() => database.updateTodo(0, todo2)).called(1);
    });
  });

  group('DeleteTodoEvent', () {
    test('deletes at the given index then reloads', () async {
      when(() => database.deleteTodo(any())).thenAnswer((_) async {});
      when(() => database.getTodos()).thenReturn([]);
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodosLoadedState>().having((s) => s.todo, 'todo', isEmpty),
        ]),
      );

      bloc.add(const DeleteTodoEvent(index: 3));
      await expectation;

      verify(() => database.deleteTodo(3)).called(1);
    });
  });

  group('DeleteAllTodoEvent', () {
    test('clears all todos', () async {
      when(() => database.deleteAllTodos()).thenReturn(null);
      when(() => database.getTodos()).thenReturn([]);
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodosLoadedState>().having((s) => s.todo, 'todo', isEmpty),
        ]),
      );

      bloc.add(DeleteAllTodoEvent());
      await expectation;
    });

    test('prefixes the error message on failure', () async {
      when(() => database.deleteAllTodos()).thenThrow(Exception('boom'));
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosLoadingState>(),
          isA<TodoErrorState>().having(
            (s) => s.errorMessage,
            'errorMessage',
            contains('Something went wrong!'),
          ),
        ]),
      );

      bloc.add(DeleteAllTodoEvent());
      await expectation;
    });
  });

  group('EditTodoEvent', () {
    test('emits TodosEditingstate directly with no loading state', () async {
      final bloc = buildBloc();
      addTearDown(bloc.close);

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          isA<TodosEditingstate>()
              .having((s) => s.todo, 'todo', todo1)
              .having((s) => s.index, 'index', 2),
        ]),
      );

      bloc.add(const EditTodoEvent(todo: todo1, index: 2));
      await expectation;
    });
  });
}
