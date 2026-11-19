import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/domain/common/money_math.dart';
import 'package:finanseapp/core/domain/common/result.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/goals/domain/financial_goal.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_amount_field.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_checkbox.dart';
import 'package:finanseapp/uikit/app_currency_select.dart';
import 'package:finanseapp/uikit/app_date_picker_field.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_form_section.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_segmented_control.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_switch.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/uikit/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Форма финансовой цели с multi-select активов (8.1).
class GoalFormScreen extends StatefulWidget {
  const GoalFormScreen({super.key, required this.viewModel});

  final GoalFormViewModel viewModel;

  @override
  State<GoalFormScreen> createState() => _GoalFormScreenState();
}

class _GoalFormScreenState extends State<GoalFormScreen> {
  final _name = TextEditingController();
  final _target = TextEditingController();
  GoalCategory _category = GoalCategory.accounts;
  String _currencyCode = 'RUB';
  Set<int> _assetIds = {};
  LocalDate _targetDate = LocalDate.fromDateTime(DateTime.now());
  bool _hasDate = false;
  String? _nameError;
  String? _amountError;
  String? _assetsError;
  String? _formError;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.load().then((_) {
      if (!mounted) return;
      final goal = widget.viewModel.goal.value;
      if (goal != null) {
        _name.text = goal.name;
        _category = goal.category;
        _currencyCode = goal.targetAmount.currencyCode;
        _target.text = MoneyMath.toDecimal(
          goal.targetAmount,
          widget.viewModel.currencyOf(goal.targetAmount.currencyCode),
        ).toString();
        _assetIds = {...goal.assetIds};
        _targetDate = goal.targetDate ?? _targetDate;
        _hasDate = goal.targetDate != null;
      }
      setState(() => _loaded = true);
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _target.dispose();
    widget.viewModel.dispose();
    super.dispose();
  }

  Currency _currencyOf(String code) => widget.viewModel.currencyOf(code);

  void _setCategory(GoalCategory category) {
    final eligible = {
      for (final asset in widget.viewModel.eligibleAssets(category)) asset.id,
    };
    setState(() {
      _category = category;
      _assetIds = _assetIds.intersection(eligible);
      _assetsError = null;
    });
  }

  Future<void> _save() async {
    if (widget.viewModel.busy.value) return;
    final l10n = AppLocalizations.of(context);
    final amount = parseOpeningAmount(_target.text, _currencyOf(_currencyCode));
    final nameError = _name.text.trim().isEmpty ? l10n.goalErrorName : null;
    final amountError = amount == null || amount.minorUnits <= 0
        ? l10n.goalErrorAmount
        : null;
    final assetsError = _assetIds.isEmpty ? l10n.goalErrorAssets : null;
    if (nameError != null || amountError != null || assetsError != null) {
      setState(() {
        _nameError = nameError;
        _amountError = amountError;
        _assetsError = assetsError;
      });
      return;
    }
    setState(() {
      _nameError = null;
      _amountError = null;
      _assetsError = null;
      _formError = null;
    });
    final result = await widget.viewModel.save(
      name: _name.text,
      category: _category,
      targetAmount: Money(
        minorUnits: amount!.minorUnits,
        currencyCode: _currencyCode,
      ),
      assetIds: _assetIds,
      targetDate: _hasDate ? _targetDate : null,
    );
    if (!mounted) return;
    if (result is Failure<int>) {
      setState(() {
        _formError = switch (result.error.fieldErrors.values.firstOrNull) {
          'validationNameRequired' => l10n.goalErrorName,
          'validationAmountPositive' => l10n.goalErrorAmount,
          'validationGoalAssetsRequired' => l10n.goalErrorAssets,
          'validationGoalAssetKind' => l10n.goalErrorAssets,
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
      title: vm.isEditing ? l10n.goalFormEdit : l10n.goalFormNew,
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
          final eligible = vm.eligibleAssets(_category);
          return AppListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppFormSection(
                title: l10n.goalFormNew,
                errorText: _formError,
                children: [
                  AppTextField(
                    label: l10n.goalNameLabel,
                    controller: _name,
                    errorText: _nameError,
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  AppSegmentedControl<GoalCategory>(
                    segments: [
                      AppSegment(
                        value: GoalCategory.accounts,
                        label: l10n.goalCategoryAccounts,
                      ),
                      AppSegment(
                        value: GoalCategory.investments,
                        label: l10n.goalCategoryInvestments,
                      ),
                    ],
                    selected: {_category},
                    onSelectionChanged: (selection) =>
                        _setCategory(selection.single),
                  ),
                  AppAmountField(
                    controller: _target,
                    label: l10n.goalTargetAmountLabel,
                    currencySuffix: _currencyCode,
                    maxFractionDigits: _currencyOf(_currencyCode)
                        .fractionDigits,
                    errorText: _amountError,
                    onChanged: (_) => setState(() => _amountError = null),
                  ),
                  AppCurrencySelect(
                    label: l10n.accountCurrencyLabel,
                    valueCode: _currencyCode,
                    items: [
                      for (final currency in vm.currencies.value.values)
                        AppCurrencyOption(
                          code: currency.code,
                          name: currency.name,
                          fractionDigits: currency.fractionDigits,
                          enabled: currency.isEnabled,
                        ),
                    ],
                    onChanged: (code) => setState(() => _currencyCode = code),
                  ),
                  AppSwitch(
                    value: _hasDate,
                    label: l10n.goalTargetDateLabel,
                    onChanged: (value) => setState(() => _hasDate = value),
                  ),
                  if (_hasDate)
                    AppDatePickerField(
                      label: l10n.goalTargetDateLabel,
                      valueText: const DateFormatter().format(_targetDate),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onChanged: (value) => setState(
                        () => _targetDate = LocalDate.fromDateTime(value),
                      ),
                    ),
                  AppText(l10n.goalAssetsLabel),
                  if (eligible.isEmpty) AppText(l10n.goalNoAssets),
                  for (final asset in eligible)
                    AppCheckbox(
                      value: _assetIds.contains(asset.id),
                      label: asset.archivedAt == null
                          ? asset.name
                          : '${asset.name} · ${l10n.accountArchivedBadge}',
                      onChanged: (value) => setState(() {
                        if (value == true) {
                          _assetIds.add(asset.id);
                        } else {
                          _assetIds.remove(asset.id);
                        }
                        _assetsError = null;
                      }),
                    ),
                  if (_assetsError != null) AppText(_assetsError!),
                  AppButton(
                    label: l10n.commonSave,
                    pending: vm.busy.value,
                    onPressed: vm.busy.value || eligible.isEmpty ? null : _save,
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
