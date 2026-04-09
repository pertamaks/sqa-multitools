import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_plugin_layout.dart';
import '../../ui/widgets/sqa_field.dart';
import '../../ui/widgets/sqa_card.dart';
import '../../ui/widgets/sqa_plugin_scrollable_content.dart';
import '../../ui/widgets/sqa_button.dart';

class SecurityPayloadsPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.security_payloads';
  @override
  String get name => 'Security Payloads';
  @override
  String get description => 'Common security testing & fuzzing payloads.';
  @override
  IconData get icon => Symbols.security;

  @override
  String? get badge => 'ALPHA';

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const _SecurityPayloadsView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const Center(child: Text('Security Payloads Settings'));
  }

  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _SecurityPayloadsView extends ConsumerStatefulWidget {
  const _SecurityPayloadsView();

  @override
  ConsumerState<_SecurityPayloadsView> createState() =>
      _SecurityPayloadsViewState();
}

class _SecurityPayloadsViewState extends ConsumerState<_SecurityPayloadsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SqaPluginLayout(
      icon: Symbols.security,
      title: 'Security Payloads',
      description: 'Fuzzing and testing payloads for common vulnerabilities.',
      tabs: const [
        Tab(text: 'Web'),
        Tab(text: 'System'),
        Tab(text: 'Utils'),
      ],
      tabController: _tabController,
      child: TabBarView(
        controller: _tabController,
        children: [_buildWebTab(), _buildSystemTab(), _buildUtilsTab()],
      ),
    );
  }

  Widget _buildWebTab() {
    return SqaPluginScrollableContent(
      child: Column(
        children: [
          _buildSection('SQL Injection', [
            '\' OR 1=1 --',
            'admin\' --',
            '\' UNION SELECT NULL, NULL --',
          ]),
          const SizedBox(height: 16),
          _buildSection('XSS (Cross-Site Scripting)', [
            '<script>alert(1)</script>',
            '<img src=x onerror=alert(1)>',
            'javascript:alert(1)',
          ]),
          const SizedBox(height: 16),
          _buildSection('Path Traversal', [
            '../../../../etc/passwd',
            '..\\..\\..\\..\\windows\\win.ini',
            '%2e%2e%2f%2e%2e%2f%65%74%63%2f%70%61%73%73%77%64',
          ]),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return SqaPluginScrollableContent(
      child: Column(
        children: [
          _buildSection('Command Injection', [
            '; ls -la',
            '| id',
            '&& cat /etc/shadow',
            '|| whoami',
          ]),
          const SizedBox(height: 16),
          _buildSection('Header/CRLF Injection', [
            'Admin: true\\r\\n',
            'Set-Cookie: session=evil\\r\\n',
            'X-Forwarded-For: 127.0.0.1',
          ]),
        ],
      ),
    );
  }

  Widget _buildUtilsTab() {
    return const _Base64Tool();
  }

  Widget _buildSection(String title, List<String> payloads) {
    return SqaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...payloads.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SqaField(label: '', initialValue: p, readOnly: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _Base64Tool extends StatefulWidget {
  const _Base64Tool();

  @override
  State<_Base64Tool> createState() => _Base64ToolState();
}

class _Base64ToolState extends State<_Base64Tool> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  void _encode() {
    try {
      final bytes = utf8.encode(_inputController.text);
      setState(() {
        _outputController.text = base64.encode(bytes);
      });
    } catch (e) {
      _outputController.text = 'Error encoding data';
    }
  }

  void _decode() {
    try {
      final decoded = utf8.decode(base64.decode(_inputController.text));
      setState(() {
        _outputController.text = decoded;
      });
    } catch (e) {
      _outputController.text = 'Invalid Base64 string';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SqaPluginScrollableContent(
      child: Column(
        children: [
          SqaCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SqaField(
                  label: 'Input',
                  controller: _inputController,
                  isMultiline: true,
                  minLines: 3,
                  hintText: 'Enter text or Base64...',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SqaButton(label: 'Encode', onPressed: _encode),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SqaButton(label: 'Decode', onPressed: _decode),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SqaField(
                  label: 'Result',
                  controller: _outputController,
                  isMultiline: true,
                  minLines: 3,
                  readOnly: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
