import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/models/notes/notes.dart';

import '../models/todos/todos.dart';

class HiveNotesDatabase {
  final Box notesBox;

  const HiveNotesDatabase({required this.notesBox});
  //Notes box functions
  List<Notes> getNotes() {
    return notesBox.values.toList().cast<Notes>();
  }

  Future<void> createNote(Notes notes) async {
    await notesBox.add(notes);
  }

  Future<void> updateNotes(int index, Notes notes) async {
    await notesBox.putAt(index, notes);
  }

  Future<void> deleteNote(int index) async {
    try {
      await notesBox.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

  void deleteAllNotes() {
    try {
      notesBox.deleteAll(notesBox.keys);
    } catch (e) {
      throw Exception(e);
    }
  }
}

class HiveTodosDatabase {
  final Box todosBox;
  HiveTodosDatabase({required this.todosBox});

  List<Todos> getTodos() {
    return todosBox.values.toList().cast<Todos>();
  }

  Future<void> createTodo(Todos todos) async {
    await todosBox.add(todos);
  }

  Future<void> updateTodo(int index, Todos todo) async {
    await todosBox.putAt(index, todo);
  }

  Future<void> deleteTodo(int index) async {
    try {
      await todosBox.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

  void deleteAllTodos() {
    try {
      todosBox.deleteAll(todosBox.keys);
    } catch (e) {
      throw Exception(e);
    }
  }
}
