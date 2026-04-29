import 'dart:io';

void main() {
  final file = File('lib/plugins/todo/ui/widgets/todo_list_item.dart');
  var content = file.readAsStringSync();
  
  String removeBlock(String source, String startToken) {
    int startIdx = source.indexOf(startToken);
    if (startIdx == -1) return source;
    
    int braceCount = 0;
    bool started = false;
    int endIdx = -1;
    
    for (int i = startIdx; i < source.length; i++) {
      if (source[i] == '{') {
        braceCount++;
        started = true;
      } else if (source[i] == '}') {
        braceCount--;
      }
      
      if (started && braceCount == 0) {
        endIdx = i;
        break;
      }
    }
    
    if (endIdx != -1) {
      return source.substring(0, startIdx) + source.substring(endIdx + 1);
    }
    return source;
  }

  // 1. Add imports
  content = content.replaceFirst("import 'package:intl/intl.dart';", "import 'package:intl/intl.dart';\nimport 'todo_item_badges.dart';\nimport 'todo_item_dialogs.dart';");

  // 2. Remove dialog methods
  content = removeBlock(content, 'void _showHistorySummaryModal(');
  content = removeBlock(content, 'void _showNotesDialog(');
  content = removeBlock(content, 'void _showDelegateDialog(');
  content = removeBlock(content, 'void _showDeferDialog(');
  content = removeBlock(content, 'Widget _buildSummaryRow(');
  content = removeBlock(content, 'Widget _buildDeferOption(');
  content = removeBlock(content, 'int _getHourForTimeBlock(');
  content = removeBlock(content, 'Widget _buildBadge(');

  // 3. Replace Wrap with TodoItemBadges
  final wrapStart = 'child: Wrap(';
  int wrapIdx = content.indexOf(wrapStart);
  if (wrapIdx != -1) {
    int wrapEndIdx = -1;
    int braceCount = 0;
    bool started = false;
    for (int i = wrapIdx; i < content.length; i++) {
      if (content[i] == '(') { braceCount++; started = true; }
      else if (content[i] == ')') { braceCount--; }
      if (started && braceCount == 0) { wrapEndIdx = i; break; }
    }
    
    if (wrapEndIdx != -1) {
      final replacement = 'child: TodoItemBadges(item: widget.item, isReadOnly: widget.isReadOnly, completionBadgeText: completionBadgeText, use24HourFormat: ref.watch(todoSettingsProvider).value?.use24HourFormat ?? true,)';
      content = content.substring(0, wrapIdx) + replacement + content.substring(wrapEndIdx + 1);
    }
  }

  // 4. Update method calls
  content = content.replaceAll('_showHistorySummaryModal(context)', 'TodoItemDialogs.showHistorySummary(context, ref, widget.item)');
  content = content.replaceAll('_showDelegateDialog(context, ref)', 'TodoItemDialogs.showDelegate(context, ref, widget.item)');
  content = content.replaceAll('_showNotesDialog(context, ref)', 'TodoItemDialogs.showNotes(context, ref, widget.item)');
  content = content.replaceAll('_showDeferDialog(context, ref)', 'TodoItemDialogs.showDefer(context, ref, widget.item)');

  file.writeAsStringSync(content);
  print('Refactored todo_list_item.dart');
}
