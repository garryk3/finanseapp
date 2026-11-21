import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rule_form_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_category_select.dart';
import 'package:finanseapp/uikit/app_confirm_dialog.dart';
import 'package:finanseapp/uikit/app_currency_select.dart';
import 'package:finanseapp/uikit/app_date_picker_field.dart';
import 'package:finanseapp/uikit/app_dialog.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_snack_bar.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_switch.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Форма создания/правки ежемесячного платежа (15.2).
class RecurringRuleFormScreen extends StatefulWidget {
  const RecurringRuleFormScreen({super.key, required this.viewModel});

  final RecurringRuleFormViewModel viewModel;

  @override
  State<RecurringRuleFormScreen> createState() =>
      _RecurringRuleFormScreenState();
}

class _RecurringRuleFormScreenState extends State<RecurringRuleFormScreen> {
  final _amount = TextEditingController();
  final _comment = TextEditingController();
  CashflowKind _kind = CashflowKind.expense;
  int? _categoryId;
  int? _accountId;
  int? _propertyId;
  bool _affectsBalance = false;
  String _currencyCode = 'RUB';
  late LocalDate _startDate = widget.viewModel.today;
  LocalDate? _endDate;
  String? _amountError;
  String? _categoryError;
  String? _dateError;
  String? _formError;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    _comment.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final vm = widget.viewModel;
    await vm.load(kind: vm.initialKind);
    if (!mounted) return;
    final rule = vm.rule.value;
    if (vm.state.value is ViewError) return;
    final presetAccount = vm.accounts.value
        .where((account) => account.id == vm.presetAccountId)
        .firstOrNull;
    setState(() {
      _kind = rule?.kind ?? vm.initialKind;
      _categoryId = rule?.categoryId;
      _accountId = rule?.accountId ?? vm.presetAccountId;
      _propertyId = rule?.propertyId ?? vm.presetPropertyId;
      _currencyCode =
          rule?.currencyCode ?? presetAccount?.currencyCode ?? 'RUB';
      _affectsBalance = rule?.affectsBalance ?? false;
      _startDate = rule?.startDate ?? vm.today;
      _endDate = rule?.endDate;
      if (rule?.amount != null) {
        _amount.text = MoneyMath.toDecimal(
          rule!.amount!,
          vm.currencyOf(rule.currencyCode),
        ).toString();
      }
      _comment.text = rule?.comment ?? '';
      _loaded = true;
    });
  }

  Future<void> _setKind(CashflowKind kind) async {
    setState(() {
      _kind = kind;
      _categoryId = null;
      _categoryError = null;
    });
    await widget.viewModel.loadCategories(kind);
  }

  void _setAccount(int? id) {
    setState(() {
      _accountId = id;
      if (id == null) {
        _affectsBalance = false;
        return;
      }
      _propertyId = null;
      final account = widget.viewModel.accounts.value
          .where((item) => item.id == id)
          .firstOrNull;
      if (account != null && account.currencyCode != _currencyCode) {
        _currencyCode = account.currencyCode;
        _amount.clear();
        _amountError = null;
      }
    });
  }

  void _setProperty(int? id) {
    setState(() {
      _propertyId = id;
      if (id != null) {
        _accountId = null;
        _affectsBalance = false;
      }
    });
  }

  Future<void> _save() async {
    final vm = widget.viewModel;
    if (_saving || vm.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final currency = vm.currencyOf(_currencyCode);
    final amount = parseOpeningAmount(_amount.text, currency);
    final amountError = amount == null || amount.minorUnits <= 0
        ? l10n.cashflowErrorAmount
        : null;
    final categoryError = _categoryId == null
        ? l10n.cashflowErrorCategory
        : null;
    final dateError = _endDate != null && _endDate!.compareTo(_startDate) < 0
        ? l10n.recurringErrorDates
        : null;
    if (amountError != null || categoryError != null || dateError != null) {
      setState(() {
        _amountError = amountError;
        _categoryError = categoryError;
        _dateError = dateError;
      });
      return;
    }
    setState(() {
      _amountError = null;
      _categoryError = null;
      _dateError = null;
      _formError = null;
      _saving = true;
    });
    final result = await vm.save(
      kind: _kind,
      categoryId: _categoryId!,
      amount: Money(
        minorUnits: amount!.minorUnits,
        currencyCode: _currencyCode,
      ),
      currencyCode: _currencyCode,
      accountId: _accountId,
      propertyId: _propertyId,
      affectsBalance: _affectsBalance && _accountId != null,
      startDate: _startDate,
      endDate: _endDate,
      comment: _comment.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is Failure<int>) {
      _showError(l10n, result.error);
      return;
    }
    showAppSnackBar(context, message: l10n.recurringSaved);
    Navigator.of(context).pop(true);
  }

  void _showError(AppLocalizations l10n, DomainException error) {
    final key = error.fieldErrors.values.isEmpty
        ? ''
        : error.fieldErrors.values.first;
    final message = switch (key) {
      'validationAmountPositive' => l10n.cashflowErrorAmount,
      'validationCategoryKindMismatch' => l10n.cashflowErrorKindMismatch,
      'validationCategoryArchived' => l10n.cashflowErrorCategoryArchived,
      'validationCurrencyMismatch' => l10n.cashflowErrorCurrencyMismatch,
      'validationPropertyAndAccountExclusive' => l10n.cashflowErrorAccount,
      'validationBalanceRequiresAccount' => l10n.cashflowErrorAccount,
      'validationRecurringDates' => l10n.recurringErrorDates,
      'validationRuleDeleted' => l10n.recurringRuleDeletedMessage,
      'validationCategoryNotFound' => l10n.cashflowErrorCategory,
      _ => l10n.errorStateMessage,
    };
    setState(() {
      switch (key) {
        case 'validationAmountPositive':
          _amountError = message;
        case 'validationRecurringDates':
          _dateError = message;
        case 'validationCategoryKindMismatch' ||
            'validationCategoryArchived' ||
            'validationCategoryNotFound':
          _categoryError = message;
        default:
          _formError = message;
      }
    });
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: l10n.recurringDeleteTitle,
        message: l10n.recurringDeleteMessage,
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
      showAppSnackBar(context, message: l10n.errorStateMessage, isError: true);
      return;
    }
    showAppSnackBar(context, message: l10n.recurringDeleted);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    return AppScaffold(
      title: vm.isEditing ? l10n.recurringEdit : l10n.recurringNew,
      body: SignalBuilder(
        builder: (context) {
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
                  onAction: () =>
                      context.go(AppRoutes.operationsTab(tab: 'recurring')),
                ),
              ],
            );
          }
          if (vm.state.value is ViewError) {
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: () => vm.load(kind: _kind),
            );
          }
          if (!_loaded) {
            return Center(child: AppSpinner(semanticLabel: l10n.commonLoading));
          }
          if (vm.isDeleted) return _deletedBody(l10n);
          if (vm.isAuto) return _autoBody(l10n);
          return _formBody(l10n);
        },
      ),
    );
  }

  Widget _deletedBody(AppLocalizations l10n) => AppListView(
    padding: const EdgeInsets.all(AppSpacing.md),
    children: [
      AppEmptyState(
        icon: Icons.delete_outline,
        title: l10n.recurringRuleDeletedTitle,
        message: l10n.recurringRuleDeletedMessage,
      ),
    ],
  );

  Widget _autoBody(AppLocalizations l10n) {
    final rule = widget.viewModel.rule.value!;
    return AppListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppFormSection(
          title: l10n.recurringTitle,
          children: [
            AppText(l10n.recurringReadOnlyInterest),
            if (rule.accountId != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.recurringOpenAccount,
                variant: AppButtonVariant.outlined,
                onPressed: () =>
                    context.push(AppRoutes.assetDetailsPath(rule.accountId!)),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _formBody(AppLocalizations l10n) {
    final vm = widget.viewModel;
    final currency = vm.currencyOf(_currencyCode);
    final presetProperty =
        vm.presetPropertyId != null && vm.presetTargetName.value != null;
    final presetAccount =
        vm.presetAccountId != null && vm.presetTargetName.value != null;
    final options = [
      for (final category in vm.categories.value)
        AppCategoryOption(
          id: category.id,
          name: category.name,
          colorKey: category.colorKey,
          archived: category.archivedAt != null,
        ),
    ];
    return AppListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppFormSection(
          title: vm.isEditing ? l10n.recurringEdit : l10n.recurringNew,
          errorText: _formError,
          children: [
            AppSegmentedControl<CashflowKind>(
              segments: [
                AppSegment(
                  value: CashflowKind.expense,
                  label: l10n.cashflowExpense,
                ),
                AppSegment(
                  value: CashflowKind.income,
                  label: l10n.cashflowIncome,
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) => _setKind(selection.single),
            ),
            AppAmountField(
              controller: _amount,
              label: l10n.cashflowAmountLabel,
              currencySuffix: _currencyCode,
              maxFractionDigits: currency.fractionDigits,
              errorText: _amountError,
              onChanged: (_) => setState(() => _amountError = null),
            ),
            AppCurrencySelect(
              label: l10n.cashflowCurrencyLabel,
              valueCode: _currencyCode,
              enabled: _accountId == null,
              disabledReason: l10n.cashflowCurrencyFromAccount,
              items: [
                for (final item in vm.currencies.value.values)
                  AppCurrencyOption(
                    code: item.code,
                    name: item.name,
                    fractionDigits: item.fractionDigits,
                    enabled: item.isEnabled,
                  ),
              ],
              onChanged: (code) => setState(() {
                _currencyCode = code;
                _amount.clear();
                _amountError = null;
              }),
            ),
            AppCategorySelect(
              label: l10n.cashflowCategoryLabel,
              valueId: _categoryId,
              items: options,
              errorText: _categoryError,
              onChanged: (id) => setState(() {
                _categoryId = id;
                _categoryError = null;
              }),
            ),
            if (options.isEmpty) AppText(l10n.cashflowNoCategories),
            if (presetProperty || presetAccount)
              AppText(
                '${presetProperty ? l10n.recurringTargetProperty : l10n.recurringTargetAccount}: '
                '${vm.presetTargetName.value}',
              )
            else ...[
              if (vm.accounts.value.isEmpty && vm.properties.value.isEmpty)
                AppText(l10n.recurringNoTargets),
              AppSelect<int>(
                label: l10n.recurringTargetAccount,
                value: _accountId ?? 0,
                searchable: true,
                items: [
                  AppSelectItem(value: 0, label: l10n.recurringNoTarget),
                  for (final account in vm.accounts.value)
                    AppSelectItem(
                      value: account.id,
                      label: account.name,
                      subtitle: account.currencyCode,
                    ),
                ],
                onChanged: (value) => _setAccount(value == 0 ? null : value),
              ),
              AppSelect<int>(
                label: l10n.recurringTargetProperty,
                value: _propertyId ?? 0,
                searchable: true,
                items: [
                  AppSelectItem(value: 0, label: l10n.recurringNoTarget),
                  for (final property in vm.properties.value)
                    AppSelectItem(value: property.id, label: property.name),
                ],
                onChanged: (value) => _setProperty(value == 0 ? null : value),
              ),
              AppText(
                l10n.recurringTargetHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (_accountId != null)
              AppSwitch(
                value: _affectsBalance,
                label: l10n.cashflowAffectsBalance,
                onChanged: (value) => setState(() => _affectsBalance = value),
              ),
            AppDatePickerField(
              label: l10n.recurringStartDate,
              valueText: const DateFormatter().format(_startDate),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              onChanged: (value) => setState(() {
                _startDate = LocalDate.fromDateTime(value);
                _dateError = null;
                if (_endDate != null && _endDate!.compareTo(_startDate) < 0) {
                  _endDate = null;
                  _dateError = l10n.recurringErrorDates;
                }
              }),
            ),
            AppDatePickerField(
              label: l10n.recurringEndDateOptional,
              valueText: _endDate == null
                  ? l10n.recurringEndNotSet
                  : const DateFormatter().format(_endDate!),
              firstDate: DateTime(
                _startDate.year,
                _startDate.month,
                _startDate.day,
              ),
              lastDate: DateTime(2100),
              errorText: _dateError,
              onChanged: (value) => setState(() {
                final picked = LocalDate.fromDateTime(value);
                if (picked.compareTo(_startDate) < 0) {
                  _dateError = l10n.recurringErrorDates;
                  return;
                }
                _endDate = picked;
                _dateError = null;
              }),
            ),
            if (_endDate != null)
              AppButton(
                label: l10n.recurringEndClear,
                variant: AppButtonVariant.text,
                onPressed: () => setState(() => _endDate = null),
              ),
            if (_currencyCode != 'RUB')
              AppText(
                l10n.recurringRateHint,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            AppTextField(
              label: l10n.transactionCommentLabel,
              controller: _comment,
            ),
            AppButton(
              label: l10n.commonSave,
              pending: vm.busy.value || _saving,
              onPressed: vm.busy.value || _saving ? null : _save,
            ),
            if (vm.isEditing) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.recurringDeleteAction,
                variant: AppButtonVariant.destructive,
                pending: vm.busy.value,
                onPressed: vm.busy.value ? null : _delete,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
