part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object> get props => [];
}

final class LoadNotesEvent extends NotesEvent {
  final bool sortByModifiedDate;

  const LoadNotesEvent({required this.sortByModifiedDate});

  @override
  List<Object> get props => [sortByModifiedDate];
}

final class LoadBookmarkedNotesEvent extends NotesEvent {}

final class LoadDeletedNotesEvent extends NotesEvent {}

final class ArchiveNotesEvent extends NotesEvent {
  final int id;

  const ArchiveNotesEvent({required this.id});

  @override
  List<Object> get props => [id];
}

final class GiveReadWriteAccessEvent extends NotesEvent {
  final int id;
  final bool isReadOnly;

  const GiveReadWriteAccessEvent({required this.id, required this.isReadOnly});

  @override
  List<Object> get props => [id];
}

final class RestoreNotesEvent extends NotesEvent {
  final int id;
  final bool isDeletedNote;

  const RestoreNotesEvent({required this.id, required this.isDeletedNote});

  @override
  List<Object> get props => [id, isDeletedNote];
}

final class DeleteNotesEvent extends NotesEvent {
  final int id;
  final bool softDelete;

  const DeleteNotesEvent({required this.id, required this.softDelete});

  @override
  List<Object> get props => [id, softDelete];
}

final class LoadArchivedNotesEvent extends NotesEvent {}

final class AddNotesEvent extends NotesEvent {
  final Note note;

  const AddNotesEvent({required this.note});

  @override
  List<Object> get props => [note];
}

class UpdateNotesEvent extends NotesEvent {
  final Note note;
  final int id;

  const UpdateNotesEvent({required this.note, required this.id});

  @override
  List<Object> get props => [note, id];
}

class BookmarkNotesEvent extends NotesEvent {
  final int id;
  final bool bookMark;

  const BookmarkNotesEvent({required this.id, required this.bookMark});

  @override
  List<Object> get props => [id, bookMark];
}

final class DeleteAllNotesevent extends NotesEvent {}

final class SearchNotesEvent extends NotesEvent {
  final String query;

  const SearchNotesEvent({required this.query});

  @override
  List<Object> get props => [query];
}

final class LoadMoreNotesEvent extends NotesEvent {
  final String? query;

  const LoadMoreNotesEvent({this.query});

  @override
  List<Object> get props => [query ?? ''];
}
