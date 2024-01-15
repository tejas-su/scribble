import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/notes.dart';
import 'hive_database.dart';
part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final HiveDatabase hiveDatabase;
  NotesBloc({required this.hiveDatabase}) : super(NotesLoading()) {
    on<LoadNotes>(_onLoadNotes);
    on<AddNotes>(_onAddNotes);
    on<UpdateNotes>(_onUpdateNotes);
    on<DeleteNotes>(_onDelteNotes);
    on<ToggleGridViewEvent>(_onToggleGridView);
  }
  //load the notes
  void _onLoadNotes(LoadNotes event, Emitter<NotesState> emit) async {
    Future<void>.delayed(const Duration(seconds: 1));
    Box box = await hiveDatabase.openBox();
    List<Notes> notes = hiveDatabase.getNotes(box);
    emit(NotesLoaded(note: notes, isGrid: 2));
  }

  //add the notes
  void _onAddNotes(AddNotes event, Emitter<NotesState> emit) async {
    Box box = await hiveDatabase.openBox();
    if (state is NotesLoaded) {
      await hiveDatabase.createNote(box, event.notes);
      emit(NotesLoaded(note: hiveDatabase.getNotes(box), isGrid: 2));
    }
  }

  //delete the notes
  void _onDelteNotes(DeleteNotes event, Emitter<NotesState> emit) async {
    Box box = await hiveDatabase.openBox();
    if (state is NotesLoaded) {
      await hiveDatabase.deleteNote(box, event.index);
      emit(NotesLoaded(
        isGrid: 2,
        note: hiveDatabase.getNotes(box),
      ));
    }
  }

  //update the notes
  void _onUpdateNotes(UpdateNotes event, Emitter<NotesState> emit) async {
    Box box = await hiveDatabase.openBox();
    if (state is NotesLoaded) {
      await hiveDatabase.updateNotes(box, event.index, event.notes);
      emit(NotesLoaded(note: hiveDatabase.getNotes(box), isGrid: 2));
    }
  }

  void _onToggleGridView(ToggleGridViewEvent event, Emitter<NotesState> emit) {
    if (state is NotesLoaded) {
      emit((state as NotesLoaded)
          .copyWith(isGrid: (state as NotesLoaded).isGrid == 1 ? 2 : 1));
    }
  }
}
