import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/presentation/primary_empty_body.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Главная (dashboard): каркас до появления реальных итогов в 10.1.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.viewModel});

  final DashboardViewModel viewModel;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late DashboardViewModel _viewModel = widget.viewModel;

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel;
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navDashboard,
      body: SignalBuilder(
        builder: (context) => PrimaryEmptyBody(
          state: _viewModel.state.value,
          icon: Icons.dashboard_outlined,
          emptyTitle: l10n.dashboardEmptyTitle,
          emptyMessage: l10n.dashboardEmptyMessage,
        ),
      ),
    );
  }
}
