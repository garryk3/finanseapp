import 'package:finanseapp/core/presentation/primary_empty_body.dart';
import 'package:finanseapp/core/features/cashflow/ui/operations_tabs.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Операции по активам (вкладка `/operations`); watch подключается в 6.1.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({
    super.key,
    required this.viewModel,
    required this.onTabChanged,
  });

  final TransactionsViewModel viewModel;
  final ValueChanged<String> onTabChanged;

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  late TransactionsViewModel _viewModel = widget.viewModel;

  @override
  void didUpdateWidget(covariant TransactionsScreen oldWidget) {
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
                  current: 'transactions',
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
                emptyTitle: l10n.transactionsEmptyTitle,
                emptyMessage: l10n.transactionsEmptyMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
