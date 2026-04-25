import 'dart:convert';
import 'package:appflowy_editor/appflowy_editor.dart';

/// A custom SQA Delta encoder that supports strikethrough, text color, and background color.
/// Colors are encoded using HTML spans for maximum compatibility with rich text viewers
/// while remaining within a Markdown-compatible structure.
class SqaDeltaMarkdownEncoder extends Converter<Delta, String> {
  @override
  String convert(Delta input) {
    final buffer = StringBuffer();
    final iterator = input.iterator;
    while (iterator.moveNext()) {
      final op = iterator.current;
      if (op is TextInsert) {
        final attributes = op.attributes;
        if (attributes != null) {
          final formula =
              (attributes[BuiltInAttributeKey.formula] as String?) ?? '';
          buffer.write(_prefixSyntax(attributes));
          if (formula.isNotEmpty) {
            buffer.write(formula);
          } else {
            buffer.write(op.text);
          }
          buffer.write(_suffixSyntax(attributes));
        } else {
          buffer.write(op.text);
        }
      }
    }

    return buffer.toString();
  }

  String _prefixSyntax(Attributes attributes) {
    var syntax = '';

    // Bold & Italic
    if (attributes[BuiltInAttributeKey.bold] == true &&
        attributes[BuiltInAttributeKey.italic] == true) {
      syntax += '***';
    } else if (attributes[BuiltInAttributeKey.bold] == true) {
      syntax += '**';
    } else if (attributes[BuiltInAttributeKey.italic] == true) {
      syntax += '_';
    }

    // Strikethrough
    if (attributes[BuiltInAttributeKey.strikethrough] == true) {
      syntax += '~~';
    }

    // Underline
    if (attributes[BuiltInAttributeKey.underline] == true) {
      syntax += '<u>';
    }

    // Code
    if (attributes[BuiltInAttributeKey.code] == true) {
      syntax += '`';
    }

    // Link
    if (attributes[BuiltInAttributeKey.href] != null) {
      syntax += '[';
    }

    // Colors (HTML Span)
    final textColor = attributes[AppFlowyRichTextKeys.textColor] as String?;
    final bgColor = attributes[AppFlowyRichTextKeys.backgroundColor] as String?;

    if (textColor != null || bgColor != null) {
      syntax += '<span style="';
      if (textColor != null) syntax += 'color:$textColor;';
      if (bgColor != null) syntax += 'background-color:$bgColor;';
      syntax += '">';
    }

    if (attributes[BuiltInAttributeKey.formula] != null) {
      syntax += r'$';
    }

    return syntax;
  }

  String _suffixSyntax(Attributes attributes) {
    var syntax = '';

    if (attributes[BuiltInAttributeKey.formula] != null) {
      syntax += r'$';
    }

    // Colors
    final textColor = attributes[AppFlowyRichTextKeys.textColor] as String?;
    final bgColor = attributes[AppFlowyRichTextKeys.backgroundColor] as String?;
    if (textColor != null || bgColor != null) {
      syntax += '</span>';
    }

    if (attributes[BuiltInAttributeKey.href] != null) {
      syntax += '](${attributes[BuiltInAttributeKey.href]})';
    }

    if (attributes[BuiltInAttributeKey.code] == true) {
      syntax += '`';
    }

    if (attributes[BuiltInAttributeKey.underline] == true) {
      syntax += '</u>';
    }

    if (attributes[BuiltInAttributeKey.strikethrough] == true) {
      syntax += '~~';
    }

    if (attributes[BuiltInAttributeKey.bold] == true &&
        attributes[BuiltInAttributeKey.italic] == true) {
      syntax += '***';
    } else if (attributes[BuiltInAttributeKey.bold] == true) {
      syntax += '**';
    } else if (attributes[BuiltInAttributeKey.italic] == true) {
      syntax += '_';
    }

    return syntax;
  }
}
