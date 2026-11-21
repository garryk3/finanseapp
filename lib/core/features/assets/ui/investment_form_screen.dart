import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/investment_form_view_model.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_currency_select.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Создание и редактирование инвестиции (5.2).
class InvestmentFormScreen extends StatefulWidget {
  const InvestmentFormScreen({super.key, required this.viewModel});

  final InvestmentFormViewModel viewModel;

  @override
  State<InvestmentFormScreen> createState() => _InvestmentFormScreenState();
}

class _InvestmentFormScreenState extends State<InvestmentFormScreen> {
  late InvestmentFormViewModel _viewModel = widget.viewModel;
  final _name = TextEditingController();
  final _opening = TextEditingController();
  int? _brokerId;
  String _currencyCode = 'RUB';
  String? _nameError;
  String? _amountError;
  String? _brokerError;
  String? _formError;
  bool _loaded = false;
  int _loadSeq = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant InvestmentFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Роутер создаёт ViewModel в builder, поэтому после push/pop экран может
    // получить новый экземпляр — старый освобождаем и грузим актуальный.
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
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final seq = ++_loadSeq;
    await _viewModel.load();
    if (!mounted || seq != _loadSeq) return;
    final investment = _viewModel.investment.value;
    if (investment != null) {
      _name.text = investment.name;
      _opening.text = MoneyMath.toDecimal(
        investment.openingValue,
        _currencyOf(investment.currencyCode),
      ).toString();
      _currencyCode = investment.currencyCode;
    }
    setState(() {
      _brokerId = _pickBroker(investment?.brokerId ?? _brokerId);
      _loaded = true;
    });
  }

  /// Держит выбор в пределах актуального списка брокеров.
  int? _pickBroker(int? current) {
    final brokers = _viewModel.brokers.value;
    if (brokers.isEmpty) return null;
    if (current != null && brokers.any((item) => item.id == current)) {
      return current;
    }
    return brokers.first.id;
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
    final opening = parseOpeningAmount(
      _opening.text,
      _currencyOf(_currencyCode),
    );
    final nameError = _name.text.trim().isEmpty
        ? l10n.investmentErrorName
        : null;
    final amountError = opening == null ? l10n.accountErrorAmount : null;
    final brokerError = _brokerId == null ? l10n.investmentErrorBroker : null;
    if (nameError != null || amountError != null || brokerError != null) {
      setState(() {
        _nameError = nameError;
        _amountError = amountError;
        _brokerError = brokerError;
      });
      return;
    }
    setState(() {
      _nameError = null;
      _amountError = null;
      _brokerError = null;
      _formError = null;
    });
    final result = await _viewModel.save(
      name: _name.text,
      brokerId: _brokerId!,
      currencyCode: _currencyCode,
      openingValue: opening!,
    );
    if (!mounted) return;
    if (result is Failure<int>) {
      final key = result.error.fieldErrors.values.isEmpty
          ? ''
          : result.error.fieldErrors.values.first;
      final message = switch (key) {
        'validationNameRequired' => l10n.investmentErrorName,
        'validationAmountNegative' => l10n.accountErrorAmount,
        'validationCurrencyLocked' => l10n.accountErrorCurrencyLocked,
        _ => l10n.errorStateMessage,
      };
      setState(() {
        _formError = message;
        _nameError = key == 'validationNameRequired' ? message : null;
        _amountError = key == 'validationAmountNegative' ? message : null;
      });
      return;
    }
    final navigator = Navigator.maybeOf(context);
    if (navigator?.canPop() ?? false) navigator!.pop();
  }

  Future<void> _openBrokers() async {
    await context.push(AppRoutes.subgroupsPath('broker'));
    if (!mounted) return;
    // Перечитываем снимок справочника: если роутер уже подменил ViewModel,
    // данные загрузит didUpdateWidget, повторный вызов безвреден.
    setState(() => _loaded = false);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = widget.viewModel;
    return AppScaffold(
      title: vm.isEditing ? l10n.investmentFormEdit : l10n.investmentFormNew,
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
          final currency = _currencyOf(_currencyCode);
          final noBrokers = vm.brokers.value.isEmpty;
          return AppListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppFormSection(
                title: l10n.investmentSectionTitle,
                errorText: _formError,
                children: [
                  AppTextField(
                    label: l10n.investmentNameLabel,
                    controller: _name,
                    errorText: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  AppAmountField(
                    controller: _opening,
                    label: l10n.accountOpeningLabel,
                    currencySuffix: _currencyCode,
                    allowZero: true,
                    maxFractionDigits: currency.fractionDigits,
                    errorText: _amountError,
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                  AppSelect<int>(
                    label: l10n.investmentBrokerLabel,
                    value: _brokerId,
                    items: [
                      for (final broker in vm.brokers.value)
                        AppSelectItem(value: broker.id, label: broker.name),
                    ],
                    onChanged: (value) => setState(() {
                      _brokerId = value;
                      _brokerError = null;
                    }),
                    errorText: _brokerError,
                  ),
                  if (noBrokers) ...[
                    AppText(l10n.investmentNoBrokers),
                    AppButton(
                      label: l10n.brokerAddAction,
                      variant: AppButtonVariant.text,
                      onPressed: _openBrokers,
                    ),
                  ],
                  AppCurrencySelect(
                    label: l10n.investmentCurrencyLabel,
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
                  AppButton(
                    label: l10n.commonSave,
                    pending: vm.busy.value,
                    onPressed: vm.busy.value || noBrokers ? null : _save,
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
