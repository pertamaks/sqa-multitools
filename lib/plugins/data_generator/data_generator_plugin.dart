import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'ui/identity_tab_view.dart';
import 'ui/lorem_tab_view.dart';
import 'ui/glyphs_tab_view.dart';
import 'ui/dev_tab_view.dart';
import 'ui/settings_panel.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_button.dart';
import '../../ui/widgets/sqa_hover_icon_button.dart';
import '../../ui/widgets/sqa_segmented_button.dart';
import '../../ui/widgets/sqa_modal.dart';
import '../../ui/widgets/sqa_field.dart';
import '../../ui/widgets/sqa_toast.dart';
import '../../core/providers/plugin_provider.dart';
import 'providers/identity_provider.dart';
import 'providers/text_provider.dart';
import 'providers/glyphs_provider.dart';
import 'providers/dev_provider.dart';
import 'models/identity_state.dart';
import 'models/text_state.dart';
import 'models/glyphs_state.dart';
import 'models/dev_state.dart';
import 'package:flutter/services.dart';
import '../../core/utils/locale_names.dart';

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
    return const DataGeneratorSettingsPanel();
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _DataGeneratorView extends ConsumerStatefulWidget {
  const _DataGeneratorView();

  @override
  ConsumerState<_DataGeneratorView> createState() => _DataGeneratorViewState();
}

class _DataGeneratorViewState extends ConsumerState<_DataGeneratorView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleGenerate() {
    switch (_tabController.index) {
      case 0:
        ref.read(identityProvider.notifier).generate();
        break;
      case 1:
        ref.read(textGeneratorProvider.notifier).generate();
        break;
      case 2:
        ref.read(glyphsGeneratorProvider.notifier).generate();
        break;
      case 3:
        ref.read(devGeneratorProvider.notifier).generate();
        break;
    }
  }

  void _showResultModal(String title, String result, IconData icon) {
    showDialog<void>(
      context: context,
      builder: (context) => SqaModal<void>.custom(
        title: title,
        scrollable: false,
        confirmLabel: 'Close',
        customActions: [
          SqaButton.tonal(
            label: 'Copy',
            icon: Symbols.content_copy,
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result));
              SqaToast.show(context, 'Copied to clipboard', type: SqaToastType.success);
            },
          ),
          const SizedBox(width: 8),
          SqaButton.primary(
            label: 'Close',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        child: SqaField(
          label: 'Generated Data',
          showLabel: false,
          isMonospace: true,
          readOnly: true,
          isMultiline: true,
          maxLines: null,
          expands: true,
          fontSize: 12,
          showLineNumbers: true,
          showCopyButton: false,
          initialValue: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final identityState = ref.watch(identityProvider);
    final devState = ref.watch(devGeneratorProvider);
    
    // Listen for results to show modal
    ref.listen(identityProvider, (previous, next) {
      if (_tabController.index == 0) {
        final history = next.resultsMap[next.selectedType] ?? [];
        if (history.isNotEmpty && history.first != (previous?.resultsMap[next.selectedType]?.firstOrNull)) {
          final latest = history.first;
          final text = next.includeFormatting ? latest.map((e) => '• $e').join('\n') : latest.join('\n');
          _showResultModal('Identity Data', text, Symbols.person);
        }
      }
    });

    ref.listen(textGeneratorProvider, (previous, next) {
      if (_tabController.index == 1) {
        final history = next.resultsMap[next.selectedType] ?? [];
        if (history.isNotEmpty && history.first != (previous?.resultsMap[next.selectedType]?.firstOrNull)) {
          final latest = history.first;
          _showResultModal('Lorem Ipsum', latest.join('\n'), Symbols.notes);
        }
      }
    });

    ref.listen(glyphsGeneratorProvider, (previous, next) {
      if (_tabController.index == 2) {
        final history = next.resultsMap[next.selectedCategory] ?? [];
        if (history.isNotEmpty && history.first != (previous?.resultsMap[next.selectedCategory]?.firstOrNull)) {
          final latest = history.first;
          _showResultModal('Glyphs & Symbols', latest.join('\n'), Symbols.glyphs);
        }
      }
    });

    ref.listen(devGeneratorProvider, (previous, next) {
      if (_tabController.index == 3) {
        final history = next.resultsMap[next.selectedType] ?? [];
        if (history.isNotEmpty && history.first != (previous?.resultsMap[next.selectedType]?.firstOrNull)) {
          final latest = history.first;
          String text = '';
          if (next.selectedType == DevType.date && latest.length == 5) {
            final labels = ['ISO 8601', 'RFC 2822', 'SQL DATETIME', 'UNIX TIMESTAMP', 'HUMAN READABLE'];
            text = List.generate(5, (i) => '${labels[i]}:\n${latest[i]}').join('\n\n');
          } else {
            text = next.includeFormatting 
                ? latest.map((e) => '• $e').join('\n') 
                : latest.join('\n');
          }
          _showResultModal('Developer Data', text, Symbols.terminal);
        }
      }
    });

    return SqaPluginLayout(
      icon: Symbols.wand_stars,
      title: 'Data Generator',
      description: 'Generate mock UUIDs, emails, numbers, and more.',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SqaHoverIconButton(
            icon: Symbols.tune,
            onPressed: () {
              ref.read(navigationServiceProvider).jumpToPluginSettings('com.sqa.data_generator');
            },
            tooltip: (_tabController.index == 0 || (_tabController.index == 3 && devState.selectedType == DevType.uuid))
                ? '${LocaleNames.getDisplayName(identityState.locale.name)}, ${identityState.quantity} items'
                : LocaleNames.getDisplayName(identityState.locale.name),
          ),
          const SizedBox(width: 8),
          SqaButton.primary(
            icon: Symbols.wand_stars,
            label: '',
            onPressed: _handleGenerate,
          ),
        ],
      ),
      secondaryHeader: _buildSecondaryHeader(),
      tabs: const [
        Tab(icon: Icon(Symbols.person), text: 'Identity'),
        Tab(icon: Icon(Symbols.notes), text: 'Lorem'),
        Tab(icon: Icon(Symbols.glyphs), text: 'Glyphs'),
        Tab(icon: Icon(Symbols.terminal), text: 'Dev'),
      ],
      tabController: _tabController,
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          IdentityTabView(),
          LoremTabView(),
          GlyphsTabView(),
          DevTabView(),
        ],
      ),
    );
  }

  Widget _buildSecondaryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Center(
        child: _buildActiveSegmentedButton(),
      ),
    );
  }

  Widget _buildActiveSegmentedButton() {
    switch (_tabController.index) {
      case 0:
        final state = ref.watch(identityProvider);
        return SqaSegmentedButton<IdentityType>(
          segments: const [
            ButtonSegment(value: IdentityType.name, label: Text('Name'), icon: Icon(Symbols.person)),
            ButtonSegment(value: IdentityType.email, label: Text('Email'), icon: Icon(Symbols.mail)),
            ButtonSegment(value: IdentityType.address, label: Text('Address'), icon: Icon(Symbols.home)),
            ButtonSegment(value: IdentityType.phone, label: Text('Phone'), icon: Icon(Symbols.call)),
            ButtonSegment(value: IdentityType.internet, label: Text('Net'), icon: Icon(Symbols.language)),
            ButtonSegment(value: IdentityType.company, label: Text('Work'), icon: Icon(Symbols.business)),
          ],
          selected: {state.selectedType},
          onSelectionChanged: (set) => ref.read(identityProvider.notifier).setType(set.first),
        );
      case 1:
        final state = ref.watch(textGeneratorProvider);
        return SqaSegmentedButton<TextType>(
          segments: const [
            ButtonSegment(value: TextType.bytes, label: Text('Bytes'), icon: Icon(Symbols.abc)),
            ButtonSegment(value: TextType.sentence, label: Text('Sentence'), icon: Icon(Symbols.short_text)),
            ButtonSegment(value: TextType.paragraph, label: Text('Paragraph'), icon: Icon(Symbols.notes)),
            ButtonSegment(value: TextType.chapter, label: Text('Chapter'), icon: Icon(Symbols.book)),
          ],
          selected: {state.selectedType},
          onSelectionChanged: (set) => ref.read(textGeneratorProvider.notifier).setType(set.first),
        );
      case 2:
        final state = ref.watch(glyphsGeneratorProvider);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SqaSegmentedButton<GlyphsCategory>(
              hasChild: true,
              segments: const [
                ButtonSegment(value: GlyphsCategory.specials, label: Text('Specials'), icon: Icon(Symbols.font_download)),
                ButtonSegment(value: GlyphsCategory.japanese, label: Text('JA'), icon: Icon(Symbols.language_japanese_kana)),
                ButtonSegment(value: GlyphsCategory.chinese, label: Text('ZH'), icon: Icon(Symbols.language_chinese_dayi)),
                ButtonSegment(value: GlyphsCategory.arabic, label: Text('AR'), icon: Icon(Symbols.language_pinyin)),
                ButtonSegment(value: GlyphsCategory.vietnamese, label: Text('VI'), icon: Icon(Symbols.language_korean_latin)),
              ],
              selected: {state.selectedCategory},
              onSelectionChanged: (set) => ref.read(glyphsGeneratorProvider.notifier).setCategory(set.first),
            ),
            SqaSegmentedButton<TextType>(
              isChild: true,
              segments: const [
                ButtonSegment(value: TextType.bytes, label: Text('Bytes'), icon: Icon(Symbols.abc)),
                ButtonSegment(value: TextType.sentence, label: Text('Sentence'), icon: Icon(Symbols.short_text)),
                ButtonSegment(value: TextType.paragraph, label: Text('Paragraph'), icon: Icon(Symbols.notes)),
                ButtonSegment(value: TextType.chapter, label: Text('Chapter'), icon: Icon(Symbols.book)),
              ],
              selected: {state.selectedType},
              onSelectionChanged: (set) => ref.read(glyphsGeneratorProvider.notifier).setType(set.first),
            ),
          ],
        );
      case 3:
        final state = ref.watch(devGeneratorProvider);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SqaSegmentedButton<DevType>(
              stretches: false,
              hasChild: state.selectedType == DevType.json || state.selectedType == DevType.date,
              segments: const [
                ButtonSegment(value: DevType.uuid, label: Text('UUID'), icon: Icon(Symbols.fingerprint)),
                ButtonSegment(value: DevType.json, label: Text('JSON'), icon: Icon(Symbols.code)),
                ButtonSegment(value: DevType.date, label: Text('Date'), icon: Icon(Symbols.calendar_today)),
              ],
              selected: {state.selectedType},
              onSelectionChanged: (set) => ref.read(devGeneratorProvider.notifier).setType(set.first),
            ),
            if (state.selectedType == DevType.json)
              SqaSegmentedButton<JsonCategory>(
                stretches: false,
                isChild: true,
                segments: const [
                  ButtonSegment(value: JsonCategory.simple, label: Text('Simple'), icon: Icon(Symbols.token)),
                  ButtonSegment(value: JsonCategory.medium, label: Text('Medium'), icon: Icon(Symbols.data_object)),
                  ButtonSegment(value: JsonCategory.complex, label: Text('Complex'), icon: Icon(Symbols.account_tree)),
                ],
                selected: {state.selectedJsonCategory},
                onSelectionChanged: (set) => ref.read(devGeneratorProvider.notifier).setJsonCategory(set.first),
              )
            else if (state.selectedType == DevType.date)
              SqaSegmentedButton<DateCategory>(
                stretches: false,
                isChild: true,
                segments: const [
                  ButtonSegment(value: DateCategory.past, label: Text('Past'), icon: Icon(Symbols.history)),
                  ButtonSegment(value: DateCategory.future, label: Text('Future'), icon: Icon(Symbols.update)),
                ],
                selected: {state.selectedDateCategory},
                onSelectionChanged: (set) => ref.read(devGeneratorProvider.notifier).setDateCategory(set.first),
              ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
