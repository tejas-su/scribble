part of 'notes_bloc.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object> get props => [];
}

final class NotesLoadingState extends NotesState {}

final class NotesLoadedState extends NotesState {
  final List<Note> notes;
  final bool isSelecting;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isDeleted;
  final bool isArchived;
  final bool isBookmarked;

  const NotesLoadedState({
    required this.notes,
    this.isSelecting = false,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isDeleted = false,
    this.isArchived = false,
    this.isBookmarked = false,
  });

  @override
  List<Object> get props => [
    notes,
    isSelecting,
    hasMore,
    isLoadingMore,
    isDeleted,
    isArchived,
    isBookmarked,
  ];

  NotesLoadedState copyWith({
    List<Note>? note,
    bool? isSelecting,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isDeleted,
    bool? isArchived,
    bool? isBookmarked,
  }) {
    return NotesLoadedState(
      notes: note ?? this.notes,
      isSelecting: isSelecting ?? this.isSelecting,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isDeleted: isDeleted ?? this.isDeleted,
      isArchived: isArchived ?? this.isArchived,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

final class NotesErrorState extends NotesState {
  final String errorMessage;
  const NotesErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
