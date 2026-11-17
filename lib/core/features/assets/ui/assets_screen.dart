import 'package:finanseapp/core/presentation/primary_empty_body.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Активы: каркас до 5.1 (watchAll + фильтры + add menu).
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key, required this.viewModel});

  final AssetsViewModel viewModel;

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  late AssetsViewModel _viewModel = widget.viewModel;

  @override
  void didUpdateWidget(covariant AssetsScreen oldWidget) {
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
      title: l10n.navAssets,
      body: SignalBuilder(
        builder: (context) => PrimaryEmptyBody(
          state: _viewModel.state.value,
          icon: Icons.account_balance_wallet_outlined,
          emptyTitle: l10n.assetsEmptyTitle,
          emptyMessage: l10n.assetsEmptyMessage,
        ),
      ),
    );
  }
}
