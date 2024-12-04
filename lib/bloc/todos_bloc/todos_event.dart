part of 'todos_bloc.dart';

sealed class TodosEvent extends Equatable {
  const TodosEvent();

  @override
  List<Object> get props => [];
}

final class LoadTodoEvent extends TodosEvent {}

final class AddtodoEvent extends TodosEvent {
  final Todos todo;

  const AddtodoEvent({required this.todo});

  @override
  List<Object> get props => [todo];
}

final class UpdateTodoEvent extends TodosEvent {
  final Todos todo;
  final int index;

  const UpdateTodoEvent({required this.todo, required this.index});

  @override
  List<Object> get props => [todo, index];
}

final class DeleteTodoEvent extends TodosEvent {
  final int index;

  const DeleteTodoEvent({required this.index});

  @override
  List<Object> get props => [index];
}

final class DeleteAllTodoEvent extends TodosEvent {}
