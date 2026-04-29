import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../models/text_editor_state.dart';

class TextEditorSaveStatus extends StatelessWidget {
  final TextEditorState state;

  const TextEditorSaveStatus({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnsavedChanges = state.hasUnsavedChanges;
    final isSaving = state.isSaving;

    final bool isSaved = !hasUnsavedChanges && !isSaving;

    return Tooltip(
      message: isSaved
          ? 'All changes saved'
          : (isSaving ? 'Saving...' : 'Unsaved changes'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(
          Symbols.check_circle,
          size: 20,
          color: isSaved
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
