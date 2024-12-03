import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
    on<DeleteAllNotesevent>(_deleteAllNotes);
  }
  //load the notes
  void _onLoadNotes(LoadNotesEvent event, Emitter<NotesState> emit) {
    emit(NotesLoadingState());
    try {
      List<Notes> notes = hiveDatabase.getNotes();
      emit(NotesLoadedState(note: notes));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //add the notes
  void _onAddNotes(AddNotesEvent event, Emitter<NotesState> emit) async {
    emit(NotesLoadingState());
    try {
      await hiveDatabase.createNote(event.notes);
      List<Notes> notes = hiveDatabase.getNotes();
      emit(NotesLoadedState(note: notes));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //delete the notes
  void _onDelteNotes(DeleteNotesEvent event, Emitter<NotesState> emit) async {
    emit(NotesLoadingState());
    try {
      await hiveDatabase.deleteNote(event.index);
      List<Notes> notes = hiveDatabase.getNotes();
      emit(NotesLoadedState(note: notes));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //update the notes
  void _onUpdateNotes(UpdateNotesEvent event, Emitter<NotesState> emit) async {
    try {
      await hiveDatabase.updateNotes(event.index, event.notes);
      List<Notes> notes = hiveDatabase.getNotes();
      emit(NotesLoadedState(note: notes));
    } catch (e) {
      emit(NotesErrorState(errorMessage: e.toString()));
    }
  }

  //Delete all notes from the database
  void _deleteAllNotes(NotesEvent event, Emitter<NotesState> emit) {
    emit(NotesLoadingState());
    try {
      hiveDatabase.deleteAllNotes();
      List<Notes> notes = hiveDatabase.getNotes();
      emit(NotesLoadedState(note: notes));
    } catch (e) {
      emit(NotesErrorState(
          errorMessage: 'Something went wrong!\n ${e.toString()}'));
    }
  }
}

class SecretNotesBloc extends NotesBloc {
  SecretNotesBloc({required super.hiveDatabase});
}
