import 'package:appflowy_editor/appflowy_editor.dart';

import '../ui/widgets/code_block_encoder_parser.dart';
import '../ui/widgets/code_block_builder.dart';
import '../ui/widgets/table_node_encoder_parser.dart';
import '../ui/widgets/table_node_loader_parser.dart';
import '../ui/widgets/html_node_loader_parser.dart';
import '../ui/widgets/html_node_encoder_parser.dart';
import '../ui/widgets/text_node_encoder_parsers.dart';
import '../ui/widgets/list_node_encoder_parsers.dart';
import '../ui/widgets/image_node_encoder_parser.dart';

class SqaMarkdownService {
  static Document parse(String text) {
    if (text.isEmpty) return Document.blank(withInitialText: true);
    
    // We cannot access standard parsers directly, so we merge them by 
    // simply using the default markdownParsers provided by appflowy_editor if possible,
    // or we must include them if we override. Let's see if providing just ours
    // overrides everything or merges. Usually it merges in newer versions.
    return markdownToDocument(
      text,
      markdownParsers: [
        const SqaMarkdownCodeBlockParser(),
        const SqaMarkdownTableParser(),
        const SqaMarkdownHtmlParser(),
        const SqaMarkdownImageParser(),
      ],
    );
  }

  static String serialize(Document document) {
    return documentToMarkdown(
      document,
      customParsers: [
        const SqaHeadingNodeParser(),
        const SqaParagraphNodeParser(),
        const SqaCodeBlockNodeParser(),
        const SqaTableNodeParser(),
        const SqaHtmlNodeParser(),
        const SqaBulletedListNodeParser(),
        const SqaNumberedListNodeParser(),
        const SqaTodoListNodeParser(),
        const SqaImageNodeParser(),
      ],
    );
  }
}
