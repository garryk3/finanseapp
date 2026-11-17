import 'package:finanseapp/core/presentation/primary_empty_body.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Цели: каркас до 8.1.
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key, required this.viewModel});

  final GoalsViewModel viewModel;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  late GoalsViewModel _viewModel = widget.viewModel;

  @override
  void didUpdateWidget(covariant GoalsScreen oldWidget) {
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
      title: l10n.navGoals,
      body: SignalBuilder(
        builder: (context) => PrimaryEmptyBody(
          state: _viewModel.state.value,
          icon: Icons.flag_outlined,
          emptyTitle: l10n.goalsEmptyTitle,
          emptyMessage: l10n.goalsEmptyMessage,
        ),
      ),
    );
  }
}
