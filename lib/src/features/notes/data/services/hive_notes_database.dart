import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/src/features/notes/data/models/notes/notes.dart';

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
