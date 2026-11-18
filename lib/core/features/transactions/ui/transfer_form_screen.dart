import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/transactions/ui/transfer_form_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_date_picker_field.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_select.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Перевод между счетами (6.2).
class TransferFormScreen extends StatefulWidget {
  const TransferFormScreen({super.key, required this.viewModel});

  final TransferFormViewModel viewModel;

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  final _amount = TextEditingController();
  final _destination = TextEditingController();
  final _comment = TextEditingController();
  int? _fromId;
  int? _toId;
  LocalDate? _date;
  String? _fromError;
  String? _toError;
  String? _amountError;
  String? _destinationError;
  String? _formError;
  bool _loaded = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load().then((_) {
      if (!mounted) return;
      setState(() {
        final accounts = widget.viewModel.accounts.value;
        _fromId = widget.viewModel.initialFromId ?? accounts.firstOrNull?.id;
        _toId = accounts
            .where((account) => account.id != _fromId)
            .firstOrNull
            ?.id;
        _date = widget.viewModel.today;
        _loaded = true;
      });
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _destination.dispose();
    _comment.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final from = _fromId == null
        ? null
        : widget.viewModel.accountById(_fromId!);
    final to = _toId == null ? null : widget.viewModel.accountById(_toId!);
    final fromCurrency = from == null
        ? null
        : widget.viewModel.currencyOf(from.currencyCode);
    final toCurrency = to == null
        ? null
        : widget.viewModel.currencyOf(to.currencyCode);
    final amount = (fromCurrency == null)
        ? null
        : parseOpeningAmount(_amount.text, fromCurrency);
    final crossCurrency =
        from != null && to != null && from.currencyCode != to.currencyCode;
    final destination = crossCurrency
        ? (toCurrency == null
              ? null
              : parseOpeningAmount(_destination.text, toCurrency))
        : null;
    final fromError = from == null ? l10n.transferErrorFrom : null;
    final toError = to == null
        ? l10n.transferErrorTo
        : (from != null && from.id == to.id
              ? l10n.transferErrorSameAccount
              : null);
    final amountError = amount == null || amount.minorUnits <= 0
        ? l10n.transferErrorAmount
        : null;
    final destinationError =
        crossCurrency && (destination == null || destination.minorUnits <= 0)
        ? l10n.transferErrorAmount
        : null;
    if (fromError != null ||
        toError != null ||
        amountError != null ||
        destinationError != null) {
      setState(() {
        _fromError = fromError;
        _toError = toError;
        _amountError = amountError;
        _destinationError = destinationError;
      });
      return;
    }
    setState(() {
      _fromError = null;
      _toError = null;
      _amountError = null;
      _destinationError = null;
      _formError = null;
      _saving = true;
    });
    final result = await widget.viewModel.save(
      fromId: _fromId!,
      toId: _toId!,
      amount: amount!,
      destinationAmount: crossCurrency ? destination : null,
      occurredOn: _date!,
      comment: _comment.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result is Failure<int>) {
      final key = result.error.fieldErrors.values.isEmpty
          ? ''
          : result.error.fieldErrors.values.first;
      final message = switch (key) {
        'validationTransferSameAccount' => l10n.transferErrorSameAccount,
        'validationAmountPositive' => l10n.transferErrorAmount,
        'validationDateInFuture' => l10n.transactionErrorDate,
        _ when result.error.code == DomainErrorCode.negativeBalance =>
          l10n.transferErrorNegativeBalance,
        _ when result.error.code == DomainErrorCode.rateUnavailable =>
          l10n.valuationErrorRate,
        _ => l10n.errorStateMessage,
      };
      setState(() {
        switch (key) {
          case 'validationTransferSameAccount':
            _toError = message;
          case 'validationAmountPositive':
            _amountError = message;
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
      title: l10n.transferFormTitle,
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
          final from = _fromId == null ? null : vm.accountById(_fromId!);
          final to = _toId == null ? null : vm.accountById(_toId!);
          final fromCurrency = from == null
              ? null
              : vm.currencyOf(from.currencyCode);
          final toCurrency = to == null ? null : vm.currencyOf(to.currencyCode);
          final crossCurrency =
              from != null &&
              to != null &&
              from.currencyCode != to.currencyCode;
          return AppListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppFormSection(
                title: l10n.transferFormTitle,
                errorText: _formError,
                children: [
                  AppSelect<int>(
                    label: l10n.transferFromLabel,
                    value: _fromId,
                    items: [
                      for (final account in vm.accounts.value)
                        AppSelectItem(
                          value: account.id,
                          label: account.name,
                          subtitle: account.currencyCode,
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _fromId = value;
                      _fromError = null;
                      _toError = null;
                      _amountError = null;
                      _destinationError = null;
                      if (value == _toId) {
                        _toId = vm.accounts.value
                            .where((account) => account.id != value)
                            .firstOrNull
                            ?.id;
                      }
                    }),
                    errorText: _fromError,
                  ),
                  AppSelect<int>(
                    label: l10n.transferToLabel,
                    value: _toId,
                    items: [
                      for (final account in vm.accounts.value)
                        AppSelectItem(
                          value: account.id,
                          label: account.name,
                          subtitle: account.currencyCode,
                        ),
                    ],
                    onChanged: (value) => setState(() {
                      _toId = value;
                      _toError = null;
                      _destinationError = null;
                    }),
                    errorText: _toError,
                  ),
                  if (vm.accounts.value.length < 2)
                    AppText(l10n.transferNoAccounts),
                  AppAmountField(
                    controller: _amount,
                    label: l10n.transferAmountLabel,
                    currencySuffix: fromCurrency?.code ?? 'RUB',
                    maxFractionDigits: fromCurrency?.fractionDigits ?? 2,
                    errorText: _amountError,
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                  if (crossCurrency)
                    AppAmountField(
                      controller: _destination,
                      label: l10n.transferDestinationAmountLabel,
                      currencySuffix: toCurrency?.code ?? 'RUB',
                      maxFractionDigits: toCurrency?.fractionDigits ?? 2,
                      errorText: _destinationError,
                      onChanged: (_) =>
                          setState(() => _destinationError = null),
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
                    onChanged: (value) =>
                        setState(() => _date = LocalDate.fromDateTime(value)),
                  ),
                  AppTextField(
                    label: l10n.transferCommentLabel,
                    controller: _comment,
                  ),
                  AppButton(
                    label: l10n.commonSave,
                    pending: vm.busy.value || _saving,
                    onPressed:
                        vm.busy.value || _saving || vm.accounts.value.length < 2
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
