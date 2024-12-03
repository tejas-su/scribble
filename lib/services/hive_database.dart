import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/models/notes/notes.dart';

class HiveDatabase {
  final Box notesBox;

  const HiveDatabase({required this.notesBox});
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
