import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/valuation_form_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_currency_select.dart';
import 'package:finanseapp/uikit/app_date_picker_field.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Форма абсолютной оценки инвестиции/квартиры (5.2).
class ValuationFormScreen extends StatefulWidget {
  const ValuationFormScreen({super.key, required this.viewModel});

  final ValuationFormViewModel viewModel;

  @override
  State<ValuationFormScreen> createState() => _ValuationFormScreenState();
}

class _ValuationFormScreenState extends State<ValuationFormScreen> {
  final _value = TextEditingController();
  final _rate = TextEditingController();
  String? _currencyCode;
  LocalDate? _date;
  String? _valueError;
  String? _dateError;
  String? _rateError;
  String? _formError;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load().then((_) {
      if (!mounted) return;
      setState(() {
        _currencyCode = widget.viewModel.asset.value?.currencyCode;
        _date = widget.viewModel.today;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _value.dispose();
    _rate.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final asset = widget.viewModel.asset.value;
    final date = _date;
    if (asset == null || date == null) return;
    final selectedCode = asset.kind == AssetKind.investment
        ? _currencyCode ?? asset.currencyCode
        : asset.currencyCode;
    final currency = widget.viewModel.currencyOf(selectedCode);
    final value = parseOpeningAmount(_value.text, currency);
    if (value == null) {
      setState(() => _valueError = l10n.valuationErrorValue);
      return;
    }
    final rawRate = _rate.text.trim().replaceAll(',', '.');
    Decimal? manualRate;
    if (rawRate.isNotEmpty) {
      manualRate = Decimal.tryParse(rawRate);
      if (manualRate == null || manualRate <= Decimal.zero) {
        setState(() => _rateError = l10n.valuationErrorRate);
        return;
      }
    }
    setState(() {
      _valueError = null;
      _dateError = null;
      _rateError = null;
      _formError = null;
    });
    final result = await widget.viewModel.save(
      value: Money(minorUnits: value.minorUnits, currencyCode: currency.code),
      effectiveOn: date,
      manualRate: manualRate,
    );
    if (!mounted) return;
    if (result is Failure<void>) {
      final key = result.error.fieldErrors.values.isEmpty
          ? ''
          : result.error.fieldErrors.values.first;
      final message = switch (key) {
        'validationDateInFuture' => l10n.valuationErrorDate,
        'validationAmountNegative' => l10n.valuationErrorValue,
        'validationRateImmutable' => l10n.rateErrorImmutable,
        _ =>
          result.error.code == DomainErrorCode.rateUnavailable
              ? l10n.valuationErrorRate
              : l10n.errorStateMessage,
      };
      setState(() {
        switch (key) {
          case 'validationDateInFuture':
            _dateError = message;
          case 'validationAmountNegative':
            _valueError = message;
          case 'validationRateImmutable':
            _rateError = message;
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
      title: l10n.valuationTitle,
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
          final asset = vm.asset.value;
          final isInvestment = asset?.kind == AssetKind.investment;
          final selectedCode = isInvestment
              ? _currencyCode ?? asset?.currencyCode
              : asset?.currencyCode;
          final currency = selectedCode == null
              ? vm.currency.value
              : vm.currencyOf(selectedCode);
          final isRub = currency == null || currency.code == 'RUB';
          return AppListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppFormSection(
                title: vm.asset.value?.name ?? l10n.valuationTitle,
                errorText: _formError,
                children: [
                  if (asset?.kind == AssetKind.investment)
                    AppCurrencySelect(
                      label: l10n.valuationCurrencyLabel,
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
                  AppAmountField(
                    controller: _value,
                    label: l10n.valuationValueLabel,
                    currencySuffix: currency?.code ?? 'RUB',
                    allowZero: true,
                    maxFractionDigits: currency?.fractionDigits ?? 2,
                    errorText: _valueError,
                    onChanged: (_) => setState(() => _valueError = null),
                  ),
                  AppDatePickerField(
                    label: l10n.valuationDateLabel,
                    valueText: const DateFormatter().format(_date!),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(
                      vm.today.year,
                      vm.today.month,
                      vm.today.day,
                    ),
                    errorText: _dateError,
                    helperText: l10n.investmentValuationHint,
                    onChanged: (value) => setState(() {
                      _date = LocalDate.fromDateTime(value);
                      _dateError = null;
                    }),
                  ),
                  if (!isRub) ...[
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
                  ],
                  AppButton(
                    label: l10n.commonSave,
                    pending: vm.busy.value,
                    onPressed: vm.busy.value ? null : _save,
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
