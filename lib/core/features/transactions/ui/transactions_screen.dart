import 'dart:async';

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/cashflow/ui/operations_tabs.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_date_header.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_operation_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_search_field.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Журнал операций по активам: фильтры, группы по дате, детали (6.3).
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
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant TransactionsScreen oldWidget) {
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
    final saved = await context.push<bool>(AppRoutes.transactionNew);
    if (!mounted || saved != true) return;
    _viewModel.reload();
  }

  Future<void> _open(int id) async {
    await context.push(AppRoutes.transactionDetailsPath(id));
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
        tooltip: l10n.transactionsAdd,
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
                  current: 'transactions',
                  onChanged: widget.onTabChanged,
                ),
              ),
            ),
          ),
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final vm = _viewModel;
                final state = vm.state.value;
                final hasRows =
                    state is ViewData<List<AssetTransaction>> &&
                    state.value.isNotEmpty;
                final showFilters = hasRows || vm.filtersActive;
                return Column(
                  children: [
                    if (showFilters)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AppSearchField(
                              controller: _search,
                              label: l10n.transactionsSearchLabel,
                              hint: l10n.transactionsSearchHint,
                              onChanged: vm.setQuery,
                              onClear: () => vm.setQuery(''),
                              clearTooltip: l10n.transactionsSearchClear,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            AppFilterBar(
                              activeCount:
                                  (vm.query.value.trim().isEmpty ? 0 : 1) +
                                  (vm.kind.value == null ? 0 : 1) +
                                  (vm.monthOnly.value ? 1 : 0),
                              onReset: vm.filtersActive && hasRows
                                  ? _resetFilters
                                  : null,
                              resetLabel: l10n.transactionsResetFilters,
                              children: [
                                AppFilterChip(
                                  label: l10n.transactionsFilterAll,
                                  selected: vm.kind.value == null,
                                  onSelected: (_) => vm.setKind(null),
                                ),
                                AppFilterChip(
                                  label: l10n.transactionsFilterDeposit,
                                  selected:
                                      vm.kind.value ==
                                      AssetTransactionKind.deposit,
                                  onSelected: (_) =>
                                      vm.setKind(AssetTransactionKind.deposit),
                                ),
                                AppFilterChip(
                                  label: l10n.transactionsFilterWithdrawal,
                                  selected:
                                      vm.kind.value ==
                                      AssetTransactionKind.withdrawal,
                                  onSelected: (_) => vm.setKind(
                                    AssetTransactionKind.withdrawal,
                                  ),
                                ),
                                AppFilterChip(
                                  label: l10n.transactionsFilterTransferOut,
                                  selected:
                                      vm.kind.value ==
                                      AssetTransactionKind.transferOut,
                                  onSelected: (_) => vm.setKind(
                                    AssetTransactionKind.transferOut,
                                  ),
                                ),
                                AppFilterChip(
                                  label: l10n.transactionsFilterTransferIn,
                                  selected:
                                      vm.kind.value ==
                                      AssetTransactionKind.transferIn,
                                  onSelected: (_) => vm.setKind(
                                    AssetTransactionKind.transferIn,
                                  ),
                                ),
                                AppFilterChip(
                                  label: l10n.transactionsFilterMonth,
                                  selected: vm.monthOnly.value,
                                  icon: Icons.calendar_month_outlined,
                                  onSelected: vm.setMonthOnly,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: switch (state) {
                        ViewLoading() => Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              for (var i = 0; i < 4; i++) ...[
                                const AppSkeleton(
                                  width: double.infinity,
                                  height: 56,
                                ),
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
                              ? (vm.filtersActive
                                    ? AppEmptyState(
                                        icon: Icons.search_off,
                                        title:
                                            l10n.transactionsFilteredEmptyTitle,
                                        message: l10n
                                            .transactionsFilteredEmptyMessage,
                                        actionLabel:
                                            l10n.transactionsResetFilters,
                                        onAction: _resetFilters,
                                      )
                                    : AppEmptyState(
                                        icon: Icons.receipt_long_outlined,
                                        title: l10n.transactionsEmptyTitle,
                                        message: l10n.transactionsEmptyMessage,
                                        actionLabel: l10n.transactionsAdd,
                                        onAction: _add,
                                      ))
                              : _journal(context, l10n, vm, value),
                      },
                    ),
                  ],
                );
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
    TransactionsViewModel vm,
    List<AssetTransaction> transactions,
  ) {
    final items = <Object>[];
    LocalDate? lastDate;
    for (final transaction in transactions) {
      if (lastDate != transaction.occurredOn) {
        items.add(transaction.occurredOn);
        lastDate = transaction.occurredOn;
      }
      items.add(transaction);
    }
    final showMore = vm.hasMore.value;
    final loadingMore = vm.loadingMore.value;
    return AppListView.builder(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: items.length + (showMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (showMore && index == items.length) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: l10n.journalLoadMore,
              variant: AppButtonVariant.outlined,
              pending: loadingMore,
              onPressed: loadingMore ? null : vm.loadMore,
            ),
          );
        }
        final item = items[index];
        if (item is LocalDate) {
          return AppDateHeader(const DateFormatter().format(item));
        }
        final transaction = item as AssetTransaction;
        final incoming =
            transaction.kind == AssetTransactionKind.deposit ||
            transaction.kind == AssetTransactionKind.transferIn;
        final isTransfer =
            transaction.kind == AssetTransactionKind.transferIn ||
            transaction.kind == AssetTransactionKind.transferOut;
        return AppOperationListTile(
          key: ValueKey(transaction.id),
          title: vm.assetName(transaction),
          typeLabel: _kindLabel(l10n, transaction.kind),
          icon: _kindIcon(transaction.kind),
          amountText: '${incoming ? '+' : '−'}${vm.formatAmount(transaction)}',
          dateText: '',
          tone: isTransfer
              ? AppMoneyTone.transfer
              : (incoming ? AppMoneyTone.income : AppMoneyTone.expense),
          onTap: () => _open(transaction.id),
        );
      },
    );
  }

  static IconData _kindIcon(AssetTransactionKind kind) => switch (kind) {
    AssetTransactionKind.deposit => Icons.add_circle_outline,
    AssetTransactionKind.withdrawal => Icons.remove_circle_outline,
    AssetTransactionKind.transferOut => Icons.north_east,
    AssetTransactionKind.transferIn => Icons.south_west,
  };

  static String _kindLabel(AppLocalizations l10n, AssetTransactionKind kind) =>
      switch (kind) {
        AssetTransactionKind.deposit => l10n.transactionKindDeposit,
        AssetTransactionKind.withdrawal => l10n.transactionKindWithdrawal,
        AssetTransactionKind.transferOut => l10n.transactionKindTransferOut,
        AssetTransactionKind.transferIn => l10n.transactionKindTransferIn,
      };
}
