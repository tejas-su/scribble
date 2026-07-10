import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scribble/src/core/utils/text_highlight_util.dart';

void main() {
  const baseStyle = TextStyle(color: Colors.black, fontSize: 14);

  group('buildHighlightedText', () {
    test('returns plain span when searchQuery is null', () {
      final span = buildHighlightedText(
        text: 'hello world',
        searchQuery: null,
        baseStyle: baseStyle,
      );
      expect(span.text, 'hello world');
      expect(span.children, isNull);
    });

    test('returns plain span when searchQuery is empty', () {
      final span = buildHighlightedText(
        text: 'hello world',
        searchQuery: '',
        baseStyle: baseStyle,
      );
      expect(span.text, 'hello world');
      expect(span.children, isNull);
    });

    test('returns text that renders unchanged when there is no match', () {
      // Implementation detail: a non-empty, no-match input goes through the
      // spans-accumulation path and comes back wrapped as a single child
      // span rather than a flat TextSpan, so compare via toPlainText().
      final span = buildHighlightedText(
        text: 'hello world',
        searchQuery: 'xyz',
        baseStyle: baseStyle,
      );
      expect(span.toPlainText(), 'hello world');
    });

    test('highlights a single match with background color', () {
      final span = buildHighlightedText(
        text: 'hello world',
        searchQuery: 'world',
        baseStyle: baseStyle,
        highlightColor: Colors.yellow,
      );

      expect(span.children, isNotNull);
      expect(span.children!.length, 2);
      final prefix = span.children![0] as TextSpan;
      final match = span.children![1] as TextSpan;
      expect(prefix.text, 'hello ');
      expect(match.text, 'world');
      expect(match.style!.backgroundColor, Colors.yellow);
    });

    test('is case-insensitive', () {
      final span = buildHighlightedText(
        text: 'Hello World',
        searchQuery: 'world',
        baseStyle: baseStyle,
      );
      final match = span.children!.last as TextSpan;
      expect(match.text, 'World');
    });

    test('highlights multiple occurrences', () {
      final span = buildHighlightedText(
        text: 'cat bat cat',
        searchQuery: 'cat',
        baseStyle: baseStyle,
      );

      final matches = span.children!
          .whereType<TextSpan>()
          .where((s) => s.style?.backgroundColor != null)
          .map((s) => s.text)
          .toList();
      expect(matches, ['cat', 'cat']);
    });

    test('handles a match at the very start of the text', () {
      final span = buildHighlightedText(
        text: 'catalog',
        searchQuery: 'cat',
        baseStyle: baseStyle,
      );
      final firstChild = span.children!.first as TextSpan;
      expect(firstChild.text, 'cat');
      expect(firstChild.style!.backgroundColor, isNotNull);
    });

    test('handles a match that spans the entire text', () {
      final span = buildHighlightedText(
        text: 'cat',
        searchQuery: 'cat',
        baseStyle: baseStyle,
      );
      expect(span.children!.length, 1);
      final match = span.children!.first as TextSpan;
      expect(match.text, 'cat');
    });

    test('escapes regex special characters in the search query', () {
      final span = buildHighlightedText(
        text: 'price: \$5 (discount)',
        searchQuery: r'$5 (discount)',
        baseStyle: baseStyle,
      );
      expect(span.children, isNotNull);
      final match = span.children!.last as TextSpan;
      expect(match.text, r'$5 (discount)');
    });
  });
}
