import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_view_model.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Детали счёта: факт, прогноз и действия (5.1).
class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key, required this.viewModel});

  final AccountDetailsViewModel viewModel;

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    widget.viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.accountDetailsTitle,
      body: SignalBuilder(
        builder: (context) {
          final vm = widget.viewModel;
          final account = vm.account.value;
          if (vm.error.value != null) {
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.load,
            );
          }
          if (account == null) {
            return Center(child: AppText(l10n.commonLoading));
          }
          return AppListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppSection(
                header: account.name,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(l10n.accountBalanceLabel),
                    AppText(_money(vm.balance.value)),
                    const SizedBox(height: AppSpacing.md),
                    AppText(l10n.accountForecastLabel),
                    AppText(_money(vm.forecast.value)),
                    AppText(l10n.accountForecastHint),
                    if (account.archivedAt != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      AppText(l10n.accountArchivedBadge),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    if (account.archivedAt == null)
                      AppButton(
                        label: l10n.accountEdit,
                        variant: AppButtonVariant.outlined,
                        onPressed: vm.busy.value
                            ? null
                            : () => context.push(
                                AppRoutes.accountEditPath(account.id),
                              ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    if (account.archivedAt == null)
                      AppButton(
                        label: l10n.accountArchive,
                        variant: AppButtonVariant.tonal,
                        onPressed: vm.busy.value ? null : () => _archive(),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    AppButton(
                      label: l10n.accountDelete,
                      variant: AppButtonVariant.destructive,
                      onPressed: vm.busy.value ? null : () => _delete(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _money(Money? money) {
    if (money == null) return '—';
    return const MoneyFormatter().format(
      money,
      Currency(
        code: money.currencyCode,
        name: money.currencyCode,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      ),
    );
  }

  Future<void> _archive() async {
    final l10n = AppLocalizations.of(context);
    final result = await widget.viewModel.archive();
    if (!mounted) return;
    if (result is Failure<void>) {
      showAppSnackBar(context, message: l10n.accountErrorInUse, isError: true);
      return;
    }
    showAppSnackBar(context, message: l10n.accountArchived);
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final account = widget.viewModel.account.value;
    if (account == null) return;
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: l10n.accountDeleteTitle(account.name),
        message: l10n.accountDeleteMessage,
        confirmLabel: l10n.commonDelete,
        cancelLabel: l10n.commonCancel,
        destructive: true,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed != true) return;
    final result = await widget.viewModel.delete();
    if (!mounted) return;
    if (result is Failure<void>) {
      showAppSnackBar(context, message: l10n.accountErrorInUse, isError: true);
      return;
    }
    showAppSnackBar(context, message: l10n.accountDeleted);
    if (context.mounted) context.pop();
  }
}
