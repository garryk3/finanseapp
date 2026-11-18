import 'dart:async';

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_asset_list_tile.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Активы (5.1: счета): список, CTA создания и переход к деталям.
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key, required this.viewModel});

  final AssetsViewModel viewModel;

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  late AssetsViewModel _viewModel = widget.viewModel;

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
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
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
        builder: (context) => switch (_viewModel.state.value) {
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
            onRetry: _viewModel.retry,
          ),
          ViewData(:final value) =>
            value.isEmpty
                ? AppEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: l10n.assetsEmptyTitle,
                    message: l10n.assetsEmptyMessage,
                    actionLabel: l10n.assetsAddAsset,
                    onAction: _addAsset,
                  )
                : AppListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final snapshot = value[index];
                      final asset = snapshot.asset;
                      return AppAssetListTile(
                        key: ValueKey(asset.id),
                        name: asset.name,
                        kindLabel: _kindLabel(l10n, asset.kind),
                        amountText: _formatted(snapshot),
                        icon: _kindIcon(asset.kind),
                        onTap: () =>
                            context.push(AppRoutes.assetDetailsPath(asset.id)),
                      );
                    },
                  ),
        },
      ),
    );
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

  static String _formatted(AssetSnapshot snapshot) =>
      const MoneyFormatter().format(
        snapshot.currentValue,
        Currency(
          code: snapshot.currentValue.currencyCode,
          name: snapshot.currentValue.currencyCode,
          fractionDigits: 2,
          isPreset: true,
          isEnabled: true,
        ),
      );
}
