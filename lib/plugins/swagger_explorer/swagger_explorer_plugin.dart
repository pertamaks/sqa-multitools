import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import 'ui/swagger_list_view.dart';
import 'ui/swagger_detail_view.dart';
import 'providers/swagger_provider.dart';
import 'models/swagger_state.dart';

class SwaggerExplorerPlugin implements SqaPlugin {
  @override
  String get id => 'com.sqa.plugin.swagger_explorer';

  @override
  String get name => 'Swagger Explorer';

  @override
  String get description =>
      'Natively parse and discover OpenAPI schemas to bridge with cURL Requester.';

  @override
  IconData get icon => Symbols.data_object;

  @override
  String? get badge => null;

  @override
  List<PermissionRequirement> get requiredPermissions => [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}

  @override
  Widget buildPluginWindow(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final state = ref.watch(swaggerProvider);
        if (state.viewMode == SwaggerViewMode.detail) {
          return const SwaggerDetailView();
        }
        return const SwaggerListView();
      },
    );
  }

  @override
  Widget buildSettingsPanel(BuildContext context) {
    return const SizedBox.shrink();
  }
}
