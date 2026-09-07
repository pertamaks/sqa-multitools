import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/models/sqa_plugin.dart';
import '../../core/models/sqa_coachmark_step.dart';
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

  @override
  List<SqaCoachmarkStep> get coachmarkSteps {
    return [
      SqaCoachmarkStep(
        targetKey: SwaggerListView.swaggerUrlKey,
        title: 'Discover APIs',
        description:
            'Paste a URL to an openapi.json file (or load a local file) to natively render and explore any OpenAPI specification without leaving the app.',
        contentAlign: CoachmarkContentAlign.bottom,
        beforeStepAction: (ref) async {
          ref.read(swaggerProvider.notifier).setViewMode(SwaggerViewMode.list);
        },
      ),
      SqaCoachmarkStep(
        targetKey: SwaggerDetailView.swaggerEndpointsKey,
        title: 'Bridge with cURL Requester',
        description:
            'Click the "Send to cURL" button on any endpoint to instantly transfer it to the cURL Requester. Path parameters, query strings, and schemas are pre-filled automatically.',
        contentAlign: CoachmarkContentAlign.left,
        beforeStepAction: (ref) async {
          // Switch view mode to detail to show the mock endpoint if there's an active schema.
          // Otherwise, we load a dummy schema just for the coachmark.
          final notifier = ref.read(swaggerProvider.notifier);
          final state = ref.read(swaggerProvider);
          if (state.activeSchema == null) {
            notifier.loadDummySchema();
          } else {
            notifier.setViewMode(SwaggerViewMode.detail);
          }
        },
      ),
    ];
  }
}
