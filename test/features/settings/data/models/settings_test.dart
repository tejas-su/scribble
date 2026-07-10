import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/features/settings/data/models/settings/settings.dart';

void main() {
  group('Settings', () {
    test('sortByModifiedDate defaults to true', () {
      const settings = Settings(isGrid: true, isDarkMode: false);
      expect(settings.sortByModifiedDate, isTrue);
    });

    test('equality is based on isGrid, isDarkMode, sortByModifiedDate', () {
      const a = Settings(isGrid: true, isDarkMode: true, sortByModifiedDate: false);
      const b = Settings(isGrid: true, isDarkMode: true, sortByModifiedDate: false);
      expect(a, b);
    });

    test('differs when isDarkMode changes', () {
      const a = Settings(isGrid: true, isDarkMode: true);
      const b = Settings(isGrid: true, isDarkMode: false);
      expect(a, isNot(equals(b)));
    });

    test('differs when sortByModifiedDate changes', () {
      const a = Settings(isGrid: true, isDarkMode: true, sortByModifiedDate: true);
      const b = Settings(isGrid: true, isDarkMode: true, sortByModifiedDate: false);
      expect(a, isNot(equals(b)));
    });
  });
}
