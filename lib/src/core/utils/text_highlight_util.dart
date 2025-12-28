import 'package:flutter/material.dart';

/// Builds a TextSpan with highlighted search terms
///
/// [text] - The text to display
/// [searchQuery] - The search term to highlight (case-insensitive)
/// [baseStyle] - The base text style
/// [highlightColor] - The background color for highlighted text (default: yellow)
TextSpan buildHighlightedText({
  required String text,
  required String? searchQuery,
  required TextStyle baseStyle,
  Color highlightColor = const Color(0xFFFFD700), // Material Yellow
}) {
  // If no search query, return plain text
  if (searchQuery == null || searchQuery.isEmpty) {
    return TextSpan(text: text, style: baseStyle);
  }
  // Use RegExp for case-insensitive matching and exact match ranges
  final List<TextSpan> spans = [];
  final regExp = RegExp(RegExp.escape(searchQuery), caseSensitive: false);
  int lastMatchEnd = 0;

  for (final match in regExp.allMatches(text)) {
    if (match.start > lastMatchEnd) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ),
      );
    }

    final matchedText =
        match.group(0) ?? text.substring(match.start, match.end);
    spans.add(
      TextSpan(
        text: matchedText,
        style: baseStyle.copyWith(
          backgroundColor: highlightColor,
          color: Colors.black,
        ),
      ),
    );

    lastMatchEnd = match.end;
  }

  if (lastMatchEnd < text.length) {
    spans.add(TextSpan(text: text.substring(lastMatchEnd), style: baseStyle));
  }

  // If no matches found, return plain text to avoid empty children
  if (spans.isEmpty) return TextSpan(text: text, style: baseStyle);

  return TextSpan(children: spans);
}
