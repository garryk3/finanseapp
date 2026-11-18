import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
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

  @override
  void initState() {
    super.initState();
    widget.viewModel.load().then((_) {
      if (!mounted) return;
      final account = widget.viewModel.account.value;
      if (account != null) {
        _name.text = account.name;
        _opening.text = account.openingValue.minorUnits.toString();
        _rate.text = account.annualRate.toString();
        _bankId = account.bankId;
        _currencyCode = account.currencyCode;
        _startDate = account.startDate;
        _endDate = account.endDate;
        _hasEndDate = account.endDate != null;
      }
      setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    _rate.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final opening = int.tryParse(_opening.text.trim());
    final rate = Decimal.tryParse(_rate.text.trim().replaceAll(',', '.'));
    if (_name.text.trim().isEmpty || opening == null || rate == null) {
      setState(() => _error = l10n.accountErrorName);
      return;
    }
    final result = await widget.viewModel.save(
      name: _name.text,
      bankId: _bankId!,
      currencyCode: _currencyCode,
      openingValue: Money(minorUnits: opening, currencyCode: _currencyCode),
      annualRate: rate,
      startDate: _startDate,
      endDate: _hasEndDate ? _endDate : null,
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
            return AppText(l10n.errorStateMessage);
          }
          if (!_loaded) {
            return AppText(l10n.commonLoading);
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
                    label: l10n.accountFormNew,
                    valueCode: _currencyCode,
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
                  AppText(l10n.accountEndDate),
                  AppButton(
                    label: _hasEndDate
                        ? (_endDate?.toIsoString() ?? l10n.accountEndDate)
                        : l10n.accountEndDate,
                    variant: AppButtonVariant.text,
                    onPressed: _hasEndDate
                        ? null
                        : () => setState(() => _hasEndDate = true),
                  ),
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
