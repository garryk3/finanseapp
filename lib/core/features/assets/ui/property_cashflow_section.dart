import 'dart:async';

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:decimal/decimal.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/date_range.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/domain/common/money.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_entry.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_filter.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/logic/property_yield_calculator.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_calculator.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_cashflow_summary.dart';
import 'package:finanseapp/uikit/app_filter_bar.dart';
import 'package:finanseapp/uikit/app_filter_chip.dart';
import 'package:finanseapp/uikit/app_metric.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

/// Денежный поток квартиры за период + создание дохода/расхода (5.4).
class PropertyCashflowSection extends StatefulWidget {
  const PropertyCashflowSection({
    super.key,
    required this.repository,
    required this.assetRepository,
    required this.propertyId,
    required this.currentValue,
    required this.currencyCode,
    required this.today,
    this.readOnly = false,
  });

  final CashflowRepository repository;
  final AssetRepository assetRepository;
  final int propertyId;
  final Money currentValue;
  final String currencyCode;
  final LocalDate today;
  final bool readOnly;

  @override
  State<PropertyCashflowSection> createState() =>
      _PropertyCashflowSectionState();
}

enum _Period { month, year, all }

class _PropertyCashflowSectionState extends State<PropertyCashflowSection> {
  _Period _period = _Period.month;
  List<CashflowEntry> _entries = const [];
  StreamSubscription<List<CashflowEntry>>? _subscription;
  bool _loading = true;
  bool _failed = false;
  bool _hasLoaded = false;
  StreamSubscription<List<CashflowEntry>>? _yieldSubscription;
  bool _yieldLoading = true;
  bool _yieldFailed = false;
  bool _yieldHasData = false;
  PropertyYield _yield = const PropertyYield();

  @override
  void initState() {
    super.initState();
    _subscribe();
    _loadYield();
  }

  @override
  void didUpdateWidget(covariant PropertyCashflowSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.propertyId != widget.propertyId ||
        !identical(oldWidget.repository, widget.repository)) {
      _subscribe();
    }
    if (oldWidget.propertyId != widget.propertyId ||
        !identical(oldWidget.assetRepository, widget.assetRepository) ||
        oldWidget.currentValue != widget.currentValue ||
        oldWidget.currencyCode != widget.currencyCode) {
      _loadYield();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _yieldSubscription?.cancel();
    super.dispose();
  }

  DateRange? get _range => switch (_period) {
    _Period.month => DateRange(
      start: LocalDate(widget.today.year, widget.today.month, 1),
      end: LocalDate(
        widget.today.year,
        widget.today.month,
        DateTime(widget.today.year, widget.today.month + 1, 0).day,
      ),
    ),
    _Period.year => DateRange(
      start: LocalDate(widget.today.year, 1, 1),
      end: LocalDate(widget.today.year, 12, 31),
    ),
    _Period.all => null,
  };

  void _loadYield() {
    _yieldSubscription?.cancel();
    setState(() {
      _yieldLoading = true;
      _yieldFailed = false;
    });
    final filter = CashflowFilter(
      period: PropertyYieldCalculator.trailingYear(widget.today),
      propertyId: widget.propertyId,
    );
    _yieldSubscription = widget.repository
        .watch(filter)
        .listen(
          (entries) async {
            try {
              final totals = CashflowCalculator.totals(entries);
              final valuations = await widget.assetRepository.valuations(
                widget.propertyId,
              );
              if (!mounted) return;
              final valueRub = valuations.isNotEmpty
                  ? valuations.first.valueRub
                  : widget.currencyCode == 'RUB'
                  ? widget.currentValue
                  : null;
              setState(() {
                _yield = PropertyYieldCalculator.calculate(
                  incomeRub: totals.income,
                  expenseRub: totals.expense,
                  valueRub: valueRub,
                );
                _yieldHasData = entries.isNotEmpty;
                _yieldLoading = false;
                _yieldFailed = false;
              });
            } on Exception {
              if (!mounted) return;
              setState(() {
                _yieldLoading = false;
                _yieldFailed = true;
              });
            }
          },
          onError: (Object _) {
            if (!mounted) return;
            setState(() {
              _yieldLoading = false;
              _yieldFailed = true;
            });
          },
        );
  }

  void _subscribe() {
    _subscription?.cancel();
    setState(() {
      _loading = true;
      _failed = false;
    });
    _subscription = widget.repository
        .watch(CashflowFilter(period: _range, propertyId: widget.propertyId))
        .listen(
          (entries) {
            if (!mounted) return;
            setState(() {
              _entries = entries;
              _loading = false;
              _hasLoaded = true;
            });
          },
          onError: (Object _) {
            if (!mounted) return;
            setState(() {
              _failed = true;
              _loading = false;
            });
          },
        );
  }

  Future<void> _add({required bool income}) async {
    await context.push(
      AppRoutes.cashflowNewForProperty(widget.propertyId, income: income),
    );
    if (!mounted) return;
    _subscribe();
    _loadYield();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totals = CashflowCalculator.totals(_entries);
    return AppSection(
      header: l10n.propertyCashflowTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFilterBar(
            activeCount: _period == _Period.all ? 1 : 0,
            children: [
              AppFilterChip(
                label: l10n.cashflowPeriodMonth,
                selected: _period == _Period.month,
                onSelected: (_) {
                  setState(() => _period = _Period.month);
                  _subscribe();
                },
              ),
              AppFilterChip(
                label: l10n.cashflowPeriodYear,
                selected: _period == _Period.year,
                onSelected: (_) {
                  setState(() => _period = _Period.year);
                  _subscribe();
                },
              ),
              AppFilterChip(
                label: l10n.cashflowPeriodAll,
                selected: _period == _Period.all,
                onSelected: (_) {
                  setState(() => _period = _Period.all);
                  _subscribe();
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_loading && !_hasLoaded)
            AppSpinner(semanticLabel: l10n.commonLoading)
          else if (_failed)
            Column(
              children: [
                AppText(l10n.errorStateMessage),
                AppButton(
                  label: l10n.retry,
                  variant: AppButtonVariant.text,
                  onPressed: _subscribe,
                ),
              ],
            )
          else
            AppCashflowSummary(
              incomeText: _rub(totals.income),
              expenseText: _rub(totals.expense),
              netText: _rub(totals.net),
              periodLabel: switch (_period) {
                _Period.month =>
                  MaterialLocalizations.of(context).formatMonthYear(
                    DateTime(widget.today.year, widget.today.month),
                  ),
                _Period.year => '${widget.today.year}',
                _Period.all => l10n.cashflowPeriodAll,
              },
              incomeLabel: l10n.cashflowTotalsIncome,
              expenseLabel: l10n.cashflowTotalsExpense,
              netLabel: l10n.cashflowTotalsNet,
            ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.propertyYieldTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          if (_yieldLoading)
            _metaText(context, l10n.commonLoading)
          else if (_yieldFailed) ...[
            _metaText(context, l10n.propertyYieldError),
            AppButton(
              label: l10n.retry,
              variant: AppButtonVariant.text,
              onPressed: _loadYield,
            ),
          ] else if (!_yieldHasData)
            _metaText(context, l10n.propertyYieldNoOperations)
          else if (_yield.available) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AppMetric(
                    label: l10n.propertyYieldGross,
                    value: _percent(_yield.grossPercent!),
                  ),
                ),
                Expanded(
                  child: AppMetric(
                    label: l10n.propertyYieldNet,
                    value: _percent(_yield.netPercent!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _metaText(context, l10n.propertyYieldHint),
          ] else
            _metaText(context, l10n.propertyYieldUnavailable),
          if (!_loading && !_failed && _entries.isEmpty && _yieldHasData) ...[
            const SizedBox(height: AppSpacing.sm),
            AppText(l10n.propertyCashflowEmpty),
          ],
          if (!widget.readOnly) ...[
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.propertyAddIncome,
              variant: AppButtonVariant.tonal,
              onPressed: () => _add(income: true),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.propertyAddExpense,
              variant: AppButtonVariant.tonal,
              onPressed: () => _add(income: false),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _metaText(BuildContext context, String text) => AppText(
    text,
    style: Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
  );

  static String _percent(Decimal value) =>
      '${value.toStringAsFixed(1).replaceAll('.', ',')}%';

  static String _rub(Money money) => const MoneyFormatter().format(
    money,
    const Currency(
      code: 'RUB',
      name: 'Рубль',
      fractionDigits: 2,
      isPreset: true,
      isEnabled: true,
    ),
  );
}
