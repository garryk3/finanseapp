import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/audit/ui/asset_revision_list.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_details_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Детали операции: суммы, ревизии и удаление (6.3).
class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({super.key, required this.viewModel});

  final TransactionDetailsViewModel viewModel;

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late TransactionDetailsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void didUpdateWidget(covariant TransactionDetailsScreen oldWidget) {
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
      title: l10n.transactionDetailsTitle,
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          final transaction = vm.transaction.value;
          if (vm.state.value is ViewError) {
            if (vm.state.value case ViewError(
              errorCode: DomainErrorCode.notFound,
            )) {
              return AppListView(
                children: [
                  AppEmptyState(
                    icon: Icons.search_off,
                    title: l10n.notFoundTitle,
                    message: l10n.notFoundMessage,
                    actionLabel: l10n.notFoundHome,
                    onAction: () => context.go(AppRoutes.dashboard),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: AppButton(
                      label: l10n.transactionAuditAction,
                      variant: AppButtonVariant.text,
                      onPressed: () => context.push(
                        AppRoutes.auditAssetTransactionPath(vm.transactionId),
                      ),
                    ),
                  ),
                ],
              );
            }
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.load,
            );
          }
          if (transaction == null) {
            return Center(child: AppText(l10n.commonLoading));
          }
          final asset = vm.asset.value;
          return AppListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppSummaryCard(
                  title: _kindLabel(l10n, transaction.kind),
                  value: _money(transaction.amount),
                  subtitle: transaction.amount.currencyCode == 'RUB'
                      ? null
                      : '${l10n.transactionAmountRub}: '
                            '${_money(transaction.amountRub)}',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSection(
                header: asset?.name ?? l10n.transactionAssetLabel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      '${l10n.transactionDateLabel}: '
                      '${const DateFormatter().format(transaction.occurredOn)}',
                    ),
                    AppText(
                      '${l10n.transactionCommentLabel}: '
                      '${transaction.comment ?? l10n.transactionCommentEmpty}',
                    ),
                    if (vm.baseUnavailable.value)
                      AppText(l10n.assetBaseUnavailable),
                    if (vm.baseAmount.value != null)
                      AppText(
                        '${l10n.assetBaseEquivalent}: '
                        '${_money(vm.baseAmount.value!)}',
                      ),
                    if (transaction.cashflowEntryId != null)
                      AppText(l10n.transactionLinkedCashflow),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l10n.transactionAuditAction,
                      variant: AppButtonVariant.text,
                      onPressed: () => context.push(
                        AppRoutes.auditAssetTransactionPath(transaction.id),
                      ),
                    ),
                    AppButton(
                      label: _isTransfer
                          ? l10n.transferDeleteAction
                          : l10n.accountDelete,
                      variant: AppButtonVariant.destructive,
                      pending: vm.busy.value,
                      onPressed: vm.busy.value ? null : _delete,
                    ),
                  ],
                ),
              ),
              AppSection(
                header: l10n.transactionRevisionsTitle,
                child: AssetRevisionList(revisions: vm.revisions.value),
              ),
            ],
          );
        },
      ),
    );
  }

  bool get _isTransfer => _viewModel.transaction.value?.transferId != null;

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: _isTransfer
            ? l10n.transferDeleteTitle
            : l10n.transactionDeleteTitle,
        message: _isTransfer
            ? l10n.transferDeleteMessage
            : l10n.transactionDeleteMessage,
        confirmLabel: l10n.commonDelete,
        cancelLabel: l10n.commonCancel,
        destructive: true,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed != true) return;
    final result = await _viewModel.delete();
    if (!mounted) return;
    if (result is Failure<void>) {
      final message = switch (result.error) {
        DomainException(code: DomainErrorCode.negativeBalance) =>
          l10n.transactionDeleteBalanceBlocked,
        DomainException(fieldErrors: final fields)
            when fields.values.contains('validationTransferLegDirectEdit') =>
          l10n.transactionDeleteBlocked,
        _ => l10n.errorStateMessage,
      };
      showAppSnackBar(context, message: message, isError: true);
      return;
    }
    showAppSnackBar(context, message: l10n.transactionDeleted);
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop(true);
  }

  static String _money(Money money) => const MoneyFormatter().format(
    money,
    Currency(
      code: money.currencyCode,
      name: money.currencyCode,
      fractionDigits: 2,
      isPreset: true,
      isEnabled: true,
    ),
  );

  static String _kindLabel(AppLocalizations l10n, AssetTransactionKind kind) =>
      switch (kind) {
        AssetTransactionKind.deposit => l10n.transactionKindDeposit,
        AssetTransactionKind.withdrawal => l10n.transactionKindWithdrawal,
        AssetTransactionKind.transferOut => l10n.transactionKindTransferOut,
        AssetTransactionKind.transferIn => l10n.transactionKindTransferIn,
      };
}
