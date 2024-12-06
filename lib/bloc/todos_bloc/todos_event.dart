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

final class EditTodoEvent extends TodosEvent {
  final Todos todo;

  final int index;

  const EditTodoEvent({required this.todo, required this.index});
}

final class CancelUpdateTodoEvent extends TodosEvent {
  final Todos todo;
  final bool cancel;
  final int index;

  const CancelUpdateTodoEvent(
      {required this.todo, required this.index, required this.cancel});
}
