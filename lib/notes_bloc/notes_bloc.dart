import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:scribble/models/bookmarks/bookmarks.dart';
import '../models/notes/notes.dart';
import '../services/hive_database.dart';
part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final HiveDatabase hiveDatabase;
  NotesBloc({required this.hiveDatabase}) : super(NotesLoadingState()) {
    on<LoadNotesEvent>(_onLoadNotes);
    on<AddNotesEvent>(_onAddNotes);
    on<UpdateNotesEvent>(_onUpdateNotes);
    on<DeleteNotesEvent>(_onDelteNotes);
    on<UpdateBookMarkEvent>(_updateBookMark);
  }
  //load the notes
  void _onLoadNotes(LoadNotesEvent event, Emitter<NotesState> emit) {
    emit(NotesLoadingState());
    try {
      List<Bookmarks> bookMarks = hiveDatabase.getBookMarks();
      List<Notes> notes = hiveDatabase.getNotes();
      debugPrint('Load notes:Bookmark:$bookMarks  Notes:$notes');
      emit(NotesLoadedState(note: notes, bookMarks: bookMarks));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //add the notes
  void _onAddNotes(AddNotesEvent event, Emitter<NotesState> emit) async {
    emit(NotesLoadingState());
    try {
      await hiveDatabase.addBookMark();
      await hiveDatabase.createNote(event.notes);
      List<Notes> notes = hiveDatabase.getNotes();
      List<Bookmarks> bookMarks = hiveDatabase.getBookMarks();
      debugPrint('Bookmark:$bookMarks Notes:$notes');
      emit(NotesLoadedState(note: notes, bookMarks: bookMarks));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //delete the notes
  void _onDelteNotes(DeleteNotesEvent event, Emitter<NotesState> emit) async {
    emit(NotesLoadingState());
    try {
      await hiveDatabase.deleteNote(event.index);
      //   await hiveDatabase.deleteBookMark(event.index);
      List<Notes> notes = hiveDatabase.getNotes();
      List<Bookmarks> bookMarks = hiveDatabase.getBookMarks();
      emit(NotesLoadedState(note: notes, bookMarks: bookMarks));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //update the notes
  void _onUpdateNotes(UpdateNotesEvent event, Emitter<NotesState> emit) async {
    try {
      await hiveDatabase.updateNotes(event.index, event.notes);
      List<Notes> notes = hiveDatabase.getNotes();
      List<Bookmarks> bookMarks = hiveDatabase.getBookMarks();
      emit(NotesLoadedState(note: notes, bookMarks: bookMarks));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //Add or remove bookmark
  void _updateBookMark(UpdateBookMarkEvent event, Emitter<NotesState> emit) {
    try {
      hiveDatabase.updateBookMark(
          event.index, Bookmarks(isBookMarked: event.isBookMarked));
      List<Notes> notes = hiveDatabase.getNotes();
      List<Bookmarks> bookMarks = hiveDatabase.getBookMarks();
      emit(NotesLoadedState(note: notes, bookMarks: bookMarks));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }
}
