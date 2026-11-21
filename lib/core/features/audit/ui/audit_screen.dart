import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/audit/ui/audit_view_model.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_operation_list_tile.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Тип записи в аудите удалённых.
enum AuditKind { assetTransaction, cashflow }

/// Аудит удалённых операций и записей денежного потока (13.1).
class AuditScreen extends StatefulWidget {
  const AuditScreen({super.key, required this.viewModel});

  final AuditViewModel viewModel;

  @override
  State<AuditScreen> createState() => _AuditScreenState();
}

class _AuditScreenState extends State<AuditScreen> {
  late AuditViewModel _viewModel = widget.viewModel;
  AuditKind _kind = AuditKind.assetTransaction;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void didUpdateWidget(covariant AuditScreen oldWidget) {
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
      title: l10n.auditTitle,
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
          final loading = vm.state.value is ViewLoading;
          final items = _kind == AuditKind.assetTransaction
              ? vm.transactions.value
              : vm.entries.value;
          final rowCount = loading || items.isEmpty ? 1 : items.length;
          return AppListView.builder(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            itemCount: rowCount + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _tabs(l10n, vm);
              if (loading) {
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Center(
                    child: AppSpinner(semanticLabel: l10n.commonLoading),
                  ),
                );
              }
              if (items.isEmpty) {
                return AppEmptyState(
                  icon: Icons.delete_outline,
                  title: l10n.auditEmptyTitle,
                  message: l10n.auditEmptyMessage,
                );
              }
              return _kind == AuditKind.assetTransaction
                  ? _transactionTile(vm, l10n, index - 1)
                  : _entryTile(vm, l10n, index - 1);
            },
          );
        },
      ),
    );
  }

  Widget _tabs(AppLocalizations l10n, AuditViewModel vm) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    child: AppSegmentedControl<AuditKind>(
      selected: {_kind},
      onSelectionChanged: (values) => setState(() => _kind = values.first),
      segments: [
        AppSegment(
          value: AuditKind.assetTransaction,
          label: '${l10n.auditTabAssets} · ${vm.transactions.value.length}',
        ),
        AppSegment(
          value: AuditKind.cashflow,
          label: '${l10n.auditTabCashflow} · ${vm.entries.value.length}',
        ),
      ],
    ),
  );

  Widget _transactionTile(AuditViewModel vm, AppLocalizations l10n, int index) {
    final item = vm.transactions.value[index];
    final incoming =
        item.kind == AssetTransactionKind.deposit ||
        item.kind == AssetTransactionKind.transferIn;
    final name = vm.assetName(item.assetId);
    return AppOperationListTile(
      key: ValueKey('tx-${item.id}'),
      title: name.isNotEmpty
          ? name
          : item.comment?.trim().isNotEmpty == true
          ? item.comment!
          : _transactionKind(l10n, item.kind),
      typeLabel: _transactionKind(l10n, item.kind),
      icon: switch (item.kind) {
        AssetTransactionKind.deposit => Icons.add_circle_outline,
        AssetTransactionKind.withdrawal => Icons.remove_circle_outline,
        AssetTransactionKind.transferOut => Icons.north_east,
        AssetTransactionKind.transferIn => Icons.south_west,
      },
      amountText: '${incoming ? '+' : '−'}${vm.formatAmount(item.amount)}',
      dateText: _dateText(l10n, item.occurredOn, item.deletedAt),
      tone: incoming ? AppMoneyTone.income : AppMoneyTone.expense,
      comment: item.comment,
      deleted: true,
      showDeletedBadge: false,
      deletedLabel: l10n.auditDeletedLabel,
      onTap: () => context.push(AppRoutes.auditAssetTransactionPath(item.id)),
    );
  }

  Widget _entryTile(AuditViewModel vm, AppLocalizations l10n, int index) {
    final entry = vm.entries.value[index];
    final income = entry.kind == CashflowKind.income;
    final name = vm.categoryName(entry.categoryId);
    return AppOperationListTile(
      key: ValueKey('cf-${entry.id}'),
      title: name.isNotEmpty
          ? name
          : entry.comment?.trim().isNotEmpty == true
          ? entry.comment!
          : _cashflowKind(l10n, entry.kind),
      typeLabel: _cashflowKind(l10n, entry.kind),
      icon: income ? Icons.south_west : Icons.north_east,
      amountText: '${income ? '+' : '−'}${vm.formatAmount(entry.amount)}',
      dateText: _dateText(l10n, entry.occurredOn, entry.deletedAt),
      tone: income ? AppMoneyTone.income : AppMoneyTone.expense,
      comment: entry.comment,
      deleted: true,
      showDeletedBadge: false,
      deletedLabel: l10n.auditDeletedLabel,
      onTap: () => context.push(AppRoutes.auditCashflowPath(entry.id)),
    );
  }

  static String _dateText(
    AppLocalizations l10n,
    LocalDate occurredOn,
    DateTime? deletedAt,
  ) {
    final date = const DateFormatter().format(occurredOn);
    if (deletedAt == null) return date;
    final removed = const DateFormatter().format(
      LocalDate.fromDateTime(deletedAt.toLocal()),
    );
    return '$date · ${l10n.auditDeletedOn} $removed';
  }

  static String _transactionKind(
    AppLocalizations l10n,
    AssetTransactionKind kind,
  ) => switch (kind) {
    AssetTransactionKind.deposit => l10n.transactionKindDeposit,
    AssetTransactionKind.withdrawal => l10n.transactionKindWithdrawal,
    AssetTransactionKind.transferOut => l10n.transactionKindTransferOut,
    AssetTransactionKind.transferIn => l10n.transactionKindTransferIn,
  };

  static String _cashflowKind(AppLocalizations l10n, CashflowKind kind) =>
      switch (kind) {
        CashflowKind.income => l10n.cashflowIncome,
        CashflowKind.expense => l10n.cashflowExpense,
      };
}
