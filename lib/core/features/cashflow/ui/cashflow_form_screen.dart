import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_category_select.dart';
import 'package:finanseapp/uikit/app_currency_select.dart';
import 'package:finanseapp/uikit/app_date_picker_field.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_switch.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Форма дохода/расхода без влияния на баланс (7.1).
class CashflowFormScreen extends StatefulWidget {
  const CashflowFormScreen({
    super.key,
    required this.viewModel,
    this.propertyId,
  });

  final CashflowFormViewModel viewModel;
  final int? propertyId;

  @override
  State<CashflowFormScreen> createState() => _CashflowFormScreenState();
}

class _CashflowFormScreenState extends State<CashflowFormScreen> {
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _comment = TextEditingController();
  CashflowKind _kind = CashflowKind.expense;
  int? _categoryId;
  int? _accountId;
  bool _affectsBalance = false;
  String _currencyCode = 'RUB';
  LocalDate? _date;
  String? _amountError;
  String? _categoryError;
  String? _rateError;
  String? _accountError;
  String? _formError;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _kind = widget.viewModel.initialKind;
    widget.viewModel.load(kind: _kind).then((_) {
      if (!mounted) return;
      final entry = widget.viewModel.entry.value;
      setState(() {
        _date = widget.viewModel.today;
        _kind = widget.viewModel.initialKind;
        if (entry != null) {
          _kind = entry.kind;
          _categoryId = entry.categoryId;
          _accountId = entry.accountId;
          _affectsBalance = entry.affectsBalance;
          _currencyCode = entry.amount.currencyCode;
          _amount.text = MoneyMath.toDecimal(
            entry.amount,
            widget.viewModel.currencyOf(entry.amount.currencyCode),
          ).toString();
          _date = entry.occurredOn;
          _comment.text = entry.comment ?? '';
        }
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _comment.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _setKind(CashflowKind kind) async {
    setState(() {
      _kind = kind;
      _categoryId = null;
      _categoryError = null;
    });
    await widget.viewModel.loadCategories(kind);
  }

  Future<void> _save() async {
    if (_saving || widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final currency = widget.viewModel.currencyOf(_currencyCode);
    final amount = parseOpeningAmount(_amount.text, currency);
    final amountError = amount == null || amount.minorUnits <= 0
        ? l10n.cashflowErrorAmount
        : null;
    final categoryError = _categoryId == null
        ? l10n.cashflowErrorCategory
        : null;
    final accountError = _affectsBalance && _accountId == null
        ? l10n.cashflowErrorAccount
        : null;
    final rawRate = widget.viewModel.isEditing && _currencyCode == 'RUB'
        ? ''
        : _rate.text.trim().replaceAll(',', '.');
    Decimal? manualRate;
    if (_currencyCode != 'RUB' && rawRate.isNotEmpty) {
      manualRate = Decimal.tryParse(rawRate);
      if (manualRate == null || manualRate <= Decimal.zero) {
        setState(() => _rateError = l10n.valuationErrorRate);
        return;
      }
    }
    if (amountError != null || categoryError != null || accountError != null) {
      setState(() {
        _amountError = amountError;
        _categoryError = categoryError;
        _accountError = accountError;
      });
      return;
    }
    setState(() {
      _amountError = null;
      _categoryError = null;
      _accountError = null;
      _rateError = null;
      _formError = null;
      _saving = true;
    });
    final result = await widget.viewModel.save(
      kind: _kind,
      categoryId: _categoryId!,
      amount: Money(
        minorUnits: amount!.minorUnits,
        currencyCode: _currencyCode,
      ),
      occurredOn: _date!,
      manualRate: manualRate,
      comment: _comment.text,
      propertyId: widget.propertyId,
      accountId: _accountId,
      affectsBalance: _affectsBalance,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is Failure<int>) {
      final key = result.error.fieldErrors.values.isEmpty
          ? ''
          : result.error.fieldErrors.values.first;
      final message = switch (key) {
        'validationAmountPositive' => l10n.cashflowErrorAmount,
        'validationCategoryKindMismatch' => l10n.cashflowErrorKindMismatch,
        'validationCategoryArchived' => l10n.cashflowErrorCategoryArchived,
        'validationDateInFuture' => l10n.transactionErrorDate,
        _ when result.error.code == DomainErrorCode.rateUnavailable =>
          l10n.valuationErrorRate,
        _ => l10n.errorStateMessage,
      };
      setState(() {
        switch (key) {
          case 'validationAmountPositive':
            _amountError = message;
          case 'validationCategoryKindMismatch':
          case 'validationCategoryArchived':
            _categoryError = message;
          default:
            _formError = message;
        }
      });
      return;
    }
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    return AppScaffold(
      title: vm.isEditing ? l10n.cashflowFormEdit : l10n.cashflowFormNew,
      body: SignalBuilder(
        builder: (context) {
          if (vm.state.value is ViewError) {
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: vm.load,
            );
          }
          if (!_loaded || _date == null) {
            return Center(child: AppSpinner(semanticLabel: l10n.commonLoading));
          }
          final currency = vm.currencyOf(_currencyCode);
          final isRub = currency.code == 'RUB';
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
                title: vm.isEditing
                    ? l10n.cashflowFormEdit
                    : l10n.cashflowFormNew,
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
                    onSelectionChanged: (selection) =>
                        _setKind(selection.single),
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
                      _rate.clear();
                      _rateError = null;
                    }),
                  ),
                  AppSelect<int>(
                    label: l10n.cashflowAccountLabel,
                    value: _accountId,
                    items: [
                      for (final account in vm.accounts.value)
                        AppSelectItem(
                          value: account.id,
                          label: account.name,
                          subtitle: account.currencyCode,
                        ),
                    ],
                    errorText: _accountError,
                    onChanged: (value) => setState(() {
                      _accountId = value;
                      _accountError = null;
                      if (_affectsBalance) {
                        final account = vm.accounts.value.firstWhere(
                          (item) => item.id == value,
                        );
                        _currencyCode = account.currencyCode;
                      }
                    }),
                  ),
                  AppSwitch(
                    value: _affectsBalance,
                    label: l10n.cashflowAffectsBalance,
                    onChanged: (value) => setState(() {
                      _affectsBalance = value;
                      _accountError = null;
                      if (value && _accountId != null) {
                        final account = vm.accounts.value.firstWhere(
                          (item) => item.id == _accountId,
                        );
                        _currencyCode = account.currencyCode;
                      }
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
                  AppDatePickerField(
                    label: l10n.transactionDateLabel,
                    valueText: const DateFormatter().format(_date!),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(
                      vm.today.year,
                      vm.today.month,
                      vm.today.day,
                    ),
                    onChanged: (value) =>
                        setState(() => _date = LocalDate.fromDateTime(value)),
                  ),
                  if (!isRub)
                    AppTextField(
                      label: l10n.valuationRateLabel,
                      controller: _rate,
                      errorText: _rateError,
                      helperText: l10n.valuationRateOptional,
                      onChanged: (_) => setState(() => _rateError = null),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
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
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
