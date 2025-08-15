part of 'notes_bloc.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

final class NotesLoadingState extends NotesState {}

final class NotesLoadedState extends NotesState {
  final List<Notes> note;
  final bool isSelecting;

  const NotesLoadedState({required this.note, this.isSelecting = false});

  @override
  List<Object> get props => [note, isSelecting];
}

final class NotesErrorState extends NotesState {
  final String errorMessage;
  const NotesErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
