import 'package:hive_flutter/hive_flutter.dart';
import 'package:scribble/models/bookmarks/bookmarks.dart';
import 'package:scribble/models/notes/notes.dart';

class HiveDatabase {
  final Box notesBox;
  final Box bookMarksBox;
  const HiveDatabase({required this.notesBox, required this.bookMarksBox});
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
      await bookMarksBox.deleteAt(index);
      await notesBox.deleteAt(index);
    } catch (e) {
      throw Exception(e);
    }
  }

  //bookmarks box function
  List<Bookmarks> getBookMarks() {
    return bookMarksBox.values.toList().cast<Bookmarks>();
  }

  Future<void> updateBookMark(int index, Bookmarks bookmark) async {
    try {
      await bookMarksBox.putAt(index, bookmark);
    } catch (e) {
      throw Exception('Oops something went wrong!');
    }
  }

  //while creating the note use addBookmark as initially
  //the user will note bookmark the note without the note even being created
  Future<void> addBookMark() async {
    await bookMarksBox.add(Bookmarks(isBookMarked: false));
  }

  Future<void> deleteBookMark(int index) async {
    await bookMarksBox.deleteAt(index);
  }
}
