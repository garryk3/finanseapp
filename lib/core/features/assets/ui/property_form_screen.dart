import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/property_form_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_currency_select.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Форма квартиры: адрес, цена покупки и начальная стоимость (5.4).
class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key, required this.viewModel});

  final PropertyFormViewModel viewModel;

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _opening = TextEditingController();
  final _purchase = TextEditingController();
  String _currencyCode = 'RUB';
  String? _nameError;
  String? _amountError;
  String? _purchaseError;
  String? _formError;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load().then((_) {
      if (!mounted) return;
      final property = widget.viewModel.property.value;
      if (property != null) {
        final currency = _currencyOf(property.currencyCode);
        _name.text = property.name;
        _address.text = property.address ?? '';
        _opening.text = MoneyMath.toDecimal(
          property.openingValue,
          currency,
        ).toString();
        final purchase = property.purchasePrice;
        if (purchase != null) {
          _purchase.text = MoneyMath.toDecimal(purchase, currency).toString();
        }
        _currencyCode = property.currencyCode;
      }
      setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _opening.dispose();
    _purchase.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Currency _currencyOf(String code) =>
      widget.viewModel.currencies.value.firstWhere(
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
    if (widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final currency = _currencyOf(_currencyCode);
    final opening = parseOpeningAmount(_opening.text, currency);
    final purchase = _purchase.text.trim().isEmpty
        ? null
        : parseOpeningAmount(_purchase.text, currency);
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = l10n.propertyErrorName);
      return;
    }
    if (opening == null) {
      setState(() => _amountError = l10n.accountErrorAmount);
      return;
    }
    if (purchase == null && _purchase.text.trim().isNotEmpty) {
      setState(() => _purchaseError = l10n.accountErrorAmount);
      return;
    }
    final result = await widget.viewModel.save(
      name: _name.text,
      currencyCode: _currencyCode,
      openingValue: opening,
      address: _address.text,
      purchasePrice: purchase,
    );
    if (!mounted) return;
    if (result is Failure<int>) {
      setState(() {
        _formError = switch (result.error.fieldErrors.values.firstOrNull) {
          'validationNameRequired' => l10n.propertyErrorName,
          'validationAmountNegative' => l10n.accountErrorAmount,
          _ => l10n.errorStateMessage,
        };
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
      title: vm.isEditing ? l10n.propertyFormEdit : l10n.propertyFormNew,
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
          if (!_loaded) {
            return Center(child: AppSpinner(semanticLabel: l10n.commonLoading));
          }
          return AppListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppFormSection(
                title: l10n.propertySectionTitle,
                errorText: _formError,
                children: [
                  AppTextField(
                    label: l10n.propertyNameLabel,
                    controller: _name,
                    errorText: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  AppTextField(
                    label: l10n.propertyAddressLabel,
                    controller: _address,
                  ),
                  AppAmountField(
                    controller: _opening,
                    label: l10n.propertyValueLabel,
                    currencySuffix: _currencyCode,
                    maxFractionDigits: _currencyOf(_currencyCode)
                        .fractionDigits,
                    allowZero: true,
                    errorText: _amountError,
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                  AppAmountField(
                    controller: _purchase,
                    label: l10n.propertyPurchasePriceLabel,
                    currencySuffix: _currencyCode,
                    maxFractionDigits: _currencyOf(_currencyCode)
                        .fractionDigits,
                    allowZero: true,
                    errorText: _purchaseError,
                    onChanged: (_) => setState(() => _purchaseError = null),
                  ),
                  AppCurrencySelect(
                    label: l10n.propertyCurrencyLabel,
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
                          enabled: currency.isEnabled,
                        ),
                    ],
                    onChanged: (code) => setState(() {
                      _currencyCode = code;
                      _amountError = null;
                      _purchaseError = null;
                    }),
                  ),
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
