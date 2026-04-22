import 'package:flutter/material.dart';

/// A specialized [TextEditingController] that provides real-time, in-place
/// Markdown styling for a "human-readable" editing experience.
///
/// It styles common Markdown patterns like headers, bold, italic, and code
/// without hiding the syntax, ensuring the content remains standard Markdown.
class SqaMdTextController extends TextEditingController {
  SqaMdTextController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final List<TextSpan> children = [];

    // Broad regex-based patterns for human-readable MD rendering
    final RegExp mdPattern = RegExp(
      r'(^#+ .*)|(\*\*.*?\*\*)|(\*.*?\*)|(_.*?_)|(src=".*?")|(href=".*?")|(`.*?`)|(https?:\/\/\S+)',
      multiLine: true,
    );

    int lastMatchEnd = 0;

    text.splitMapJoin(
      mdPattern,
      onMatch: (Match match) {
        final String matchText = match[0]!;

        // Add text before the match
        if (match.start > lastMatchEnd) {
          children
              .add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
        }

        TextStyle? matchStyle;

        if (matchText.startsWith('#')) {
          // Headers: Map # to larger, bold primary colored text
          final int level = matchText.indexOf(' ');
          double fontSize = style?.fontSize ?? 14.0;
          if (level == 1) fontSize *= 1.8;
          if (level == 2) fontSize *= 1.5;
          if (level == 3) fontSize *= 1.2;

          matchStyle = style?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            color: colorScheme.primary,
          );
        } else if (matchText.startsWith('**')) {
          // Bold: **text**
          matchStyle = style?.copyWith(fontWeight: FontWeight.bold);
        } else if (matchText.startsWith('*') || matchText.startsWith('_')) {
          // Italic: *text* or _text_
          matchStyle = style?.copyWith(fontStyle: FontStyle.italic);
        } else if (matchText.startsWith('`')) {
          // Inline Code: `text`
          matchStyle = style?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: colorScheme.surfaceContainerHigh,
            color: colorScheme.secondary,
          );
        } else if (matchText.startsWith('http')) {
          // Links: https://...
          matchStyle = style?.copyWith(
            color: colorScheme.tertiary,
            decoration: TextDecoration.underline,
          );
        }

        children.add(TextSpan(text: matchText, style: matchStyle));
        lastMatchEnd = match.end;
        return matchText;
      },
      onNonMatch: (String nonMatch) {
        return nonMatch;
      },
    );

    // Add remaining text after the last match
    if (lastMatchEnd < text.length) {
      children.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return TextSpan(style: style, children: children);
  }
}
