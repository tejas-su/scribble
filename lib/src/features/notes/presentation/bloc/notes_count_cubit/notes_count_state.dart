part of 'notes_count_cubit.dart';

class NotesCountState extends Equatable {
  final int notesCount;
  final int archivedCount;
  final int bookmarkedCount;

  const NotesCountState({
    this.notesCount = 0,
    this.archivedCount = 0,
    this.bookmarkedCount = 0,
  });

  @override
  List<Object> get props => [notesCount, archivedCount, bookmarkedCount];
}
