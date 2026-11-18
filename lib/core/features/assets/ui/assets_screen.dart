import 'dart:async';

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_asset_list_tile.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_search_field.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:finanseapp/uikit/app_switch.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Активы: единый каталог с поиском, видом, архивом и созданием (5.3).
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key, required this.viewModel});

  final AssetsViewModel viewModel;

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  late AssetsViewModel _viewModel = widget.viewModel;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant AssetsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      unawaited(oldWidget.viewModel.dispose());
      _search.clear();
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    unawaited(_viewModel.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navAssets,
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        tooltip: l10n.assetsAddAsset,
        onPressed: _addAsset,
      ),
      body: SignalBuilder(
        builder: (context) {
          final vm = _viewModel;
          final showFilters = vm.total.value > 0 || vm.filtersActive;
          final data = vm.state.value;
          final listEmpty =
              data is ViewData<List<AssetSnapshot>> && data.value.isEmpty;
          final archivedOnly =
              listEmpty && vm.total.value > 0 && !vm.filtersActive;
          return Column(
            children: [
              if (showFilters)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: AppSearchField(
                          controller: _search,
                          label: l10n.assetsSearchLabel,
                          hint: l10n.assetsSearchHint,
                          onChanged: vm.setQuery,
                          onClear: () => vm.setQuery(''),
                          clearTooltip: l10n.assetsSearchClear,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        child: AppFilterBar(
                          activeCount:
                              (vm.query.value.trim().isEmpty ? 0 : 1) +
                              (vm.kind.value == null ? 0 : 1) +
                              (vm.showArchived.value ? 1 : 0),
                          onReset: vm.filtersActive && !listEmpty
                              ? _resetFilters
                              : null,
                          resetLabel: l10n.assetsResetFilters,
                          children: [
                            AppFilterChip(
                              label: l10n.assetsFilterAll,
                              selected: vm.kind.value == null,
                              onSelected: (_) => vm.setKind(null),
                            ),
                            AppFilterChip(
                              label: l10n.assetKindAccount,
                              selected: vm.kind.value == AssetKind.account,
                              icon: Icons.account_balance_wallet_outlined,
                              count: vm.kindCounts.value[AssetKind.account],
                              onSelected: (_) => vm.setKind(AssetKind.account),
                            ),
                            AppFilterChip(
                              label: l10n.assetKindInvestment,
                              selected: vm.kind.value == AssetKind.investment,
                              icon: Icons.trending_up,
                              count: vm.kindCounts.value[AssetKind.investment],
                              onSelected: (_) =>
                                  vm.setKind(AssetKind.investment),
                            ),
                            AppFilterChip(
                              label: l10n.assetKindProperty,
                              selected: vm.kind.value == AssetKind.property,
                              icon: Icons.home_outlined,
                              count: vm.kindCounts.value[AssetKind.property],
                              onSelected: (_) => vm.setKind(AssetKind.property),
                            ),
                          ],
                        ),
                      ),
                      AppSwitch(
                        value: vm.showArchived.value,
                        label: l10n.assetsFilterArchived,
                        onChanged: vm.setShowArchived,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: switch (vm.state.value) {
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
                    onRetry: vm.retry,
                  ),
                  ViewData(:final value) =>
                    value.isEmpty
                        ? (vm.filtersActive
                              ? AppEmptyState(
                                  icon: Icons.search_off,
                                  title: l10n.assetsFilteredEmptyTitle,
                                  message: l10n.assetsFilteredEmptyMessage,
                                  actionLabel: l10n.assetsResetFilters,
                                  onAction: _resetFilters,
                                )
                              : archivedOnly
                              ? AppEmptyState(
                                  icon: Icons.archive_outlined,
                                  title: l10n.assetsAllArchivedTitle,
                                  message: l10n.assetsAllArchivedMessage,
                                  actionLabel: l10n.assetsShowArchivedAction,
                                  onAction: () => vm.setShowArchived(true),
                                )
                              : AppEmptyState(
                                  icon: Icons.account_balance_wallet_outlined,
                                  title: l10n.assetsEmptyTitle,
                                  message: l10n.assetsEmptyMessage,
                                  actionLabel: l10n.assetsAddAsset,
                                  onAction: _addAsset,
                                ))
                        : AppListView.builder(
                            padding: const EdgeInsets.only(bottom: 88),
                            itemCount: value.length,
                            itemBuilder: (context, index) {
                              final snapshot = value[index];
                              final asset = snapshot.asset;
                              final base = vm.baseEquivalent(snapshot);
                              return AppAssetListTile(
                                key: ValueKey(asset.id),
                                name: asset.name,
                                kindLabel: _kindLabel(l10n, asset.kind),
                                amountText: vm.formatAmount(
                                  snapshot.currentValue,
                                ),
                                baseAmountText:
                                    base.text ??
                                    (base.unavailable
                                        ? l10n.assetBaseUnavailable
                                        : null),
                                icon: _kindIcon(asset.kind),
                                archived: asset.archivedAt != null,
                                archivedLabel: l10n.accountArchivedBadge,
                                onTap: () => context.push(
                                  AppRoutes.assetDetailsPath(asset.id),
                                ),
                              );
                            },
                          ),
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _resetFilters() {
    _search.clear();
    FocusScope.of(context).unfocus();
    _viewModel.resetFilters();
  }

  Future<void> _addAsset() async {
    final l10n = AppLocalizations.of(context);
    final kind = await showAppDialog<String>(
      context: context,
      builder: (context) => AppDialog(
        title: AppText(l10n.assetsAddTitle),
        actions: [
          AppButton(
            label: l10n.commonCancel,
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: l10n.assetsAddAccount,
            onPressed: () => Navigator.of(context).pop('account'),
          ),
          AppButton(
            label: l10n.assetsAddInvestment,
            onPressed: () => Navigator.of(context).pop('investment'),
          ),
        ],
      ),
    );
    if (!mounted || kind == null) return;
    context.push(
      kind == 'account' ? AppRoutes.accountNew : AppRoutes.investmentNew,
    );
  }

  static String _kindLabel(AppLocalizations l10n, AssetKind kind) =>
      switch (kind) {
        AssetKind.account => l10n.assetKindAccount,
        AssetKind.investment => l10n.assetKindInvestment,
        AssetKind.property => l10n.assetKindProperty,
      };

  static IconData _kindIcon(AssetKind kind) => switch (kind) {
    AssetKind.account => Icons.account_balance_wallet_outlined,
    AssetKind.investment => Icons.trending_up,
    AssetKind.property => Icons.home_outlined,
  };
}
