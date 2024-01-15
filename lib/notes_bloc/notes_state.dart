part of 'notes_bloc.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<Notes> note;
  final int isGrid;

  const NotesLoaded({
    this.isGrid = 2,
    required this.note,
  });
  @override
  List<Object> get props => [note, isGrid];

  NotesLoaded copyWith({
    List<Notes>? note,
    int? isGrid,
  }) {
    return NotesLoaded(
      note: note ?? this.note,
      isGrid: isGrid ?? this.isGrid,
    );
  }
}
