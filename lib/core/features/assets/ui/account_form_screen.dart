import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_currency_select.dart';
import 'package:finanseapp/uikit/app_date_picker_field.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Создание и редактирование счёта (5.1).
class AccountFormScreen extends StatefulWidget {
  const AccountFormScreen({super.key, required this.viewModel});

  final AccountFormViewModel viewModel;

  @override
  State<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends State<AccountFormScreen> {
  late AccountFormViewModel _viewModel = widget.viewModel;
  final _name = TextEditingController();
  final _opening = TextEditingController();
  final _rate = TextEditingController(text: '0');
  int? _bankId;
  String _currencyCode = 'RUB';
  LocalDate _startDate = LocalDate.fromDateTime(DateTime.now());
  bool _hasEndDate = false;
  LocalDate? _endDate;
  String? _error;
  bool _loaded = false;
  int _loadSeq = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant AccountFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Роутер создаёт ViewModel в builder: после возврата с другого экрана
    // экземпляр может быть новым.
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel;
      _loaded = false;
      _load();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    _rate.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final seq = ++_loadSeq;
    await _viewModel.load();
    if (!mounted || seq != _loadSeq) return;
    final account = _viewModel.account.value;
    if (account != null) {
      _name.text = account.name;
      _opening.text = MoneyMath.toDecimal(
        account.openingValue,
        _currencyOf(account.currencyCode),
      ).toString();
      _rate.text = account.annualRate.toString();
      _currencyCode = account.currencyCode;
      _startDate = account.startDate;
      _endDate = account.endDate;
      _hasEndDate = account.endDate != null;
    }
    setState(() {
      _bankId = _pickBank(account?.bankId ?? _bankId);
      _loaded = true;
    });
  }

  /// Держит выбор в пределах актуального списка банков.
  int? _pickBank(int? current) {
    final banks = _viewModel.banks.value;
    if (banks.isEmpty) return null;
    if (current != null && banks.any((item) => item.id == current)) {
      return current;
    }
    return banks.first.id;
  }

  Currency _currencyOf(String code) => _viewModel.currencies.value.firstWhere(
    (currency) => currency.code == code,
    orElse: () => Currency(
      code: code,
      name: code,
      fractionDigits: 2,
      isPreset: true,
      isEnabled: true,
    ),
  );

  Future<void> _save() async {
    if (_viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final currency = _viewModel.currencies.value.firstWhere(
      (item) => item.code == _currencyCode,
      orElse: () => Currency(
        code: _currencyCode,
        name: _currencyCode,
        fractionDigits: 2,
        isPreset: true,
        isEnabled: true,
      ),
    );
    // Пустое поле означает ноль: подсказка «0» не должна превращаться
    // в ошибку «введите сумму».
    final openingText = _opening.text.trim();
    final opening = openingText.isEmpty
        ? Money(minorUnits: 0, currencyCode: currency.code)
        : parseOpeningAmount(openingText, currency);
    final rateText = _rate.text.trim();
    final rate = rateText.isEmpty
        ? Decimal.zero
        : Decimal.tryParse(rateText.replaceAll(',', '.'));
    if (_name.text.trim().isEmpty) {
      setState(() => _error = l10n.accountErrorName);
      return;
    }
    if (opening == null) {
      setState(() => _error = l10n.accountErrorAmount);
      return;
    }
    if (_bankId == null) {
      setState(() => _error = l10n.accountErrorBank);
      return;
    }
    if (rate == null) {
      setState(() => _error = l10n.accountErrorRate);
      return;
    }
    final result = await _viewModel.save(
      name: _name.text,
      bankId: _bankId!,
      currencyCode: _currencyCode,
      openingValue: opening,
      annualRate: rate,
      startDate: _startDate,
      endDate: _hasEndDate ? (_endDate ?? _startDate) : null,
    );
    if (!mounted) return;
    if (result is Failure<int>) {
      final key = result.error.fieldErrors.values.isEmpty
          ? ''
          : result.error.fieldErrors.values.first;
      setState(() {
        _error = switch (key) {
          'validationRateRange' => l10n.accountErrorRate,
          'validationDateRangeInvalid' => l10n.accountErrorDates,
          'validationCurrencyLocked' => l10n.accountErrorCurrencyLocked,
          'validationNameRequired' => l10n.accountErrorName,
          _ => l10n.errorStateMessage,
        };
      });
      return;
    }
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    return AppScaffold(
      title: vm.isEditing ? l10n.accountFormEdit : l10n.accountFormNew,
      body: SignalBuilder(
        builder: (context) {
          if (vm.state.value is ViewError) {
            return AppErrorState(
              title: l10n.errorStateTitle,
              message: l10n.errorStateMessage,
              errorLabel: l10n.errorLabel,
              retryLabel: l10n.retry,
              onRetry: () {
                setState(() => _loaded = false);
                _load();
              },
            );
          }
          if (!_loaded) {
            return Center(child: AppSpinner(semanticLabel: l10n.commonLoading));
          }
          return AppListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppFormSection(
                title: l10n.accountNameLabel,
                children: [
                  AppTextField(label: l10n.accountNameLabel, controller: _name),
                  const SizedBox(height: AppSpacing.md),
                  AppAmountField(
                    controller: _opening,
                    label: l10n.accountOpeningLabel,
                    currencySuffix: _currencyCode,
                    allowZero: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.accountRateLabel,
                    controller: _rate,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppSelect<int>(
                    label: l10n.accountBankLabel,
                    value: _bankId,
                    items: [
                      for (final bank in vm.banks.value)
                        AppSelectItem(value: bank.id, label: bank.name),
                    ],
                    onChanged: (value) => setState(() => _bankId = value),
                    errorText: vm.banks.value.isEmpty
                        ? l10n.accountNoBanks
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppCurrencySelect(
                    label: l10n.accountCurrencyLabel,
                    valueCode: _currencyCode,
                    enabled:
                        !(vm.isEditing &&
                            (vm.referenceCounts.value?.isUsed ?? false)),
                    disabledReason: l10n.accountCurrencyLocked,
                    items: [
                      for (final currency in vm.currencies.value)
                        AppCurrencyOption(
                          code: currency.code,
                          name: currency.name,
                          fractionDigits: currency.fractionDigits,
                        ),
                    ],
                    onChanged: (code) => setState(() => _currencyCode = code),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppDatePickerField(
                    label: l10n.accountStartDate,
                    valueText: _startDate.toIsoString(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    onChanged: (value) => setState(
                      () => _startDate = LocalDate.fromDateTime(value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_hasEndDate)
                    AppDatePickerField(
                      label: l10n.accountEndDate,
                      valueText: (_endDate ?? _startDate).toIsoString(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onChanged: (value) => setState(
                        () => _endDate = LocalDate.fromDateTime(value),
                      ),
                    ),
                  AppButton(
                    label: _hasEndDate
                        ? l10n.accountRemoveEndDate
                        : l10n.accountAddEndDate,
                    variant: AppButtonVariant.text,
                    onPressed: () => setState(() {
                      if (_hasEndDate) {
                        _hasEndDate = false;
                        _endDate = null;
                      } else {
                        _hasEndDate = true;
                        _endDate = _startDate;
                      }
                    }),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    AppText(_error!),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.commonSave,
                    pending: vm.busy.value,
                    onPressed: vm.busy.value || vm.banks.value.isEmpty
                        ? null
                        : _save,
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
