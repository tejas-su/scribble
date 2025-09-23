part of 'notes_bloc.dart';

abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

class LoadNotesEvent extends NotesEvent {}

class AddNotesEvent extends NotesEvent {
  final Notes notes;

  const AddNotesEvent({required this.notes});

  @override
  List<Object> get props => [notes];
}

class UpdateNotesEvent extends NotesEvent {
  final Notes notes;
  final int index;

  const UpdateNotesEvent({required this.notes, required this.index});

  @override
  List<Object> get props => [notes, index];
}

class DeleteNotesEvent extends NotesEvent {
  final int index;

  const DeleteNotesEvent({required this.index});

  @override
  List<Object> get props => [index];
}

class DeleteAllNotesevent extends NotesEvent {}

class SelectNotesEvent extends NotesEvent {
  final int index;
  final Notes note;
  final bool isSelected;
  const SelectNotesEvent(
      {required this.note, required this.index, required this.isSelected});

  @override
  List<Object> get props => [note, index, isSelected];
}

class SelectAllNotesEvent extends NotesEvent {}

class DeSelectAllNotesEvent extends NotesEvent {}

final class DeleteSelectedNotes extends NotesEvent {
  final List<Notes> notes;

  const DeleteSelectedNotes({required this.notes});

  @override
  List<Object> get props => [notes];
}
