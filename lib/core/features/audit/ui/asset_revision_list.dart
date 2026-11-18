import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/revision.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_revision.dart';
import 'package:finanseapp/core/features/transactions/logic/revision_diff.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_divider.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:flutter/widgets.dart';

/// Append-only список ревизий операции с diff к предыдущей (6.3).
class AssetRevisionList extends StatelessWidget {
  const AssetRevisionList({super.key, required this.revisions});

  final List<AssetTransactionRevision> revisions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < revisions.length; i++) ...[
          if (i > 0) const AppDivider(),
          AppListTile(
            title:
                '${l10n.revisionLabel(revisions[i].revisionNo)} · '
                '${_actionLabel(l10n, revisions[i])}',
            subtitle: _subtitle(context, l10n, i),
          ),
        ],
      ],
    );
  }

  String _subtitle(BuildContext context, AppLocalizations l10n, int index) {
    final revision = revisions[index];
    final changedAt = const DateFormatter().format(
      LocalDate.fromDateTime(revision.changedAt.toLocal()),
    );
    if (index == 0) return changedAt;
    final diff = diffAssetTransactions(
      revisions[index - 1].snapshot,
      revision.snapshot,
    );
    if (diff.isEmpty) return changedAt;
    final lines = [
      for (final change in diff)
        l10n.revisionDiffLine(
          _fieldLabel(l10n, change.field),
          change.oldValue,
          change.newValue,
        ),
    ];
    return '$changedAt\n${lines.join('\n')}';
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
