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
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_operation_list_tile.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_search_field.dart';
import 'package:finanseapp/uikit/app_select.dart';
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
  final _search = TextEditingController();
  bool _advanced = false;

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
      _search.clear();
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _search.clear();
    FocusScope.of(context).unfocus();
    _viewModel.resetFilters();
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
          SignalBuilder(
            builder: (context) {
              final vm = _viewModel;
              final state = vm.state.value;
              if (state is! ViewData<List<CashflowEntry>> ||
                  (state.value.isEmpty && !vm.filtersActive)) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppSearchField(
                      controller: _search,
                      label: l10n.cashflowSearchLabel,
                      hint: l10n.cashflowSearchHint,
                      onChanged: vm.setQuery,
                      onClear: () => vm.setQuery(''),
                      clearTooltip: l10n.cashflowSearchClear,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppFilterBar(
                      activeCount:
                          (vm.query.value.trim().isEmpty ? 0 : 1) +
                          (vm.kind.value == null ? 0 : 1) +
                          (vm.period.value == CashflowJournalPeriod.all
                              ? 0
                              : 1),
                      onReset: vm.filtersActive ? _resetFilters : null,
                      resetLabel: l10n.cashflowResetFilters,
                      children: [
                        AppFilterChip(
                          label: l10n.cashflowFilterAll,
                          selected: vm.kind.value == null,
                          onSelected: (_) => vm.setKind(null),
                        ),
                        AppFilterChip(
                          label: l10n.cashflowIncome,
                          selected: vm.kind.value == CashflowKind.income,
                          onSelected: (_) => vm.setKind(CashflowKind.income),
                        ),
                        AppFilterChip(
                          label: l10n.cashflowExpense,
                          selected: vm.kind.value == CashflowKind.expense,
                          onSelected: (_) => vm.setKind(CashflowKind.expense),
                        ),
                        AppFilterChip(
                          label: l10n.cashflowPeriodMonth,
                          selected:
                              vm.period.value == CashflowJournalPeriod.month,
                          onSelected: (_) =>
                              vm.setPeriod(CashflowJournalPeriod.month),
                        ),
                        AppFilterChip(
                          label: l10n.cashflowPeriodYear,
                          selected:
                              vm.period.value == CashflowJournalPeriod.year,
                          onSelected: (_) =>
                              vm.setPeriod(CashflowJournalPeriod.year),
                        ),
                        AppFilterChip(
                          label: l10n.cashflowPeriodAll,
                          selected:
                              vm.period.value == CashflowJournalPeriod.all,
                          onSelected: (_) =>
                              vm.setPeriod(CashflowJournalPeriod.all),
                        ),
                      ],
                    ),
                    AppButton(
                      label: _advanced
                          ? l10n.cashflowFiltersHide
                          : l10n.cashflowFilters,
                      variant: AppButtonVariant.text,
                      onPressed: () => setState(() => _advanced = !_advanced),
                    ),
                    if (_advanced) ...[
                      AppSelect<int>(
                        label: l10n.cashflowCategoryLabel,
                        value: vm.categoryId.value,
                        hint: l10n.cashflowAllCategories,
                        items: [
                          for (final category in vm.categories.value)
                            AppSelectItem(
                              value: category.id,
                              label: category.name,
                            ),
                        ],
                        onChanged: (value) => vm.setCategory(value),
                      ),
                      AppSelect<int>(
                        label: l10n.cashflowAccountLabel,
                        value: vm.accountId.value,
                        hint: l10n.cashflowAllAccounts,
                        items: [
                          for (final account in vm.accounts.value)
                            AppSelectItem(
                              value: account.id,
                              label: account.name,
                              subtitle: account.currencyCode,
                            ),
                        ],
                        onChanged: (value) => vm.setAccount(value),
                      ),
                      AppSelect<String>(
                        label: l10n.cashflowCurrencyLabel,
                        value: vm.currencyCode.value,
                        hint: l10n.cashflowAllCurrencies,
                        items: [
                          for (final code in vm.currencies.value.keys)
                            AppSelectItem(value: code, label: code),
                        ],
                        onChanged: (value) => vm.setCurrency(value),
                      ),
                    ],
                  ],
                ),
              );
            },
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
