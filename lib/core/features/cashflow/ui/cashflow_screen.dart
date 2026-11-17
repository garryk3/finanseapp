import 'package:finanseapp/core/presentation/primary_empty_body.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/cashflow/ui/operations_tabs.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Денежный поток (вкладка `/operations`); watch подключается в 7.1.
class CashflowScreen extends StatefulWidget {
  const CashflowScreen({
    super.key,
    required this.viewModel,
    required this.onTabChanged,
  });

  final CashflowViewModel viewModel;
  final ValueChanged<String> onTabChanged;

  @override
  State<CashflowScreen> createState() => _CashflowScreenState();
}

class _CashflowScreenState extends State<CashflowScreen> {
  late CashflowViewModel _viewModel = widget.viewModel;

  @override
  void didUpdateWidget(covariant CashflowScreen oldWidget) {
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
      title: l10n.navOperations,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding(
                MediaQuery.sizeOf(context).width,
              ),
              vertical: AppSpacing.sm,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.formMaxWidth,
                ),
                child: OperationsTabs(
                  current: 'cashflow',
                  onChanged: widget.onTabChanged,
                ),
              ),
            ),
          ),
          Expanded(
            child: SignalBuilder(
              builder: (context) => PrimaryEmptyBody(
                state: _viewModel.state.value,
                icon: Icons.receipt_long_outlined,
                emptyTitle: l10n.cashflowEmptyTitle,
                emptyMessage: l10n.cashflowEmptyMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
