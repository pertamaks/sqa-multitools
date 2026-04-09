import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:faker_dart/faker_dart.dart';
import '../../core/utils/locale_names.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_segmented_button.dart';
import '../../ui/widgets/sqa_field.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_dropdown.dart';
import '../../ui/widgets/sqa_settings_tile.dart';
import '../../ui/widgets/sqa_switch.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';
import 'models/identity_state.dart';
import 'models/text_state.dart';
import 'models/glyphs_state.dart';
import 'models/dev_state.dart';
import 'providers/identity_provider.dart';
import 'providers/text_provider.dart';
import 'providers/glyphs_provider.dart';
import 'providers/dev_provider.dart';
import 'widgets/identity_config_panel.dart';
import 'widgets/text_config_panel.dart';
import 'widgets/glyphs_config_panel.dart';
import 'widgets/dev_config_panel.dart';

class DataGeneratorPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.data_generator';
  @override
  String get name => 'Data Generator';
  @override
  String get description => 'Generate mock UUIDs, emails, etc.';
  @override
  IconData get icon => Symbols.wand_stars;
  @override
  String? get badge => null;
  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _DataGeneratorView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const _DataGeneratorSettingsPanel();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _DataGeneratorSettingsPanel extends ConsumerWidget {
  const _DataGeneratorSettingsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(identityProvider);
    final notifier = ref.read(identityProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENERATOR SETTINGS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LOCALE',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _LocaleDropdown(
                    value: state.locale,
                    onChanged: (val) {
                      if (val != null) notifier.setLocale(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'COUNT',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _CountDropdown(
                    value: state.quantity,
                    onChanged: (val) {
                      if (val != null) notifier.setQuantity(val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SqaSettingsTile(
          title: 'INCLUDE FORMATTING',
          subtitle: 'Prefix each result with a bullet point (•)',
          titleStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          trailing: SqaSwitch(
            value: state.includeFormatting,
            onChanged: (val) => notifier.setIncludeFormatting(val),
          ),
        ),
        SqaSettingsTile(
          title: 'INCLUDE EXTENSION',
          subtitle: 'Include phone extensions (e.g. x123)',
          titleStyle: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
          trailing: SqaSwitch(
            value: state.includeExtension,
            onChanged: (val) => notifier.setIncludeExtension(val),
          ),
        ),
      ],
    );
  }
}

class _LocaleDropdown extends StatelessWidget {
  final FakerLocaleType value;
  final ValueChanged<FakerLocaleType?> onChanged;

  const _LocaleDropdown({required this.value, required this.onChanged});

  String _formatName(FakerLocaleType locale) {
    return LocaleNames.getDisplayName(locale.name);
  }

  @override
  Widget build(BuildContext context) {
    // Sort locales by name for better UX
    final sortedLocales = FakerLocaleType.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return SqaDropdown<FakerLocaleType>(
      value: value,
      items: sortedLocales.map((locale) {
        return DropdownMenuItem<FakerLocaleType>(
          value: locale,
          child: Text(
            _formatName(locale),
            style: const TextStyle(fontSize: 12),
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _CountDropdown extends StatelessWidget {
  final int value;
  final ValueChanged<int?> onChanged;

  const _CountDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SqaDropdown<int>(
      value: value,
      items: [1, 5, 10, 20, 50]
          .map((e) => DropdownMenuItem(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _DataGeneratorView extends StatelessWidget {
  const _DataGeneratorView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: SqaPluginLayout(
        icon: Symbols.wand_stars,
        title: 'Data Generator',
        description: 'Generate mock UUIDs, emails, numbers, and more.',
        tabs: const [
          Tab(icon: Icon(Symbols.person), text: 'Identity'),
          Tab(icon: Icon(Symbols.notes), text: 'Lorem'),
          Tab(icon: Icon(Symbols.glyphs), text: 'Glyphs'),
          Tab(icon: Icon(Symbols.terminal), text: 'Dev'),
        ],
        child: const TabBarView(
          children: [
            _IdentityTabView(),
            _LoremTabView(),
            _GlyphsTabView(),
            _DevTabView(),
          ],
        ),
      ),
    );
  }
}

class _IdentityTabView extends ConsumerStatefulWidget {
  const _IdentityTabView();

  @override
  ConsumerState<_IdentityTabView> createState() => _IdentityTabViewState();
}

class _IdentityTabViewState extends ConsumerState<_IdentityTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(identityProvider);
    final notifier = ref.read(identityProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<IdentityType>(
            segments: const [
              ButtonSegment(
                value: IdentityType.email,
                label: Text('Email'),
                icon: Icon(Symbols.mail),
              ),
              ButtonSegment(
                value: IdentityType.address,
                label: Text('Address'),
                icon: Icon(Symbols.home),
              ),
              ButtonSegment(
                value: IdentityType.phone,
                label: Text('Phone'),
                icon: Icon(Symbols.call),
              ),
              ButtonSegment(
                value: IdentityType.internet,
                label: Text('Net'),
                icon: Icon(Symbols.language),
              ),
              ButtonSegment(
                value: IdentityType.company,
                label: Text('Work'),
                icon: Icon(Symbols.business),
              ),
            ],
            selected: {state.selectedType},
            onSelectionChanged: (set) => notifier.setType(set.first),
          ),
          const SizedBox(height: 24),
          const IdentityConfigPanel(),
          if ((state.resultsMap[state.selectedType] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            SqaField(
              label: 'Result',
              initialValue: state.includeFormatting
                  ? (state.resultsMap[state.selectedType] ?? <String>[])
                        .map((String e) => '• $e')
                        .join('\n')
                  : (state.resultsMap[state.selectedType] ?? <String>[]).join(
                      '\n',
                    ),
              icon: Symbols.content_copy,
              isMultiline: true,
              collapsedMaxLines: 10,
            ),
          ],
        ],
      ),
    );
  }
}

class _LoremTabView extends ConsumerStatefulWidget {
  const _LoremTabView();

  @override
  ConsumerState<_LoremTabView> createState() => _LoremTabViewState();
}

class _LoremTabViewState extends ConsumerState<_LoremTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(textGeneratorProvider);
    final notifier = ref.read(textGeneratorProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<TextType>(
            segments: const [
              ButtonSegment(
                value: TextType.bytes,
                label: Text('Bytes'),
                icon: Icon(Symbols.abc),
              ),
              ButtonSegment(
                value: TextType.sentence,
                label: Text('Sentence'),
                icon: Icon(Symbols.short_text),
              ),
              ButtonSegment(
                value: TextType.paragraph,
                label: Text('Paragraph'),
                icon: Icon(Symbols.notes),
              ),
              ButtonSegment(
                value: TextType.chapter,
                label: Text('Chapter'),
                icon: Icon(Symbols.book),
              ),
            ],
            selected: {state.selectedType},
            onSelectionChanged: (set) => notifier.setType(set.first),
          ),
          const SizedBox(height: 24),
          const TextConfigPanel(),
          if ((state.resultsMap[state.selectedType] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            SqaField(
              label: 'Result',
              initialValue: (state.resultsMap[state.selectedType] ?? <String>[])
                  .join('\n\n---\n\n'),
              icon: Symbols.content_copy,
              isMultiline: true,
              collapsedMaxLines: 10,
            ),
          ],
        ],
      ),
    );
  }
}

class _DevTabView extends ConsumerStatefulWidget {
  const _DevTabView();

  @override
  ConsumerState<_DevTabView> createState() => _DevTabViewState();
}

class _DevTabViewState extends ConsumerState<_DevTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(devGeneratorProvider);
    final notifier = ref.read(devGeneratorProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<DevType>(
            hasChild:
                state.selectedType == DevType.json ||
                state.selectedType == DevType.date,
            segments: const [
              ButtonSegment(
                value: DevType.uuid,
                label: Text('UUID'),
                icon: Icon(Symbols.fingerprint),
              ),
              ButtonSegment(
                value: DevType.json,
                label: Text('JSON'),
                icon: Icon(Symbols.code),
              ),
              ButtonSegment(
                value: DevType.date,
                label: Text('Date'),
                icon: Icon(Symbols.calendar_today),
              ),
            ],
            selected: {state.selectedType},
            onSelectionChanged: (set) => notifier.setType(set.first),
          ),
          if (state.selectedType == DevType.uuid) const SizedBox(height: 24),
          const DevConfigPanel(),
          if ((state.resultsMap[state.selectedType] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            ..._buildDevResults(state),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDevResults(DevState state) {
    final results = state.resultsMap[state.selectedType] ?? <String>[];
    if (state.selectedType == DevType.date && results.length == 5) {
      final labels = [
        'ISO 8601',
        'RFC 2822',
        'SQL DATETIME',
        'UNIX TIMESTAMP',
        'HUMAN READABLE',
      ];
      return List.generate(5, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 4 ? 0 : 16.0),
          child: SqaField(
            label: labels[index],
            initialValue: results[index],
            icon: Symbols.calendar_today,
            isMonospace: true,
          ),
        );
      });
    }

    if (state.selectedType == DevType.uuid && results.isNotEmpty) {
      final latest = results.first;
      final history = state.uuidHistory.where((u) => u != latest).toList();

      return [
        SqaField(
          label: 'Latest UUID',
          initialValue: latest,
          icon: Symbols.fingerprint,
          isMonospace: true,
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 24),
          SqaField(
            label: 'HISTORY (LAST 10)',
            initialValue: history.join('\n'),
            icon: Symbols.history,
            isMultiline: true,
            isMonospace: true,
            collapsedMaxLines: 10,
          ),
        ],
      ];
    }

    // JSON or fallback
    return [
      SqaField(
        label: 'Result',
        initialValue: results.join('\n\n---\n\n'),
        icon: _getDevIcon(state.selectedType),
        isMultiline: true,
        isMonospace: true,
        collapsedMaxLines: 10,
      ),
    ];
  }

  IconData _getDevIcon(DevType type) {
    switch (type) {
      case DevType.uuid:
        return Symbols.fingerprint;
      case DevType.json:
        return Symbols.code;
      case DevType.date:
        return Symbols.calendar_today;
    }
  }
}

class _GlyphsTabView extends ConsumerStatefulWidget {
  const _GlyphsTabView();

  @override
  ConsumerState<_GlyphsTabView> createState() => _GlyphsTabViewState();
}

class _GlyphsTabViewState extends ConsumerState<_GlyphsTabView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(glyphsGeneratorProvider);
    final notifier = ref.read(glyphsGeneratorProvider.notifier);

    return SqaPluginScrollableContent(
      controller: _scrollController,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaSegmentedButton<GlyphsCategory>(
            hasChild: true,
            segments: const [
              ButtonSegment(
                value: GlyphsCategory.specials,
                label: Text('Specials'),
                icon: Icon(Symbols.font_download),
              ),
              ButtonSegment(
                value: GlyphsCategory.japanese,
                label: Text('JA'),
                icon: Icon(Symbols.language_japanese_kana),
              ),
              ButtonSegment(
                value: GlyphsCategory.chinese,
                label: Text('ZH'),
                icon: Icon(Symbols.language_chinese_dayi),
              ),
              ButtonSegment(
                value: GlyphsCategory.arabic,
                label: Text('AR'),
                icon: Icon(Symbols.language_pinyin),
              ),
              ButtonSegment(
                value: GlyphsCategory.vietnamese,
                label: Text('VI'),
                icon: Icon(Symbols.language_korean_latin),
              ),
            ],
            selected: {state.selectedCategory},
            onSelectionChanged: (set) => notifier.setCategory(set.first),
          ),
          SqaSegmentedButton<TextType>(
            isChild: true,
            segments: const [
              ButtonSegment(
                value: TextType.bytes,
                label: Text('Bytes'),
                icon: Icon(Symbols.abc),
              ),
              ButtonSegment(
                value: TextType.sentence,
                label: Text('Sentence'),
                icon: Icon(Symbols.short_text),
              ),
              ButtonSegment(
                value: TextType.paragraph,
                label: Text('Paragraph'),
                icon: Icon(Symbols.notes),
              ),
              ButtonSegment(
                value: TextType.chapter,
                label: Text('Chapter'),
                icon: Icon(Symbols.book),
              ),
            ],
            selected: {state.selectedType},
            onSelectionChanged: (set) => notifier.setType(set.first),
          ),
          const SizedBox(height: 24),
          const GlyphsConfigPanel(),
          if ((state.resultsMap[state.selectedCategory] ?? <String>[])
              .isNotEmpty) ...[
            const SizedBox(height: 24),
            SqaField(
              label: 'Result',
              initialValue:
                  (state.resultsMap[state.selectedCategory] ?? <String>[]).join(
                    '\n\n---\n\n',
                  ),
              icon: Symbols.content_copy,
              isMultiline: true,
              collapsedMaxLines: 10,
              isMonospace: state.selectedCategory == GlyphsCategory.specials,
            ),
          ],
        ],
      ),
    );
  }
}
