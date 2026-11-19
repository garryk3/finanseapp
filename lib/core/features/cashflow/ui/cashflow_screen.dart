import 'dart:async';

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_calculator.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/cashflow/ui/operations_tabs.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_date_header.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_operation_list_tile.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:finanseapp/uikit/app_cashflow_summary.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Журнал доходов и расходов (7.1).
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
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant CashflowScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final saved = await context.push<bool>(AppRoutes.cashflowNew);
    if (!mounted || saved != true) return;
    _viewModel.reload();
  }

  Future<void> _open(int id) async {
    await context.push(AppRoutes.cashflowDetailsPath(id));
    if (!mounted) return;
    _viewModel.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navOperations,
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        tooltip: l10n.cashflowAdd,
        onPressed: _add,
      ),
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
              builder: (context) {
                final vm = _viewModel;
                return switch (vm.state.value) {
                  ViewLoading() => Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        for (var i = 0; i < 4; i++) ...[
                          const AppSkeleton(width: double.infinity, height: 56),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ],
                    ),
                  ),
                  ViewError() => AppErrorState(
                    title: l10n.errorStateTitle,
                    message: l10n.errorStateMessage,
                    errorLabel: l10n.errorLabel,
                    retryLabel: l10n.retry,
                    onRetry: vm.init,
                  ),
                  ViewData(:final value) =>
                    value.isEmpty
                        ? AppListView(
                            children: [
                              AppEmptyState(
                                icon: Icons.receipt_long_outlined,
                                title: l10n.cashflowEmptyTitle,
                                message: l10n.cashflowEmptyMessage,
                                actionLabel: l10n.cashflowAdd,
                                onAction: _add,
                              ),
                            ],
                          )
                        : _journal(context, l10n, vm, value),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _journal(
    BuildContext context,
    AppLocalizations l10n,
    CashflowViewModel vm,
    List<CashflowEntry> entries,
  ) {
    final totals = CashflowCalculator.totals(entries);
    final items = <Object>[];
    LocalDate? lastDate;
    for (final entry in entries) {
      if (lastDate != entry.occurredOn) {
        items.add(entry.occurredOn);
        lastDate = entry.occurredOn;
      }
      items.add(entry);
    }
    return AppListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppCashflowSummary(
              incomeText: _rub(totals.income),
              expenseText: _rub(totals.expense),
              netText: _rub(totals.net),
              periodLabel: l10n.cashflowPeriodAll,
              incomeLabel: l10n.cashflowTotalsIncome,
              expenseLabel: l10n.cashflowTotalsExpense,
              netLabel: l10n.cashflowTotalsNet,
            ),
          );
        }
        final item = items[index - 1];
        if (item is LocalDate) {
          return AppDateHeader(const DateFormatter().format(item));
        }
        final entry = item as CashflowEntry;
        final income = entry.kind == CashflowKind.income;
        return AppOperationListTile(
          key: ValueKey(entry.id),
          title: vm.categoryName(entry.categoryId),
          typeLabel: income ? l10n.cashflowIncome : l10n.cashflowExpense,
          icon: income ? Icons.south_west : Icons.north_east,
          amountText: '${income ? '+' : '−'}${vm.formatAmount(entry)}',
          dateText: '',
          tone: income ? AppMoneyTone.income : AppMoneyTone.expense,
          comment: entry.comment,
          onTap: () => _open(entry.id),
        );
      },
    );
  }

  static String _rub(Money money) => const MoneyFormatter().format(
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
