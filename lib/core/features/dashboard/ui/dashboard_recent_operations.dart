import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Последние операции на главной (10.1).
class DashboardRecentOperations extends StatelessWidget {
  const DashboardRecentOperations({
    super.key,
    required this.operations,
    required this.assetNames,
    required this.l10n,
    required this.formatMoney,
    required this.onOpen,
    required this.onAll,
    required this.unknownAssetName,
    this.padded = true,
  });

  final List<AssetTransaction> operations;
  final Map<int, String> assetNames;
  final AppLocalizations l10n;
  final String Function(Money) formatMoney;
  final void Function(int id) onOpen;
  final VoidCallback onAll;
  final String unknownAssetName;

  /// false — секция внутри контейнера с готовым горизонтальным отступом.
  final bool padded;

  @override
  Widget build(BuildContext context) {
    return AppSection(
      header: l10n.dashboardRecentTitle,
      padded: padded,
      child: operations.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(l10n.dashboardRecentEmpty),
                const SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.dashboardAllOperations,
                  variant: AppButtonVariant.outlined,
                  onPressed: onAll,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final operation in operations)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: AppListTile(
                      title: assetNames[operation.assetId] ?? unknownAssetName,
                      subtitle:
                          '${const DateFormatter().format(operation.occurredOn)}'
                          ' · ${_type(l10n, operation.kind)}',
                      leading: _icon(operation.kind),
                      trailing: AppMoneyText(
                        formatMoney(operation.amount),
                        tone: _tone(operation.kind),
                      ),
                      onTap: () => onOpen(operation.id),
                    ),
                  ),
                AppButton(
                  label: l10n.dashboardAllOperations,
                  variant: AppButtonVariant.text,
                  onPressed: onAll,
                ),
              ],
            ),
    );
  }

  static AppMoneyTone _tone(AssetTransactionKind kind) => switch (kind) {
    AssetTransactionKind.deposit => AppMoneyTone.income,
    AssetTransactionKind.withdrawal => AppMoneyTone.expense,
    AssetTransactionKind.transferOut ||
    AssetTransactionKind.transferIn => AppMoneyTone.transfer,
  };

  static AppIcon _icon(AssetTransactionKind kind) => switch (kind) {
    AssetTransactionKind.deposit => const AppIcon(Icons.add),
    AssetTransactionKind.withdrawal => const AppIcon(Icons.remove),
    AssetTransactionKind.transferOut ||
    AssetTransactionKind.transferIn => const AppIcon(Icons.swap_horiz),
  };

  static String _type(AppLocalizations l10n, AssetTransactionKind kind) =>
      switch (kind) {
        AssetTransactionKind.deposit => l10n.transactionKindDeposit,
        AssetTransactionKind.withdrawal => l10n.transactionKindWithdrawal,
        AssetTransactionKind.transferOut => l10n.transactionKindTransferOut,
        AssetTransactionKind.transferIn => l10n.transactionKindTransferIn,
      };
}
