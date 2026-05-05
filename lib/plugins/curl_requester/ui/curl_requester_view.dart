import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../ui/widgets/sqa_plugin_layout.dart';
import '../../../ui/widgets/sqa_field.dart';
import '../../../ui/widgets/sqa_button.dart';
import '../../../ui/widgets/sqa_styles.dart';
import '../../../ui/widgets/sqa_hover_icon_button.dart';
import '../../../ui/widgets/sqa_card.dart';
import '../../../ui/widgets/sqa_fade_wrapper.dart';
import '../../../ui/widgets/sqa_segmented_button.dart';
import '../../../ui/widgets/sqa_modal.dart';
import '../../../ui/widgets/sqa_status_badge.dart';
import '../../../ui/widgets/sqa_metadata_item.dart';
import 'components/curl_requester_grid_row.dart';


enum ModalTab { request, response }

class CurlRequesterView extends StatefulWidget {
  const CurlRequesterView({super.key});

  @override
  State<CurlRequesterView> createState() => _CurlRequesterViewState();
}

class _CurlRequesterViewState extends State<CurlRequesterView>
    with SingleTickerProviderStateMixin {
  // --- State ---
  late TabController _tabController;
  late TextEditingController _urlController;
  late TextEditingController _curlController;

  bool _isGridMode = false;
  bool _showReflector = false;

  ModalTab _modalTab = ModalTab.response;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _urlController = TextEditingController(
      text: 'https://api.example.com/v1/users',
    );
    _curlController = TextEditingController(
      text:
          'curl -X GET "https://api.example.com/v1/users" \\\n'
          '  -H "Accept: application/json" \\\n'
          '  -H "Authorization: Bearer {{token}}"',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    _curlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        return SqaPluginLayout(
          icon: Symbols.terminal,
          title: 'cURL Requester',
          description: 'Transform and execute cURL commands',
          tabController: _tabController,
          trailing: _tabController.index == 0
              ? SqaButton.primary(
                  label: '',
                  icon: Symbols.rocket_launch,
                  onPressed: () =>
                      _showResponseModal(context, isHistory: false),
                  tooltip: 'Execute Command',
                )
              : null,
          tabs: const [
            Tab(text: 'Request', icon: Icon(Symbols.send)),
            Tab(text: 'History', icon: Icon(Symbols.history)),
          ],
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SqaFadeWrapper(child: _buildRequestTab()),
              SqaFadeWrapper(child: _buildHistoryTab()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRequestTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRequestHeader(),
          const SizedBox(height: 24),
          _showReflector
              ? _buildUnifiedGridContent()
              : _buildCommandDeckContent(),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildRequestHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              _showReflector ? Symbols.magic_button : Symbols.terminal,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              _showReflector ? 'Structured Request' : 'Command Deck (cURL)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
        Row(
          children: [
            SqaHoverIconButton(
              icon: _showReflector ? Symbols.terminal : Symbols.magic_button,
              onPressed: () => setState(() {
                _showReflector = !_showReflector;
                if (_showReflector) _isGridMode = true;
              }),
              tooltip: _showReflector ? 'Switch to Command' : 'Show Grid',
              iconSize: 18,
            ),
            const SizedBox(width: 8),
            SqaHoverIconButton(
              icon: Symbols.content_paste,
              onPressed: () {},
              tooltip: 'Paste from Clipboard',
              iconSize: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommandDeckContent() {
    return SqaCard(
      padding: const EdgeInsets.all(16),
      child: SqaField(
        label: '',
        showLabel: false,
        controller: _curlController,
        isMonospace: true,
        isMultiline: true,
        minLines: 8,
        maxLines: 20,
        fontSize: 12,
        hintText: 'Paste curl command here...',
        showCopyButton: false,
      ),
    );
  }

  Widget _buildUnifiedGridContent() {
    return Column(
      children: [
        _buildParamsEditor(),
        const SizedBox(height: 32),
        _buildHeadersEditor(),
        const SizedBox(height: 32),
        _buildBodySection(),
      ],
    );
  }

  Widget _buildBodySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildJsonBodyHeader(),
        const SizedBox(height: 16),
        // In Structured View, we default to the Grid Editor for a consistent experience
        _isGridMode ? _buildGridEditor() : _buildRawEditor(),
      ],
    );
  }


  Widget _buildJsonBodyHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'JSON Body',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Row(
          children: [
            Text(
              _isGridMode ? 'Grid Mode' : 'Raw JSON',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            SqaHoverIconButton(
              icon: _isGridMode ? Symbols.edit_note : Symbols.magic_button,
              onPressed: () => setState(() => _isGridMode = !_isGridMode),
              tooltip: _isGridMode ? 'Switch to Raw' : 'Switch to Grid',
              color: _isGridMode ? Theme.of(context).colorScheme.primary : null,
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildParamsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Query Parameters',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        SqaCard(
          child: Column(
            children: [
              const CurlRequesterGridRow(label: 'page', value: '1'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const CurlRequesterGridRow(label: 'limit', value: '20'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const CurlRequesterGridRow(
                label: 'search',
                value: 'faker',
                hasFaker: true,
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildAddRowButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddRowButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SqaHoverIconButton(
        icon: Symbols.add,
        onPressed: () {},
        tooltip: 'Add new row',
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildHeadersEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Headers',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        SqaCard(
          child: Column(
            children: [
              const CurlRequesterGridRow(
                label: 'Content-Type',
                value: 'application/json',
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const CurlRequesterGridRow(
                label: 'Authorization',
                value: 'Bearer token_abc...',
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const CurlRequesterGridRow(label: 'Accept', value: '*/*'),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _buildAddRowButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRawEditor() {
    return const SqaField(
      label: 'Request Body',
      hintText: '{\n  "name": "John Doe",\n  "email": "john@example.com"\n}',
      showLabel: false,
      isMultiline: true,
      minLines: 4,
      maxLines: 16,
      isMonospace: true,
      showCopyButton: false,
    );
  }

  Widget _buildGridEditor() {
    return SqaCard(
      child: Column(
        children: [
          const CurlRequesterGridRow(
            label: 'name',
            value: 'John Doe',
            hasFaker: true,
            showCheckbox: false,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const CurlRequesterGridRow(
            label: 'user',
            value: '{...}',
            isParent: true,
            showCheckbox: false,
          ),
          const CurlRequesterGridRow(
            label: 'id',
            value: 'usr_9921',
            depth: 1,
            showCheckbox: false,
          ),
          const CurlRequesterGridRow(
            label: 'profile',
            value: '{...}',
            depth: 1,
            isParent: true,
            showCheckbox: false,
          ),
          const CurlRequesterGridRow(
            label: 'avatar',
            value: 'https://...',
            depth: 2,
            showCheckbox: false,
          ),
          const CurlRequesterGridRow(
            label: 'details',
            value: '{...}',
            depth: 2,
            isParent: true,
            showCheckbox: false,
          ),
          const CurlRequesterGridRow(
            label: 'bio',
            value: 'Software Engineer',
            depth: 3,
            hasFaker: true,
            showCheckbox: false,
          ),
          const CurlRequesterGridRow(
            label: 'location',
            value: 'NYC',
            depth: 3,
            showCheckbox: false,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const CurlRequesterGridRow(
            label: 'role',
            value: 'admin',
            showCheckbox: false,
          ),
        ],
      ),
    );
  }


  Widget _buildHistoryTab() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () => _showResponseModal(context, isHistory: true),
          borderRadius: SqaStyles.radiusLarge,
          child: SqaCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SqaStatusBadge(text: '200 OK', color: Colors.green),
                    const SizedBox(width: 12),
                    Text(
                      'POST /v1/users',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '2 mins ago',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'curl -X POST "https://api.example.com/v1/users" -H "Content-Type: application/json" -d \'{"name": "John Doe"}\'',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showResponseModal(
    BuildContext context, {
    bool isHistory = false,
  }) async {
    // Reset modal tab to response when opening
    setState(() => _modalTab = ModalTab.response);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SqaModal<bool>.custom(
              title: isHistory ? 'Transaction Inspector' : 'Response',
              leading: const SqaStatusBadge(
                text: '200 OK',
                color: Colors.green,
              ),
              confirmLabel: 'Done',
              cancelLabel: 'Send Again',
              topBar: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const SqaMetadataItem(
                            icon: Symbols.timer,
                            text: '1,245.82 ms',
                          ),
                          const SizedBox(width: 12),
                          const SqaMetadataItem(
                            icon: Symbols.database,
                            text: '1,242.08 MB',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isHistory) ...[
                    const SizedBox(width: 16),
                    SqaSegmentedButton<ModalTab>(
                      stretches: false,
                      minScale: 0.8,
                      segments: const [
                        ButtonSegment(
                          value: ModalTab.request,
                          label: Text('REQ'),
                          icon: Icon(Symbols.send),
                        ),
                        ButtonSegment(
                          value: ModalTab.response,
                          label: Text('RES'),
                          icon: Icon(Symbols.data_object),
                        ),
                      ],
                      selected: {_modalTab},
                      onSelectionChanged: (v) {
                        setModalState(() => _modalTab = v.first);
                        setState(() => _modalTab = v.first);
                      },
                    ),
                  ],
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  minWidth: MediaQuery.of(context).size.width * 0.85 > 800
                      ? 800
                      : MediaQuery.of(context).size.width * 0.85,
                  maxWidth: 800,
                ),
                child: _modalTab == ModalTab.request
                    ? _buildRequestModalContent()
                    : _buildResponseContent(),
              ),
            );
          },
        );
      },
    );

    // If "Send Again" (Cancel button) was pressed, re-trigger the modal
    if (result == false) {
      if (context.mounted) {
        _showResponseModal(context);
      }
    }
  }

  Widget _buildRequestModalContent() {
    return const SqaField(
      label: 'cURL Command',
      showLabel: false,
      isMonospace: true,
      readOnly: true,
      isMultiline: true,
      maxLines: 40,
      fontSize: 12,
      showCopyButton: true,
      initialValue:
          'curl -X POST "https://api.example.com/v1/users" \\\n  -H "Accept: application/json" \\\n  -H "Content-Type: application/json" \\\n  -d \'{"name": "John Doe", "email": "john@example.com"}\'',
    );
  }

  Widget _buildResponseContent() {
    return const SqaField(
      label: 'Response Output',
      showLabel: false,
      isMonospace: true,
      readOnly: true,
      isMultiline: true,
      maxLines: 40,
      fontSize: 12,
      showCopyButton: true,
      initialValue:
          '{\n  "status": "success",\n  "data": {\n    "id": 101,\n    "title": "foo",\n    "body": "bar",\n    "userId": 1\n  }\n}',
    );
  }

}
