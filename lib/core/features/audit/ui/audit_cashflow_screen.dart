import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/audit/ui/audit_cashflow_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_divider.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Аудит записи денежного потока (7.3).
class AuditCashflowScreen extends StatefulWidget {
  const AuditCashflowScreen({super.key, required this.viewModel});

  final AuditCashflowViewModel viewModel;

  @override
  State<AuditCashflowScreen> createState() => _AuditCashflowScreenState();
}

class _AuditCashflowScreenState extends State<AuditCashflowScreen> {
  late AuditCashflowViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void didUpdateWidget(covariant AuditCashflowScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..load();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.cashflowAuditTitle,
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          if (vm.state.value is ViewError) {
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.load,
            );
          }
          if (vm.state.value is ViewLoading) {
            return Center(child: AppText(l10n.commonLoading));
          }
          return AppListView(
            children: [
              AppSection(
                header: l10n.cashflowAuditTitle,
                child: vm.revisions.value.isEmpty
                    ? AppText(l10n.revisionEmpty)
                    : Column(
                        children: [
                          for (
                            var i = 0;
                            i < vm.revisions.value.length;
                            i++
                          ) ...[
                            if (i > 0) const AppDivider(),
                            AppText(
                              '${l10n.revisionLabel(vm.revisions.value[i].revisionNo)} · '
                              '${_action(l10n, vm.revisions.value[i].action)}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            AppText(
                              '${const DateFormatter().format(LocalDate.fromDateTime(vm.revisions.value[i].changedAt.toLocal()))} · '
                              '${_money(vm.revisions.value[i].snapshot.amountRub)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _action(AppLocalizations l10n, RevisionAction action) =>
      switch (action) {
        RevisionAction.create => l10n.revisionActionCreate,
        RevisionAction.edit => l10n.revisionActionEdit,
        RevisionAction.delete => l10n.revisionActionDelete,
        RevisionAction.restore => l10n.revisionActionEdit,
      };

  static String _money(Money money) => const MoneyFormatter().format(
    money,
    const Currency(
      code: 'RUB',
      name: 'Рубль',
      fractionDigits: 2,
      isPreset: true,
      isEnabled: true,
    ),
  );
}
