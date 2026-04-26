import 'package:markdown/markdown.dart' as md;
import 'package:appflowy_editor/appflowy_editor.dart';

/// A custom Markdown inline syntax for parsing <span style="..."> tags.
/// It extracts color and background-color styles and converts them into
/// AppFlowy font_color and bg_color attributes.
class SqaSpanInlineSyntax extends md.InlineSyntax {
  SqaSpanInlineSyntax() : super(r'<span style="([^"]*)">([^<]*)</span>');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final style = match.group(1) ?? '';
    final text = match.group(2) ?? '';

    final attributes = <String, String>{};

    // Parse style string: "color:#ff0000;background-color:#ffff00;"
    final parts = style.split(';');
    for (var part in parts) {
      if (part.contains(':')) {
        final kv = part.split(':');
        final key = kv[0].trim();
        final value = kv[1].trim();

        if (key == 'color') {
          attributes[AppFlowyRichTextKeys.textColor] = '"$value"';
        } else if (key == 'background-color') {
          attributes[AppFlowyRichTextKeys.backgroundColor] = '"$value"';
        }
      }
    }

    final element = md.Element('span', [md.Text(text)]);
    element.attributes.addAll(attributes);
    parser.addNode(element);
    return true;
  }
}
