import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/domain/asset_valuation.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/property_cashflow_section.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_chip.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_divider.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_popup_menu.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_summary_card.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_top_app_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Детали актива: счёт (5.1), инвестиция и оценки (5.2).
class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key, required this.viewModel});

  final AccountDetailsViewModel viewModel;

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  late AccountDetailsViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void didUpdateWidget(covariant AccountDetailsScreen oldWidget) {
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
    return SignalBuilder(
      builder: (context) {
        final vm = _viewModel;
        final asset = vm.asset.value;
        return AppScaffold(
          appBar: AppTopAppBar(
            title: switch (asset?.kind) {
              AssetKind.investment => l10n.investmentDetailsTitle,
              AssetKind.property => l10n.assetKindProperty,
              AssetKind.account || null => l10n.accountDetailsTitle,
            },
            actions: [if (asset != null) _actions(l10n, vm, asset)],
          ),
          body: _body(context, vm, asset),
        );
      },
    );
  }

  Widget _body(BuildContext context, AccountDetailsViewModel vm, Asset? asset) {
    final l10n = AppLocalizations.of(context);
    if (vm.error.value != null) {
      return AppErrorState(
        title: l10n.errorStateTitle,
        message: l10n.errorStateMessage,
        errorLabel: l10n.errorLabel,
        retryLabel: l10n.retry,
        onRetry: vm.load,
      );
    }
    if (asset == null) {
      return Center(child: AppSpinner(semanticLabel: l10n.commonLoading));
    }
    final isAccount = asset is AccountAsset;
    final isInvestment = asset is InvestmentAsset;
    final isArchived = asset.archivedAt != null;
    final showBase =
        vm.baseCurrency.value != null &&
        vm.baseCurrency.value!.code != asset.currencyCode;
    return AppListView(
      children: [
        AppSection(
          header: asset.name,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSummaryCard(
                title: isAccount
                    ? l10n.accountBalanceLabel
                    : l10n.investmentCurrentValue,
                value: _money(vm.balance.value),
                subtitle: isAccount
                    ? '${l10n.accountForecastLabel}: '
                          '${_money(vm.forecast.value)}'
                    : null,
              ),
              if (isAccount) ...[
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  l10n.accountForecastHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (asset is PropertyAsset) ...[
                if (asset.address != null) AppText(asset.address!),
                if (asset.purchasePrice != null)
                  AppText(
                    '${l10n.propertyPurchasePriceLabel}: '
                    '${_money(asset.purchasePrice)}',
                  ),
              ],
              if (showBase) ...[
                const SizedBox(height: AppSpacing.md),
                AppText(l10n.assetBaseEquivalent),
                AppMoneyText(
                  vm.baseRateUnavailable.value
                      ? l10n.assetBaseUnavailable
                      : _money(
                          vm.baseEquivalent.value,
                          currency: vm.baseCurrency.value,
                        ),
                ),
              ],
              if (isArchived) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(children: [AppChip(label: l10n.accountArchivedBadge)]),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (!isArchived &&
                  (isAccount || isInvestment || asset is PropertyAsset))
                AppButton(
                  label: l10n.accountEdit,
                  variant: AppButtonVariant.outlined,
                  onPressed: vm.busy.value ? null : () => _edit(asset),
                ),
              if (!isArchived && (isAccount || isInvestment))
                const SizedBox(height: AppSpacing.sm),
              if (!isArchived && (isAccount || isInvestment))
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: l10n.transactionAddDeposit,
                        variant: AppButtonVariant.tonal,
                        onPressed: vm.busy.value
                            ? null
                            : () => _addTransaction(asset.id, deposit: true),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        label: l10n.transactionAddWithdrawal,
                        variant: AppButtonVariant.tonal,
                        onPressed: vm.busy.value
                            ? null
                            : () => _addTransaction(asset.id, deposit: false),
                      ),
                    ),
                  ],
                ),
              if (!isArchived && isAccount)
                const SizedBox(height: AppSpacing.sm),
              if (!isArchived && isAccount)
                AppButton(
                  label: l10n.transferAction,
                  icon: Icons.swap_horiz,
                  variant: AppButtonVariant.text,
                  onPressed: vm.busy.value ? null : () => _transfer(asset.id),
                ),
              if (!isArchived && !isAccount)
                const SizedBox(height: AppSpacing.sm),
              if (!isArchived && !isAccount)
                AppButton(
                  label: l10n.investmentAddValuation,
                  variant: AppButtonVariant.outlined,
                  onPressed: vm.busy.value
                      ? null
                      : () => _addValuation(asset.id),
                ),
            ],
          ),
        ),
        if (asset is PropertyAsset && vm.cashflowRepository != null)
          PropertyCashflowSection(
            repository: vm.cashflowRepository!,
            propertyId: asset.id,
            today: vm.today,
            readOnly: isArchived,
          ),
        if (!isAccount)
          AppSection(
            header: l10n.valuationHistory,
            child: vm.valuationHistory.value.isEmpty
                ? AppText(l10n.valuationHistoryEmpty)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (
                        var i = 0;
                        i < vm.valuationHistory.value.length;
                        i++
                      ) ...[
                        if (i > 0) const AppDivider(),
                        _ValuationRow(
                          valuation: vm.valuationHistory.value[i],
                          current: i == 0,
                          fractionDigits:
                              vm.currency.value?.fractionDigits ?? 2,
                        ),
                      ],
                    ],
                  ),
          ),
      ],
    );
  }

  Widget _actions(
    AppLocalizations l10n,
    AccountDetailsViewModel vm,
    Asset asset,
  ) => AppPopupMenu<String>(
    tooltip: l10n.assetActions,
    enabled: !vm.busy.value,
    items: [
      if (asset.archivedAt == null)
        AppPopupMenuItem(
          value: 'archive',
          label: l10n.accountArchive,
          icon: Icons.archive_outlined,
        ),
      AppPopupMenuItem(
        value: 'delete',
        label: l10n.accountDelete,
        icon: Icons.delete_outline,
      ),
    ],
    onSelected: (value) {
      if (value == 'archive') {
        _archive();
      } else {
        _delete(asset);
      }
    },
  );

  Future<void> _edit(Asset asset) async {
    final path = switch (asset) {
      AccountAsset() => AppRoutes.accountEditPath(asset.id),
      InvestmentAsset() => AppRoutes.investmentEditPath(asset.id),
      PropertyAsset() => AppRoutes.propertyEditPath(asset.id),
    };
    await context.push(path);
    if (!mounted) return;
    await _viewModel.load();
  }

  Future<void> _transfer(int id) async {
    final saved = await context.push<bool>(AppRoutes.transferNewFor(id));
    if (!mounted || saved != true) return;
    await _viewModel.load();
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).transferSaved,
    );
  }

  Future<void> _addTransaction(int id, {required bool deposit}) async {
    final saved = await context.push<bool>(
      AppRoutes.transactionNewFor(id, deposit: deposit),
    );
    if (!mounted || saved != true) return;
    await _viewModel.load();
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).transactionSaved,
    );
  }

  Future<void> _addValuation(int id) async {
    final saved = await context.push<bool>(AppRoutes.valuationNewPath(id));
    if (!mounted || saved != true) return;
    await _viewModel.load();
    if (!mounted) return;
    showAppSnackBar(
      context,
      message: AppLocalizations.of(context).valuationSaved,
    );
  }

  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context);
    final isAccount = _viewModel.asset.value is AccountAsset;
    final result = await _viewModel.archive();
    if (!mounted) return;
    if (result is Failure<void>) {
      showAppSnackBar(context, message: l10n.assetArchiveFailed, isError: true);
      return;
    }
    showAppSnackBar(
      context,
      message: isAccount ? l10n.accountArchived : l10n.assetArchived,
    );
  }

  Future<void> _delete(Asset asset) async {
    final l10n = AppLocalizations.of(context);
    final isAccount = asset is AccountAsset;
    final counts = _viewModel.referenceCounts.value;
    if (counts != null && counts.isUsed) {
      await showAppDialog<void>(
        context: context,
        builder: (context) => AppDialog(
          title: AppText(l10n.assetInUseTitle),
          content: AppText(
            l10n.assetInUseMessage(
              counts.transactions,
              counts.valuations,
              counts.goals,
              counts.cashflow,
            ),
          ),
          actions: [
            AppButton(
              label: l10n.commonCancel,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: isAccount
            ? l10n.accountDeleteTitle(asset.name)
            : l10n.assetDeleteTitle(asset.name),
        message: isAccount
            ? l10n.accountDeleteMessage
            : l10n.assetDeleteMessage,
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
      showAppSnackBar(context, message: l10n.assetErrorInUse, isError: true);
      return;
    }
    showAppSnackBar(
      context,
      message: isAccount ? l10n.accountDeleted : l10n.assetDeleted,
    );
    if (context.mounted) context.pop();
  }

  String _money(Money? money, {Currency? currency}) {
    if (money == null) return '—';
    final effective =
        currency ??
        (money.currencyCode == _viewModel.currency.value?.code
            ? _viewModel.currency.value
            : null) ??
        Currency(
          code: money.currencyCode,
          name: money.currencyCode,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        );
    return const MoneyFormatter().format(money, effective);
  }
}

/// Строка истории оценок: сумма, дата, рублёвый эквивалент и метка текущей.
class _ValuationRow extends StatelessWidget {
  const _ValuationRow({
    required this.valuation,
    required this.current,
    required this.fractionDigits,
  });

  final AssetValuation valuation;
  final bool current;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatted = const MoneyFormatter().format(
      valuation.value,
      Currency(
        code: valuation.value.currencyCode,
        name: valuation.value.currencyCode,
        fractionDigits: fractionDigits,
        isPreset: true,
        isEnabled: true,
      ),
    );
    final date = const DateFormatter().format(valuation.effectiveOn);
    final rub = valuation.value.currencyCode == 'RUB'
        ? null
        : l10n.valuationRubLine(
            const MoneyFormatter().format(
              valuation.valueRub,
              const Currency(
                code: 'RUB',
                name: 'RUB',
                fractionDigits: 2,
                isPreset: true,
                isEnabled: true,
              ),
            ),
          );
    return AppListTile(
      title: formatted,
      subtitle: rub == null ? date : '$date · $rub',
      trailing: current
          ? ExcludeSemantics(child: AppChip(label: l10n.valuationCurrent))
          : null,
      semanticLabel:
          '${l10n.valuationDateLabel} $date, $formatted'
          '${rub == null ? '' : ', $rub'}'
          '${current ? ', ${l10n.valuationCurrent}' : ''}',
    );
  }
}
