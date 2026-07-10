import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/features/notes/domain/enitities/note.dart';

void main() {
  Note buildNote({
    int? id,
    String title = 'title',
    String content = 'content',
    String modifiedAt = '2026-01-01',
    String createdAt = '2026-01-01',
    bool isBookMarked = false,
    bool isPinned = false,
    bool isArchived = false,
    bool isDeleted = false,
    bool isReadOnly = false,
  }) {
    return Note(
      id: id,
      title: title,
      content: content,
      modifiedAt: modifiedAt,
      createdAt: createdAt,
      isBookMarked: isBookMarked,
      isPinned: isPinned,
      isArchived: isArchived,
      isDeleted: isDeleted,
      isReadOnly: isReadOnly,
    );
  }

  group('Note', () {
    test('two notes with identical fields are equal', () {
      expect(buildNote(id: 1), buildNote(id: 1));
    });

    test('id is not part of equality (props excludes id)', () {
      // Documents current behavior: two notes that differ only by id
      // are still considered equal because `id` is absent from `props`.
      expect(buildNote(id: 1), buildNote(id: 2));
      expect(buildNote(id: null), buildNote(id: 999));
    });

    test('isDeleted is not part of equality (props excludes isDeleted)', () {
      expect(buildNote(isDeleted: true), buildNote(isDeleted: false));
    });

    test('differs when title changes', () {
      expect(buildNote(title: 'a'), isNot(equals(buildNote(title: 'b'))));
    });

    test('differs when content changes', () {
      expect(
        buildNote(content: 'a'),
        isNot(equals(buildNote(content: 'b'))),
      );
    });

    test('differs when isBookMarked changes', () {
      expect(
        buildNote(isBookMarked: true),
        isNot(equals(buildNote(isBookMarked: false))),
      );
    });

    test('differs when isPinned changes', () {
      expect(
        buildNote(isPinned: true),
        isNot(equals(buildNote(isPinned: false))),
      );
    });

    test('differs when isArchived changes', () {
      expect(
        buildNote(isArchived: true),
        isNot(equals(buildNote(isArchived: false))),
      );
    });

    test('differs when isReadOnly changes', () {
      expect(
        buildNote(isReadOnly: true),
        isNot(equals(buildNote(isReadOnly: false))),
      );
    });

    test('supports empty title and content strings', () {
      final note = buildNote(title: '', content: '');
      expect(note.title, '');
      expect(note.content, '');
    });

    test('id defaults to null when not supplied', () {
      final note = buildNote();
      expect(note.id, isNull);
    });
  });
}
