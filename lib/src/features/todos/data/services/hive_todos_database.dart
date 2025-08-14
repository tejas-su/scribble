import 'package:hive_flutter/hive_flutter.dart';
import '../models/todos/todos.dart';

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