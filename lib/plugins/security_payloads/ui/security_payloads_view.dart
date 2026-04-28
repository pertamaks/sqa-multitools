import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/security_payloads_provider.dart';
import './tabs/web_tab_view.dart';
import './tabs/system_tab_view.dart';
import './widgets/security_disclaimer.dart';
import '../../../../ui/widgets/sqa_plugin_layout.dart';

class SecurityPayloadsView extends ConsumerStatefulWidget {
  const SecurityPayloadsView({super.key});

  @override
  ConsumerState<SecurityPayloadsView> createState() =>
      _SecurityPayloadsViewState();
}

class _SecurityPayloadsViewState extends ConsumerState<SecurityPayloadsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showDisclaimer = ref.watch(
      securityPayloadsProvider.select((s) => s.showDisclaimer),
    );

    return Stack(
      children: [
        SqaPluginLayout(
          icon: Symbols.security,
          title: 'Security Payloads',
          description: 'Educational lab for fuzzing and vulnerability testing.',
          tabs: const [
            Tab(text: 'Web', icon: Icon(Symbols.web)),
            Tab(text: 'System', icon: Icon(Symbols.computer)),
          ],
          tabController: _tabController,
          child: TabBarView(
            controller: _tabController,
            children: const [WebTabView(), SystemTabView()],
          ),
        ),
        if (showDisclaimer) const SecurityDisclaimer(),
      ],
    );
  }
}
