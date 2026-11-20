import 'package:finanseapp/core/features/audit/ui/asset_revision_list.dart';
import 'package:finanseapp/core/features/audit/ui/audit_asset_transaction_view_model.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Аудит операции: ревизии даже после удаления (6.3).
class AuditAssetTransactionScreen extends StatefulWidget {
  const AuditAssetTransactionScreen({super.key, required this.viewModel});

  final AuditAssetTransactionViewModel viewModel;

  @override
  State<AuditAssetTransactionScreen> createState() =>
      _AuditAssetTransactionScreenState();
}

class _AuditAssetTransactionScreenState
    extends State<AuditAssetTransactionScreen> {
  late AuditAssetTransactionViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load();
  }

  @override
  void didUpdateWidget(covariant AuditAssetTransactionScreen oldWidget) {
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
      title: l10n.auditAssetTransactionTitle,
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
          if (vm.state.value is ViewLoading) {
            return Center(child: AppText(l10n.commonLoading));
          }
          return AppListView(
            children: [
              AppSection(
                header: vm.asset.value?.name ?? l10n.auditAssetTransactionTitle,
                child: AssetRevisionList(revisions: vm.revisions.value),
              ),
              if (vm.canRestore) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.auditRestore,
                  pending: vm.restoreBusy.value,
                  onPressed: vm.restoreBusy.value ? null : vm.restore,
                ),
              ],
              if (vm.restoreFailed.value) AppText(l10n.auditRestoreFailed),
            ],
          );
        },
      ),
    );
  }
}
