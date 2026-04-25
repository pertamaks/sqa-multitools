import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:sqa_multitools/plugins/text_editor/ui/widgets/text_node_encoder_parsers.dart';
import 'package:sqa_multitools/plugins/text_editor/ui/widgets/sqa_delta_markdown_encoder.dart';

void main() {
  group('SqaQuoteNodeParser', () {
    test('should transform quote node to markdown with > prefix and double newline', () {
      // 1. Arrange: Create a quote node with a delta
      final node = Node(
        type: QuoteBlockKeys.type,
        attributes: {
          'delta': (Delta()..insert('Hello SQA World')).toJson(),
        },
      );
      
      const parser = SqaQuoteNodeParser();
      
      // 2. Act: Transform the node
      final result = parser.transform(node, null);
      
      // 3. Assert: Verify the "Whitespace Firewall" and prefix
      expect(result, equals('> Hello SQA World\n\n'));
    });

    test('should return empty string if delta is missing', () {
      final node = Node(
        type: QuoteBlockKeys.type,
        attributes: {},
      );
      
      const parser = SqaQuoteNodeParser();
      final result = parser.transform(node, null);
      
      expect(result, equals(''));
    });
  });

  group('SqaDeltaMarkdownEncoder', () {
    test('should encode strikethrough correctly', () {
      final delta = Delta()..insert('struck', attributes: {AppFlowyRichTextKeys.strikethrough: true});
      final encoder = SqaDeltaMarkdownEncoder();
      expect(encoder.convert(delta), equals('~~struck~~'));
    });

    test('should encode colors using HTML spans', () {
      final delta = Delta()..insert('colored', attributes: {
        AppFlowyRichTextKeys.textColor: '#ff0000',
        AppFlowyRichTextKeys.backgroundColor: '#ffff00',
      });
      final encoder = SqaDeltaMarkdownEncoder();
      expect(encoder.convert(delta), equals('<span style="color:#ff0000;background-color:#ffff00;">colored</span>'));
    });

    test('should encode combined styles (bold + color)', () {
      final delta = Delta()..insert('both', attributes: {
        AppFlowyRichTextKeys.bold: true,
        AppFlowyRichTextKeys.textColor: '#ff0000',
      });
      final encoder = SqaDeltaMarkdownEncoder();
      // Bold is wrapped outside/inside depending on order in encoder, SqaDeltaMarkdownEncoder puts span inside bold
      expect(encoder.convert(delta), equals('**<span style="color:#ff0000;">both</span>**'));
    });
  });
}
