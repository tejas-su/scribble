import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/features/notes/data/models/migration_notes/notes_model.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';

void main() {
  group('NotesModel.toMap', () {
    test('converts bool flags to 1/0 and preserves other fields', () {
      const model = NotesModel(
        id: 5,
        title: 'title',
        content: 'content',
        modifiedAt: '2026-01-02',
        createdAt: '2026-01-01',
        isBookMarked: true,
        isArchived: false,
        isDeleted: true,
        isReadOnly: false,
      );

      final map = model.toMap();

      expect(map['id'], 5);
      expect(map['title'], 'title');
      expect(map['content'], 'content');
      expect(map['modifiedAt'], '2026-01-02');
      expect(map['createdAt'], '2026-01-01');
      expect(map['isBookMarked'], 1);
      expect(map['isArchived'], 0);
      expect(map['isDeleted'], 1);
      // Note: toMap intentionally omits isReadOnly (not present in the map).
      expect(map.containsKey('isReadOnly'), isFalse);
    });

    test('null id round-trips as null in the map', () {
      const model = NotesModel(
        title: 't',
        content: 'c',
        modifiedAt: 'm',
        createdAt: 'c',
        isBookMarked: false,
        isArchived: false,
        isDeleted: false,
        isReadOnly: false,
      );
      expect(model.toMap()['id'], isNull);
    });
  });

  group('NotesModel.fromMap', () {
    test('parses 1/0 integers back into booleans', () {
      final model = NotesModel.fromMap({
        'id': 3,
        'title': 'title',
        'content': 'content',
        'modifiedAt': '2026-01-02',
        'createdAt': '2026-01-01',
        'isBookMarked': 1,
        'isArchived': 0,
        'isDeleted': 1,
        'isReadOnly': 0,
      });

      expect(model.id, 3);
      expect(model.isBookMarked, isTrue);
      expect(model.isArchived, isFalse);
      expect(model.isDeleted, isTrue);
      expect(model.isReadOnly, isFalse);
    });

    test('treats any non-1 value as false', () {
      final model = NotesModel.fromMap({
        'id': 1,
        'title': 't',
        'content': 'c',
        'modifiedAt': 'm',
        'createdAt': 'c',
        'isBookMarked': 2,
        'isArchived': null,
        'isDeleted': 0,
        'isReadOnly': 0,
      });

      expect(model.isBookMarked, isFalse);
      expect(model.isArchived, isFalse);
    });
  });

  group('NotesModel.fromEntity', () {
    test('copies every field from a base Note', () {
      const note = Note(
        id: 7,
        title: 'title',
        content: 'content',
        modifiedAt: 'mod',
        createdAt: 'created',
        isBookMarked: true,
        isArchived: true,
        isDeleted: false,
        isReadOnly: true,
      );

      final model = NotesModel.fromEntity(note);

      expect(model.id, 7);
      expect(model.title, 'title');
      expect(model.content, 'content');
      expect(model.modifiedAt, 'mod');
      expect(model.createdAt, 'created');
      expect(model.isBookMarked, isTrue);
      expect(model.isArchived, isTrue);
      expect(model.isDeleted, isFalse);
      expect(model.isReadOnly, isTrue);
    });
  });

  group('NotesModel.copyWith', () {
    const base = NotesModel(
      id: 1,
      title: 'title',
      content: 'content',
      modifiedAt: 'mod',
      createdAt: 'created',
      isBookMarked: false,
      isArchived: false,
      isDeleted: false,
      isReadOnly: false,
    );

    test('overrides only the requested fields', () {
      final updated = base.copyWith(title: 'new title', isBookMarked: true);

      expect(updated.title, 'new title');
      expect(updated.isBookMarked, isTrue);
      expect(updated.content, base.content);
      expect(updated.createdAt, base.createdAt);
    });

    test('with no arguments returns an equivalent copy', () {
      final copy = base.copyWith();
      expect(copy.title, base.title);
      expect(copy.content, base.content);
      expect(copy.isArchived, base.isArchived);
    });

    test('"date" parameter maps to modifiedAt', () {
      final updated = base.copyWith(date: '2026-05-05');
      expect(updated.modifiedAt, '2026-05-05');
      expect(updated.createdAt, base.createdAt);
    });
  });
}
