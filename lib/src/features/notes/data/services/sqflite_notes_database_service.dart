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
    try {
      return await openDatabase(
        path,
        version: 2,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        isBookMarked INTEGER NOT NULL DEFAULT 0,
        isArchived INTEGER NOT NULL DEFAULT 0,
        isDeleted INTEGER NOT NULL DEFAULT 0,
        isReadOnly INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Indexes for optimized searching and sorting
    await db.execute('CREATE INDEX idx_date ON notes(modifiedAt)');
    await db.execute('CREATE INDEX idx_createdAt ON notes(createdAt)');
    await db.execute('CREATE INDEX idx_bookmark ON notes(isBookmarked)');
    await db.execute('CREATE INDEX idx_archived ON notes(isArchived)');
    await db.execute('CREATE INDEX idx_title_content ON notes(title, content)');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      if (oldVersion < newVersion) {
        await db.execute(
          'ALTER TABLE notes ADD COLUMN isReadOnly INTEGER NOT NULL DEFAULT 0',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Insert a new Note
  Future<int> insertNote(NotesModel note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  /// Update Note
  Future<int> updateNote(int id, NotesModel note) async {
    final db = await instance.database;
    try {
      final noteMap = note.toMap()
        ..remove('id'); // Remove id to avoid updating primary key
      return await db.update(
        'notes',
        noteMap,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to update note");
    }
  }

  @Deprecated('Will be deprecating in future release')
  /// Migration Insert all notes to the database
  Future<void> migrateNotes(List<NotesModel> notes) async {
    try {
      final db = await instance.database;
      final batch = db.batch();
      for (final note in notes) {
        batch.insert('notes', note.toMap());
      }
      await batch.commit();
    } catch (e) {
      throw Exception("Failed to migrate notes");
    }
  }

  /// Get all active notes
  Future<List<NotesModel>> getNotes({
    String? query,
    bool onlyBookmarked = false,
    bool onlyDeleted = false,
    bool onlyArchived = false,
    int limit = 20,
    int offset = 0,
    bool sortByModifiedDate = true,
  }) async {
    final db = await instance.database;
    String whereClause;
    final List<dynamic> whereArgs = [];

    String orderBy;
    if (sortByModifiedDate) {
      orderBy = 'datetime(modifiedAt) DESC';
    } else {
      orderBy = 'datetime(createdAt) DESC';
    }

    // Determine base filter based on what type of notes to show
    if (onlyDeleted) {
      whereClause = 'isDeleted = 1';
    } else if (onlyArchived) {
      // Show archived notes that are not deleted
      whereClause = 'isArchived = 1 AND isDeleted = 0';
    } else {
      // Default: show only active notes (not deleted and not archived)
      whereClause = 'isArchived = 0 AND isDeleted = 0';
    }

    // Add bookmark filter if needed
    if (onlyBookmarked) {
      whereClause += ' AND isBookMarked = 1';
    }

    // Add search query filter if provided
    if (query != null && query.isNotEmpty) {
      whereClause += ' AND (title LIKE ? OR content LIKE ?)';
      whereArgs
        ..add('%$query%')
        ..add('%$query%');
    }

    try {
      final result = await db.query(
        'notes',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
      return result.map(NotesModel.fromMap).toList();
    } catch (e) {
      throw Exception("Failed to get notes");
    }
  }

  /// Archive a note
  Future<int> archiveNote(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isArchived': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to archive note");
    }
  }

  /// Bookmark a note
  Future<int> bookmarkNote(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isBookmarked': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to bookmark note");
    }
  }

  /// Make a note readonly
  Future<int> makeNoteReadOnly(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isReadOnly': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to make the note readonly");
    }
  }

  /// Give write permission to a particular note
  Future<int> giveWriteAccess(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isReadOnly': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to give write access");
    }
  }

  /// Unbookmark a note
  Future<int> unbookmarkNote(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isBookmarked': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to unbookmark note");
    }
  }

  /// Restore archived note
  Future<int> restoreArchivedNote(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isArchived': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to restore archived note");
    }
  }

  /// Restore deleted note
  Future<int> restoreDeletedNote(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isDeleted': 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to restore deleted note");
    }
  }

  /// Soft delete (mark as deleted) a note
  Future<int> softDeleteNote(int id) async {
    final db = await instance.database;
    try {
      return await db.update(
        'notes',
        {'isDeleted': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception("Failed to soft delete note");
    }
  }

  /// Delete permanently
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    try {
      return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      throw Exception("Failed to delete note");
    }
  }

  /// Delete all notes
  Future<void> deleteAllNotes() async {
    final db = await instance.database;
    try {
      final batch = db.batch()..delete('notes');
      await batch.commit();
    } catch (e) {
      throw Exception("Failed to delete all notes");
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
