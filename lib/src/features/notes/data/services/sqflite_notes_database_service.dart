import 'package:path/path.dart';
import 'package:scribble/src/features/notes/data/models/migration_notes/notes_model.dart';
import 'package:sqflite/sqflite.dart';

class SqfliteNotesDatabaseService {
  SqfliteNotesDatabaseService._internal();

  static final SqfliteNotesDatabaseService instance =
      SqfliteNotesDatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes.db');
    return _database!;
  }

  // Initialise the database
  Future<Database> _initDB(String filePath) async {
    final String dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        isBookmarked INTEGER NOT NULL DEFAULT 0,
        isArchived INTEGER NOT NULL DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0,
      )
    ''');

    // Indexes for optimized searching and sorting
    await db.execute('CREATE INDEX idx_date ON notes(date)');
    await db.execute('CREATE INDEX idx_bookmark ON notes(isBookmarked)');
    await db.execute('CREATE INDEX idx_archived ON notes(isArchived)');
    await db.execute('CREATE INDEX idx_title_content ON notes(title, content)');
  }

  // Insert or Update Note
  Future<int> upsertNote(NotesModel note) async {
    final db = await instance.database;
    if (note.id == null) {
      return await db.insert('notes', note.toMap());
    } else {
      return await db
          .update('notes', note.toMap(), where: 'id = ?', whereArgs: [note.id]);
    }
  }

  // Migration Insert all notes to the database
  migrateNotes(List<NotesModel> notes) async {
    final db = await instance.database;
    // db.insert(table, values)
  }

  // Get all active notes
  Future<List<NotesModel>> getNotes({
    String? query,
    bool sortByDateDesc = true,
    bool onlyBookmarked = false,
  }) async {
    final db = await instance.database;
    String whereClause = 'isArchived = 0';
    List<dynamic> whereArgs = [];

    if (onlyBookmarked) {
      whereClause += ' AND isBookmarked = 1';
    }

    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (title LIKE ? OR content LIKE ?)';
      whereArgs.add('%$query%');
      whereArgs.add('%$query%');
    }

    final orderBy = sortByDateDesc ? 'date DESC' : 'date ASC';
    final result = await db.query('notes',
        where: whereClause, whereArgs: whereArgs, orderBy: orderBy);
    return result.map((e) => NotesModel.fromMap(e)).toList();
  }

  // Archive (delete) a note
  Future<int> archiveNote(int id) async {
    final db = await instance.database;
    return await db.update('notes', {'isArchived': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  // Restore archived note
  Future<int> restoreArchivedNote(int id) async {
    final db = await instance.database;
    return await db.update('notes', {'isArchived': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  // Restore deleted note
  Future<int> restoreDeletedNote(int id) async {
    final db = await instance.database;
    return await db.update('notes', {'isDeleted': 0},
        where: 'id = ?', whereArgs: [id]);
  }

  // Get archived notes
  Future<List<NotesModel>> getArchivedNotes() async {
    final db = await instance.database;
    final result =
        await db.query('notes', where: 'isArchived = 1', orderBy: 'date DESC');
    return result.map((e) => NotesModel.fromMap(e)).toList();
  }

  // Get deleted notes
  Future<List<NotesModel>> getDeletedNotes() async {
    final db = await instance.database;
    final result =
        await db.query('notes', where: 'isDeleted = 1', orderBy: 'date DESC');
    return result.map((e) => NotesModel.fromMap(e)).toList();
  }

  // Delete permanently
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
