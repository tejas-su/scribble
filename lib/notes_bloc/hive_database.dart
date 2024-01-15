import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/models/notes.dart';

class HiveDatabase {
  Future<Box> openBox() async {
    Box notesBox = await Hive.openBox<Notes>('notes');
    return notesBox;
  }

  List<Notes> getNotes(Box notesBox) {
    return notesBox.values.toList().cast<Notes>();
  }

  Future<void> createNote(Box notesBox, Notes notes) async {
    await notesBox.add(notes);
  }

  Future<void> updateNotes(Box notesBox, int index, Notes notes) async {
    await notesBox.putAt(index, notes);
  }

  Future<void> deleteNote(Box notesBox, int index) async {
    await notesBox.deleteAt(index);
  }
}
