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

  final List<TextSpan> spans = [];
  final String lowerText = text.toLowerCase();
  final String lowerQuery = searchQuery.toLowerCase();

  int start = 0;
  int index = lowerText.indexOf(lowerQuery);

  while (index != -1) {
    // Add text before match
    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index), style: baseStyle));
    }

    // Add highlighted match
    spans.add(
      TextSpan(
        text: text.substring(index, index + lowerQuery.length),
        style: baseStyle.copyWith(
          background: Paint()
            ..color = highlightColor
            ..style = PaintingStyle.fill,
          color: Colors.black, // Ensure text is readable on yellow background
        ),
      ),
    );

    start = index + lowerQuery.length;
    index = lowerText.indexOf(lowerQuery, start);
  }

  // Add remaining text
  if (start < text.length) {
    spans.add(TextSpan(text: text.substring(start), style: baseStyle));
  }

  return TextSpan(children: spans);
}
