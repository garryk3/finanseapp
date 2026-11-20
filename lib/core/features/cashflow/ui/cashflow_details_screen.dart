import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_details_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_divider.dart';
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

/// Детали дохода/расхода: сумма, ревизии, edit/delete (7.1).
class CashflowDetailsScreen extends StatefulWidget {
  const CashflowDetailsScreen({super.key, required this.viewModel});

  final CashflowDetailsViewModel viewModel;

  @override
  State<CashflowDetailsScreen> createState() => _CashflowDetailsScreenState();
}

class _CashflowDetailsScreenState extends State<CashflowDetailsScreen> {
  late CashflowDetailsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void didUpdateWidget(covariant CashflowDetailsScreen oldWidget) {
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
      title: l10n.cashflowDetailsTitle,
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          final entry = vm.entry.value;
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
                      onPressed: () =>
                          context.push(AppRoutes.auditCashflowPath(vm.entryId)),
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
          if (entry == null) {
            return Center(child: AppText(l10n.commonLoading));
          }
          final income = entry.kind == CashflowKind.income;
          return AppListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppSummaryCard(
                  title: income ? l10n.cashflowIncome : l10n.cashflowExpense,
                  value: _money(entry.amount),
                  subtitle: entry.amount.currencyCode == 'RUB'
                      ? null
                      : '${l10n.transactionAmountRub}: '
                            '${_money(entry.amountRub)}',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppSection(
                header: vm.category.value?.name ?? l10n.cashflowCategoryLabel,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      '${l10n.transactionDateLabel}: '
                      '${const DateFormatter().format(entry.occurredOn)}',
                    ),
                    AppText(
                      '${l10n.transactionCommentLabel}: '
                      '${entry.comment ?? l10n.transactionCommentEmpty}',
                    ),
                    if (vm.accountName.value != null)
                      AppText(
                        '${l10n.cashflowAccountLabel}: '
                        '${vm.accountName.value}',
                      ),
                    if (vm.deleteError.value != null)
                      AppText(
                        l10n.cashflowDeleteError,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton(
                      label: l10n.accountEdit,
                      variant: AppButtonVariant.outlined,
                      onPressed: () async {
                        final saved = await context.push<bool>(
                          AppRoutes.cashflowEditPath(entry.id),
                        );
                        if (!mounted || saved != true) return;
                        await vm.load();
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.accountDelete,
                      variant: AppButtonVariant.destructive,
                      pending: vm.busy.value,
                      onPressed: vm.busy.value ? null : _delete,
                    ),
                  ],
                ),
              ),
              AppSection(
                header: l10n.transactionRevisionsTitle,
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

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final entry = _viewModel.entry.value;
    if (entry == null) return;
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: l10n.cashflowDeleteTitle,
        message: l10n.cashflowDeleteMessage,
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
      showAppSnackBar(context, message: l10n.errorStateMessage, isError: true);
      return;
    }
    showAppSnackBar(context, message: l10n.cashflowDeleted);
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop(true);
  }

  static String _action(AppLocalizations l10n, RevisionAction action) =>
      switch (action) {
        RevisionAction.create => l10n.revisionActionCreate,
        RevisionAction.edit => l10n.revisionActionEdit,
        RevisionAction.delete => l10n.revisionActionDelete,
        RevisionAction.restore => l10n.revisionActionRestore,
      };

  String _money(Money money) => const MoneyFormatter().format(
    money,
    _viewModel.currencies.value[money.currencyCode] ??
        Currency(
          code: money.currencyCode,
          name: money.currencyCode,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        ),
  );
}
