import 'package:decimal/decimal.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/domain/asset.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_form_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_category_select.dart';
import 'package:finanseapp/uikit/app_date_picker_field.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_switch.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Форма пополнения/снятия с классификацией (6.1).
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, required this.viewModel});

  final TransactionFormViewModel viewModel;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _amount = TextEditingController();
  final _rate = TextEditingController();
  final _comment = TextEditingController();
  int? _assetId;
  AssetTransactionKind _kind = AssetTransactionKind.deposit;
  LocalDate? _date;
  bool _classify = false;
  int? _categoryId;
  String? _assetError;
  String? _amountError;
  String? _rateError;
  String? _dateError;
  String? _categoryError;
  String? _formError;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load().then((_) {
      if (!mounted) return;
      setState(() {
        _assetId =
            widget.viewModel.initialAssetId ??
            widget.viewModel.assets.value.firstOrNull?.id;
        _kind = widget.viewModel.initialKind;
        _date = widget.viewModel.today;
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

  CashflowKind get _classificationKind => _kind == AssetTransactionKind.deposit
      ? CashflowKind.income
      : CashflowKind.expense;

  Future<void> _setClassify(bool value) async {
    setState(() {
      _classify = value;
      _categoryId = null;
      _categoryError = null;
    });
    if (value) await widget.viewModel.loadCategories(_classificationKind);
  }

  Future<void> _setKind(AssetTransactionKind kind) async {
    setState(() {
      _kind = kind;
      _categoryId = null;
      _categoryError = null;
    });
    if (_classify) await widget.viewModel.loadCategories(_classificationKind);
  }

  Future<void> _save() async {
    if (_saving || widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final asset = _assetId == null
        ? null
        : widget.viewModel.assetById(_assetId!);
    final currency = asset == null
        ? null
        : widget.viewModel.currencyOf(asset.currencyCode);
    final isRub = currency == null || currency.code == 'RUB';
    final amount = (asset == null || currency == null)
        ? null
        : parseOpeningAmount(_amount.text, currency);
    final assetError = asset == null ? l10n.transactionErrorAsset : null;
    final amountError = amount == null || amount.minorUnits <= 0
        ? l10n.transactionErrorAmount
        : null;
    final categoryError = _classify && _categoryId == null
        ? l10n.transactionErrorCategory
        : null;
    final rawRate = isRub ? '' : _rate.text.trim().replaceAll(',', '.');
    Decimal? manualRate;
    if (rawRate.isNotEmpty) {
      manualRate = Decimal.tryParse(rawRate);
      if (manualRate == null || manualRate <= Decimal.zero) {
        setState(() => _rateError = l10n.valuationErrorRate);
        return;
      }
    }
    if (assetError != null || amountError != null || categoryError != null) {
      setState(() {
        _assetError = assetError;
        _amountError = amountError;
        _categoryError = categoryError;
      });
      return;
    }
    setState(() {
      _assetError = null;
      _amountError = null;
      _rateError = null;
      _dateError = null;
      _categoryError = null;
      _formError = null;
      _saving = true;
    });
    final result = await widget.viewModel.save(
      assetId: _assetId!,
      kind: _kind,
      amount: Money(
        minorUnits: amount!.minorUnits,
        currencyCode: currency!.code,
      ),
      occurredOn: _date!,
      manualRate: manualRate,
      comment: _comment.text,
      categoryId: _classify ? _categoryId : null,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is Failure<int>) {
      final key = result.error.fieldErrors.values.isEmpty
          ? ''
          : result.error.fieldErrors.values.first;
      final message = switch (key) {
        'validationDateInFuture' => l10n.transactionErrorDate,
        'validationAmountPositive' => l10n.transactionErrorAmount,
        'validationClassificationKindMismatch' =>
          l10n.transactionErrorKindMismatch,
        'validationCategoryKindMismatch' => l10n.transactionErrorKindMismatch,
        'validationClassificationAccountOnly' =>
          l10n.transactionErrorKindMismatch,
        _ when result.error.code == DomainErrorCode.negativeBalance =>
          l10n.transactionErrorNegativeBalance,
        _ when result.error.code == DomainErrorCode.rateUnavailable =>
          l10n.valuationErrorRate,
        _ => l10n.errorStateMessage,
      };
      setState(() {
        switch (key) {
          case 'validationDateInFuture':
            _dateError = message;
          case 'validationAmountPositive':
          case 'validationAmountNegative':
            _amountError = message;
          case 'validationCategoryKindMismatch':
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
      title: l10n.transactionFormNew,
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
          final asset = _assetId == null ? null : vm.assetById(_assetId!);
          final currency = asset == null
              ? null
              : vm.currencyOf(asset.currencyCode);
          final isRub = currency == null || currency.code == 'RUB';
          final categoryOptions = [
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
                title: asset?.name ?? l10n.transactionFormNew,
                errorText: _formError,
                children: [
                  AppSelect<int>(
                    label: l10n.transactionAssetLabel,
                    value: _assetId,
                    items: [
                      for (final item in vm.assets.value)
                        AppSelectItem(
                          value: item.id,
                          label: item.name,
                          subtitle: item.currencyCode,
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _assetId = value;
                      _assetError = null;
                      _rate.clear();
                      _rateError = null;
                      final selected = vm.assetById(value);
                      if (selected?.kind != AssetKind.account) {
                        _classify = false;
                        _categoryId = null;
                        _categoryError = null;
                      }
                    }),
                    errorText: _assetError,
                  ),
                  if (vm.assets.value.isEmpty)
                    AppText(l10n.transactionNoAssets),
                  AppSegmentedControl<AssetTransactionKind>(
                    segments: [
                      AppSegment(
                        value: AssetTransactionKind.deposit,
                        label: l10n.transactionKindDeposit,
                      ),
                      AppSegment(
                        value: AssetTransactionKind.withdrawal,
                        label: l10n.transactionKindWithdrawal,
                      ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (selection) =>
                        _setKind(selection.single),
                  ),
                  AppAmountField(
                    controller: _amount,
                    label: l10n.transactionAmountLabel,
                    currencySuffix: currency?.code ?? 'RUB',
                    maxFractionDigits: currency?.fractionDigits ?? 2,
                    errorText: _amountError,
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                  AppDatePickerField(
                    label: l10n.transactionDateLabel,
                    valueText: const DateFormatter().format(_date!),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(
                      vm.today.year,
                      vm.today.month,
                      vm.today.day,
                    ),
                    errorText: _dateError,
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
                  AppTextField(
                    label: l10n.transactionCommentLabel,
                    controller: _comment,
                  ),
                  if (asset?.kind == AssetKind.account) ...[
                    AppSwitch(
                      value: _classify,
                      label: l10n.transactionClassifyLabel,
                      onChanged: _setClassify,
                    ),
                    if (_classify) ...[
                      AppCategorySelect(
                        label: l10n.transactionCategoryLabel,
                        valueId: _categoryId,
                        items: categoryOptions,
                        errorText: _categoryError,
                        onChanged: (id) => setState(() {
                          _categoryId = id;
                          _categoryError = null;
                        }),
                      ),
                      if (categoryOptions.isEmpty)
                        AppText(l10n.transactionNoCategories),
                    ],
                  ],
                  AppButton(
                    label: l10n.commonSave,
                    pending: vm.busy.value || _saving,
                    onPressed: vm.busy.value || _saving || asset == null
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
