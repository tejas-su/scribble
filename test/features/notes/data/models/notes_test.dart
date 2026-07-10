import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/features/notes/data/models/notes/notes.dart';

void main() {
  group('Notes (hive legacy model)', () {
    test('defaults isSelected and isBookmarked to false', () {
      const notes = Notes(title: 't', date: 'd', content: 'c');
      expect(notes.isSelected, isFalse);
      expect(notes.isBookmarked, isFalse);
    });

    test('equality is based on title, date, content, isBookmarked, isSelected', () {
      const a = Notes(title: 't', date: 'd', content: 'c');
      const b = Notes(title: 't', date: 'd', content: 'c');
      expect(a, b);
    });

    test('differs when content changes', () {
      const a = Notes(title: 't', date: 'd', content: 'c1');
      const b = Notes(title: 't', date: 'd', content: 'c2');
      expect(a, isNot(equals(b)));
    });

    group('copyWith', () {
      const base = Notes(title: 't', date: 'd', content: 'c', isBookmarked: false);

      test('overrides only supplied fields', () {
        final updated = base.copyWith(isBookmarked: true);
        expect(updated.isBookmarked, isTrue);
        expect(updated.title, base.title);
        expect(updated.date, base.date);
        expect(updated.content, base.content);
      });

      test('with no arguments returns identical values', () {
        final copy = base.copyWith();
        expect(copy, base);
      });

      test('can toggle isSelected independently', () {
        final selected = base.copyWith(isSelected: true);
        expect(selected.isSelected, isTrue);
        expect(selected.isBookmarked, base.isBookmarked);
      });
    });
  });
}
