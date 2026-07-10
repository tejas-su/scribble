import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/core/utils/extensions.dart';

void main() {
  group('StringToFormattedDate.yMMMEdFormat', () {
    test('formats a valid ISO date string', () {
      final formatted = '2026-01-15T00:00:00.000'.yMMMEdFormat;
      expect(formatted, 'Thu, Jan 15, 2026');
    });

    test('returns the original string when it cannot be parsed', () {
      const invalid = 'not-a-date';
      expect(invalid.yMMMEdFormat, invalid);
    });

    test('returns the original string for an empty string', () {
      expect(''.yMMMEdFormat, '');
    });

    test('formats a date-only string without a time component', () {
      final formatted = '2026-12-25'.yMMMEdFormat;
      expect(formatted, 'Fri, Dec 25, 2026');
    });
  });
}
