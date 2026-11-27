import 'dart:async';

import 'package:collection/collection.dart';
import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/currencies/logic/rate_refresh_service.dart';
import 'package:finanseapp/core/features/currencies/ui/currencies_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_icon_button.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_popup_menu.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_skeleton.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:finanseapp/uikit/app_top_app_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

enum _CurrencyAction { toggle, rename, delete }

/// Справочник валют: enable/disable, rename, delete, переход к базовой (BR-C).
class CurrenciesScreen extends StatefulWidget {
  const CurrenciesScreen({super.key, required this.viewModel});

  final CurrenciesViewModel viewModel;

  @override
  State<CurrenciesScreen> createState() => _CurrenciesScreenState();
}

class _CurrenciesScreenState extends State<CurrenciesScreen> {
  late CurrenciesViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant CurrenciesScreen oldWidget) {
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

  AppLocalizations get _l10n => AppLocalizations.of(context);

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;
    return AppScaffold(
      appBar: AppTopAppBar(
        title: l10n.currenciesTitle,
        actions: [
          SignalBuilder(
            builder: (context) => AppIconButton(
              icon: Icons.refresh,
              tooltip: l10n.currenciesRefreshTooltip,
              pending: _viewModel.refreshing.value,
              pendingLabel: l10n.currenciesRefreshPending,
              onPressed: _refreshRates,
            ),
          ),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        tooltip: l10n.currencyAdd,
        onPressed: () => context.push(AppRoutes.currencyNew),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppButton(
              label: l10n.currenciesBaseAction,
              icon: Icons.payments_outlined,
              variant: AppButtonVariant.tonal,
              onPressed: () => context.push(AppRoutes.baseCurrency),
            ),
          ),
          Expanded(
            child: SignalBuilder(
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
                          icon: Icons.payments_outlined,
                          title: l10n.subgroupEmptyTitle,
                          message: l10n.currencyAdd,
                          actionLabel: l10n.currencyAdd,
                          onAction: () => context.push(AppRoutes.currencyNew),
                        )
                      : _list(value, l10n),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(List<Currency> currencies, AppLocalizations l10n) =>
      AppListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final isBase = _viewModel.baseCode.value == currency.code;
          final meta = [
            l10n.currencyFractionValue(currency.fractionDigits),
            if (isBase) l10n.baseCurrencyCurrent,
            if (!currency.isEnabled) l10n.currencyDisabledLabel,
          ].join(' · ');
          return AppListTile(
            key: ValueKey(currency.code),
            title: '${currency.code} · ${currency.name}',
            subtitle: meta,
            enabled: currency.isEnabled,
            semanticLabel: '${currency.code} · ${currency.name}, $meta',
            leading: const AppIcon(Icons.payments_outlined),
            trailing: AppPopupMenu<_CurrencyAction>(
              tooltip: l10n.currencyActionsTooltip,
              items: [
                AppPopupMenuItem(
                  value: _CurrencyAction.toggle,
                  label: currency.isEnabled
                      ? l10n.currencyToggleDisable
                      : l10n.currencyToggleEnable,
                  icon: currency.isEnabled
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                AppPopupMenuItem(
                  value: _CurrencyAction.rename,
                  label: l10n.currencyRename,
                  icon: Icons.edit_outlined,
                ),
                AppPopupMenuItem(
                  value: _CurrencyAction.delete,
                  label: l10n.currencyDelete,
                  icon: Icons.delete_outline,
                ),
              ],
              onSelected: (action) => switch (action) {
                _CurrencyAction.toggle => _toggle(currency),
                _CurrencyAction.rename => _rename(currency),
                _CurrencyAction.delete => _delete(currency),
              },
            ),
          );
        },
      );

  Future<void> _toggle(Currency currency) async {
    if (currency.code == 'RUB') {
      await _explainProtected(currency);
      return;
    }
    if (currency.isEnabled) {
      final references = await _viewModel.countReferences(currency.code);
      if (!mounted) return;
      if (references > 0) {
        await _explainProtected(currency);
        return;
      }
    }
    final result = await _viewModel.setEnabled(
      currency.code,
      !currency.isEnabled,
    );
    if (!mounted) return;
    _report(result, success: _l10n.currencyToggled);
  }

  Future<void> _rename(Currency currency) async {
    await showAppDialog<void>(
      context: context,
      builder: (context) => _RenameDialog(
        currency: currency,
        submit: (name) async {
          final result = await _viewModel.rename(currency.code, name);
          return result is Failure<void> ? result.error : null;
        },
        errorText: _errorText,
      ),
    );
  }

  Future<void> _delete(Currency currency) async {
    final l10n = _l10n;
    if (currency.code == 'RUB') {
      await _explainProtected(currency);
      return;
    }
    final references = await _viewModel.countReferences(currency.code);
    if (!mounted) return;
    if (references > 0) {
      await _explainProtected(currency);
      return;
    }
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: l10n.currencyDeleteConfirmTitle(currency.code),
        message: l10n.currencyDeleteConfirmMessage,
        confirmLabel: l10n.commonDelete,
        cancelLabel: l10n.commonCancel,
        destructive: true,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
    if (confirmed != true) return;
    final result = await _viewModel.deleteIfUnused(currency.code);
    if (!mounted) return;
    _report(result, success: l10n.currencyDeleted);
  }

  Future<void> _explainProtected(Currency currency) => showAppDialog<void>(
    context: context,
    builder: (context) => AppDialog(
      title: AppText(_l10n.currencyErrorInUse),
      content: AppText(
        currency.code == 'RUB'
            ? _l10n.currencyErrorRub
            : _l10n.currencyErrorInUseCode(currency.code),
      ),
      actions: [
        AppButton(
          label: _l10n.commonCancel,
          variant: AppButtonVariant.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  /// Ручное обновление курсов (R3): индикатор на иконке + snackbar-результат.
  Future<void> _refreshRates() async {
    final l10n = _l10n;
    final RateRefreshReport report;
    try {
      report = await _viewModel.refreshRates();
    } on DomainException {
      if (!mounted) return;
      _showError(l10n.errorStateMessage);
      return;
    }
    if (!mounted) return;
    if (report.hasFailures) {
      _showError(l10n.currenciesRefreshFailed(report.failures.length));
      return;
    }
    showAppSnackBar(
      context,
      message: report.refreshed == 0
          ? l10n.currenciesRefreshUpToDate
          : l10n.currenciesRefreshDone(report.refreshed),
    );
  }

  void _report(Result<void> result, {String? success}) {
    if (result is Failure<void>) {
      _showError(_errorText(result.error));
      return;
    }
    if (success != null) showAppSnackBar(context, message: success);
  }

  String _errorText(DomainException error) {
    final l10n = _l10n;
    final key = error.fieldErrors.values.firstOrNull;
    return switch (key) {
      'validationCurrencyDuplicate' => l10n.currencyErrorDuplicate,
      'validationNameRequired' => l10n.currencyNameRequired,
      'validationCurrencyCodeFormat' => l10n.currencyErrorCode,
      'validationCurrencyInUse' => l10n.currencyErrorInUse,
      'validationRubProtected' => l10n.currencyErrorRub,
      _ => l10n.errorStateMessage,
    };
  }

  void _showError(String message) =>
      showAppSnackBar(context, message: message, isError: true);
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({
    required this.currency,
    required this.submit,
    required this.errorText,
  });

  final Currency currency;
  final Future<DomainException?> Function(String name) submit;
  final String Function(DomainException error) errorText;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.currency.name,
  );
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final error = await widget.submit(name);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _saving = false;
      _error = widget.errorText(error);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopScope(
      canPop: !_saving,
      child: AppDialog(
        title: AppText(l10n.currencyRenameNamed(widget.currency.code)),
        content: AppTextField(
          label: l10n.currencyNameLabel,
          controller: _controller,
          errorText: _error,
          autofocus: true,
        ),
        actions: [
          AppButton(
            label: l10n.commonCancel,
            variant: AppButtonVariant.text,
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
          ),
          AppButton(
            label: l10n.commonSave,
            pending: _saving,
            onPressed: _saving ? null : _save,
          ),
        ],
      ),
    );
  }
}
