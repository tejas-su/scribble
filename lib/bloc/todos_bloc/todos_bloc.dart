import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/todos/todos.dart';
import '../../services/hive_database.dart';
part 'todos_event.dart';
part 'todos_state.dart';

class TodosBloc extends Bloc<TodosEvent, TodosState> {
  final HiveTodosDatabase hiveDatabase;
  TodosBloc({required this.hiveDatabase}) : super(TodosLoadingState()) {
    on<LoadTodoEvent>(_onLoadTodos);
    on<AddtodoEvent>(_onAddTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDelteTodo);
    on<DeleteAllTodoEvent>(_deleteAllTodos);
    on<EditTodoEvent>(_editTodo);
  }
  //load the todos
  void _onLoadTodos(LoadTodoEvent event, Emitter<TodosState> emit) {
    emit(TodosLoadingState());
    try {
      List<Todos> todos = hiveDatabase.getTodos();
      emit(TodosLoadedState(todo: todos));
    } catch (e) {
      emit(TodoErrorState(errorMessage: e.toString()));
    }
  }

  //add the todos
  void _onAddTodo(AddtodoEvent event, Emitter<TodosState> emit) async {
    emit(TodosLoadingState());
    try {
      await hiveDatabase.createTodo(event.todo);
      List<Todos> todos = hiveDatabase.getTodos();
      emit(TodosLoadedState(todo: todos));
    } catch (e) {
      emit(TodoErrorState(errorMessage: e.toString()));
    }
  }

  //delete the todos
  void _onDelteTodo(DeleteTodoEvent event, Emitter<TodosState> emit) async {
    emit(TodosLoadingState());
    try {
      await hiveDatabase.deleteTodo(event.index);
      List<Todos> todos = hiveDatabase.getTodos();
      emit(TodosLoadedState(todo: todos));
    } catch (e) {
      emit(TodoErrorState(errorMessage: e.toString()));
    }
  }

  //update the todos
  void _onUpdateTodo(UpdateTodoEvent event, Emitter<TodosState> emit) async {
    try {
      await hiveDatabase.updateTodo(event.index, event.todo);
      List<Todos> todos = hiveDatabase.getTodos();
      emit(TodosLoadedState(todo: todos));
    } catch (e) {
      emit(TodoErrorState(errorMessage: e.toString()));
    }
  }

  //Delete all todos from the database
  void _deleteAllTodos(DeleteAllTodoEvent event, Emitter<TodosState> emit) {
    emit(TodosLoadingState());
    try {
      hiveDatabase.deleteAllTodos();
      List<Todos> todos = hiveDatabase.getTodos();
      emit(TodosLoadedState(todo: todos));
    } catch (e) {
      emit(TodoErrorState(
          errorMessage: 'Something went wrong!\n ${e.toString()}'));
    }
  }

  void _editTodo(EditTodoEvent event, Emitter<TodosState> emit) {
    emit(TodosEditingstate(todo: event.todo, index: event.index));
  }
}
