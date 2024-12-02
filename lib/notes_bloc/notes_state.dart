part of 'notes_bloc.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

class NotesLoadingState extends NotesState {}

class NotesLoadedState extends NotesState {
  final List<Notes> note;

  const NotesLoadedState({
    required this.note,
  });

  @override
  List<Object> get props => [note];
}

class NotesErrorState extends NotesState {
  final String errorMessage;
  const NotesErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
