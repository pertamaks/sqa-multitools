import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import '../../ui/widgets/sqa_faker_locale_picker.dart';
import '../../ui/widgets/sqa_design_tokens.dart';
import 'ui/curl_requester_view.dart';

class CurlRequesterPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.curl_requester';

  @override
  String get name => 'cURL Requester';

  @override
  @override
  String get description => 'Quickly test and transform cURL commands.';

  @override
  IconData get icon => Symbols.terminal;

  @override
  String? get badge => null;

  @override
  Widget buildPluginWindow(BuildContext context) {
    return const CurlRequesterView();
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(SqaTokens.spacingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SqaFakerLocalePicker(),
        ],
      ),
    );
  }

  @override
  Future<void> initialize() async {
    // Pre-load assets if needed
  }

  @override
  Future<void> dispose() async {
    // Clean up
  }

  @override
  List<PermissionRequirement> get requiredPermissions => [];
}
