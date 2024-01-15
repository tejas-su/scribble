part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotes extends NotesEvent {}

class AddNotes extends NotesEvent {
  final Notes notes;

  const AddNotes({required this.notes});
}

class UpdateNotes extends NotesEvent {
  final Notes notes;
  final int index;

  const UpdateNotes({required this.notes, required this.index});
}

class DeleteNotes extends NotesEvent {
  final int index;
  final List<Notes> notes;

  const DeleteNotes({required this.notes, required this.index});
}

class ToggleGridViewEvent extends NotesEvent {}
