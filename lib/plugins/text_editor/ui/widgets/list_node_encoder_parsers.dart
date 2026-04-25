import 'package:appflowy_editor/appflowy_editor.dart';
import 'sqa_delta_markdown_encoder.dart';

class SqaBulletedListNodeParser extends NodeParser {
  const SqaBulletedListNodeParser();
  @override
  String get id => BulletedListBlockKeys.type;
  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta;
    if (delta == null) return '';
    final text = SqaDeltaMarkdownEncoder().convert(delta);
    return '* $text\n';
  }
}

class SqaNumberedListNodeParser extends NodeParser {
  const SqaNumberedListNodeParser();
  @override
  String get id => NumberedListBlockKeys.type;
  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta;
    final number = node.attributes[NumberedListBlockKeys.number] as int? ?? 1;
    if (delta == null) return '';
    final text = SqaDeltaMarkdownEncoder().convert(delta);
    return '$number. $text\n';
  }
}

class SqaTodoListNodeParser extends NodeParser {
  const SqaTodoListNodeParser();
  @override
  String get id => TodoListBlockKeys.type;
  @override
  String transform(Node node, DocumentMarkdownEncoder? encoder) {
    final delta = node.delta;
    final checked =
        node.attributes[TodoListBlockKeys.checked] as bool? ?? false;
    if (delta == null) return '';
    final text = SqaDeltaMarkdownEncoder().convert(delta);
    return '* [${checked ? 'x' : ' '}] $text\n';
  }
}
