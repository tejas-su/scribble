import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/models/notes/notes.dart';
import '../models/todos/todos.dart';

class HiveNotesDatabase {
  final Box<Notes> box;

  HiveNotesDatabase({required this.box});

  static Future<Box<Notes>> openBox(String boxName) async {
    Box<Notes> box = await Hive.openBox(boxName);
    return box;
  }

  //Notes box functions
  List<Notes> getNotes() {
    return box.values.toList().cast<Notes>();
  }

  Future<void> createNote(Notes notes) async {
    await box.add(notes);
  }

  Future<void> updateNotes(int index, Notes notes) async {
    await box.putAt(index, notes);
  }

  Future<void> deleteNote(int index) async {
    try {
      await box.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

  void deleteAllNotes() {
    try {
      box.deleteAll(box.keys);
    } catch (e) {
      throw Exception(e);
    }
  }
}

class HiveTodosDatabase {
  late Box box;
  HiveTodosDatabase({required this.box});
  static Future<Box<Todos>> openBox(String boxName) async {
    Box<Todos> box = await Hive.openBox(boxName);
    return box;
  }

  List<Todos> getTodos() {
    return box.values.toList().cast<Todos>();
  }

  Future<void> createTodo(Todos todos) async {
    await box.add(todos);
  }

  Future<void> updateTodo(int index, Todos todo) async {
    await box.putAt(index, todo);
  }

  Future<void> deleteTodo(int index) async {
    try {
      await box.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

  void deleteAllTodos() {
    try {
      box.deleteAll(box.keys);
    } catch (e) {
      throw Exception(e);
    }
  }
}
