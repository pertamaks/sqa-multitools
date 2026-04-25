import 'package:flutter_test/flutter_test.dart';
import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:sqa_multitools/plugins/text_editor/ui/widgets/text_node_encoder_parsers.dart';

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
}
