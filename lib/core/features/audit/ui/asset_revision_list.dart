import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';
import 'package:finanseapp/core/features/transactions/logic/revision_diff.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_divider.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';

/// Append-only список ревизий операции с diff к предыдущей (6.3).
class AssetRevisionList extends StatelessWidget {
  const AssetRevisionList({super.key, required this.revisions});

  final List<AssetTransactionRevision> revisions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (revisions.isEmpty) {
      return AppText(l10n.revisionEmpty);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < revisions.length; i++) ...[
          if (i > 0) const AppDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '${l10n.revisionLabel(revisions[i].revisionNo)} · '
                  '${_actionLabel(l10n, revisions[i])}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                AppText(
                  _changedAt(revisions[i]),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                for (final line in _diffLines(l10n, i))
                  AppText(line, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _changedAt(AssetTransactionRevision revision) => const DateFormatter()
      .format(LocalDate.fromDateTime(revision.changedAt.toLocal()));

  List<String> _diffLines(AppLocalizations l10n, int index) {
    if (index == 0) return const [];
    final diff = diffAssetTransactions(
      revisions[index - 1].snapshot,
      revisions[index].snapshot,
    );
    return [
      for (final change in diff)
        l10n.revisionDiffLine(
          _fieldLabel(l10n, change.field),
          _value(l10n, change.field, change.oldValue),
          _value(l10n, change.field, change.newValue),
        ),
    ];
  }

  static String _value(AppLocalizations l10n, String field, String raw) {
    if (field == 'kind') {
      return switch (raw) {
        'deposit' => l10n.transactionKindDeposit,
        'withdrawal' => l10n.transactionKindWithdrawal,
        'transferOut' => l10n.transactionKindTransferOut,
        'transferIn' => l10n.transactionKindTransferIn,
        _ => raw,
      };
    }
    return raw.isEmpty ? '—' : raw;
  }

  static String _actionLabel(
    AppLocalizations l10n,
    AssetTransactionRevision revision,
  ) => switch (revision.action) {
    RevisionAction.create => l10n.revisionActionCreate,
    RevisionAction.edit => l10n.revisionActionEdit,
    RevisionAction.delete => l10n.revisionActionDelete,
    RevisionAction.restore => l10n.revisionActionEdit,
  };

  static String _fieldLabel(AppLocalizations l10n, String field) =>
      switch (field) {
        'amount' => l10n.revisionFieldAmount,
        'date' => l10n.revisionFieldDate,
        'kind' => l10n.revisionFieldKind,
        'rate' => l10n.revisionFieldRate,
        'comment' => l10n.revisionFieldComment,
        _ => field,
      };
}
