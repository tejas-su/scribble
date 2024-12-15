import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/models/notes/notes.dart';
import '../models/todos/todos.dart';

class HiveNotesDatabase {
  late Box _notesBox;
  final String boxName;
  HiveNotesDatabase({required this.boxName}) {
    _opennotesBox();
  }

  Future<void> _opennotesBox() async {
    _notesBox = await Hive.openBox(boxName);
  }

  //Notes box functions
  List<Notes> getNotes() {
    return _notesBox.values.toList().cast<Notes>();
  }

  Future<void> createNote(Notes notes) async {
    await _notesBox.add(notes);
  }

  Future<void> updateNotes(int index, Notes notes) async {
    await _notesBox.putAt(index, notes);
  }

  Future<void> deleteNote(int index) async {
    try {
      await _notesBox.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

  void deleteAllNotes() {
    try {
      _notesBox.deleteAll(_notesBox.keys);
    } catch (e) {
      throw Exception(e);
    }
  }
}

class HiveTodosDatabase {
  final String boxName;
  late Box _todosBox;
  HiveTodosDatabase({required this.boxName}) {
    _openBox();
  }

  Future<void> _openBox() async {
    _todosBox = await Hive.openBox(boxName);
  }

  List<Todos> getTodos() {
    return _todosBox.values.toList().cast<Todos>();
  }

  Future<void> createTodo(Todos todos) async {
    await _todosBox.add(todos);
  }

  Future<void> updateTodo(int index, Todos todo) async {
    await _todosBox.putAt(index, todo);
  }

  Future<void> deleteTodo(int index) async {
    try {
      await _todosBox.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

  void deleteAllTodos() {
    try {
      _todosBox.deleteAll(_todosBox.keys);
    } catch (e) {
      throw Exception(e);
    }
  }
}
