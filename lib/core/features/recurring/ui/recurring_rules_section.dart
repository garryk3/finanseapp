import 'dart:async';
import 'dart:developer' as developer;

import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_schedule.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/money_formatter.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_section.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/uikit/app_text.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Секция ежемесячных платежей на экране недвижимости или счёта (15.2).
class RecurringRulesSection extends StatefulWidget {
  const RecurringRulesSection({
    super.key,
    required this.repository,
    required this.categoryRepository,
    required this.currencyRepository,
    required this.rateRepository,
    required this.assetId,
    required this.isAccount,
    required this.today,
    this.readOnly = false,
  });

  final RecurringRepository repository;
  final CategoryRepository categoryRepository;
  final CurrencyRepository currencyRepository;
  final ExchangeRateRepository rateRepository;
  final int assetId;
  final bool isAccount;
  final LocalDate today;
  final bool readOnly;

  @override
  State<RecurringRulesSection> createState() => _RecurringRulesSectionState();
}

class _RecurringRulesSectionState extends State<RecurringRulesSection> {
  List<RecurringRule> _rules = const [];
  Map<int, String> _categoryNames = const {};
  Map<String, Currency> _currencies = const {};
  Set<int> _pending = const {};
  StreamSubscription<List<RecurringRule>>? _subscription;
  bool _loading = true;
  bool _failed = false;
  int _pendingGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadReferences();
    _subscribe();
  }

  @override
  void didUpdateWidget(covariant RecurringRulesSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetId != widget.assetId ||
        oldWidget.isAccount != widget.isAccount ||
        !identical(oldWidget.repository, widget.repository)) {
      _subscribe();
    }
    if (!identical(oldWidget.categoryRepository, widget.categoryRepository) ||
        !identical(oldWidget.currencyRepository, widget.currencyRepository)) {
      _loadReferences();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _subscribe() {
    _subscription?.cancel();
    setState(() {
      _loading = true;
      _failed = false;
    });
    final stream = widget.isAccount
        ? widget.repository.watchByAccount(widget.assetId)
        : widget.repository.watchByProperty(widget.assetId);
    _subscription = stream.listen(
      (rules) {
        if (!mounted) return;
        final fixed = [
          for (final rule in rules)
            if (rule.strategy == RecurringStrategy.fixed) rule,
        ]..sort(_compareByNextPayment);
        setState(() {
          _rules = fixed;
          _loading = false;
          _failed = false;
        });
        _computePending(fixed);
      },
      onError: (Object _) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _failed = true;
        });
      },
    );
  }

  Future<void> _loadReferences() async {
    try {
      final income = await widget.categoryRepository
          .watchByKind(CashflowKind.income, includeArchived: true)
          .first;
      final expense = await widget.categoryRepository
          .watchByKind(CashflowKind.expense, includeArchived: true)
          .first;
      final currencies = await widget.currencyRepository.watchAll().first;
      if (!mounted) return;
      setState(() {
        _categoryNames = {
          for (final category in [...income, ...expense])
            category.id: category.name,
        };
        _currencies = {
          for (final currency in currencies) currency.code: currency,
        };
      });
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Не удалось загрузить подписи секции регулярных платежей',
        name: 'recurring.section',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _computePending(List<RecurringRule> rules) async {
    final generation = ++_pendingGeneration;
    final pending = <int>{};
    for (final rule in rules) {
      if (rule.currencyCode == 'RUB') continue;
      final next = _nextPayment(rule);
      if (next == null || next.compareTo(widget.today) > 0) continue;
      final rate = await widget.rateRepository.find(rule.currencyCode, next);
      if (rate == null) pending.add(rule.id);
    }
    if (!mounted || generation != _pendingGeneration) return;
    setState(() => _pending = pending);
  }

  LocalDate? _nextPayment(RecurringRule rule) => RecurringSchedule.nextPayment(
    startDate: rule.startDate,
    endDate: rule.endDate,
    lastGeneratedPeriod: rule.lastGeneratedPeriod,
    firstPeriodOffset: 0,
  );

  String _amount(RecurringRule rule) {
    final amount = rule.amount;
    if (amount == null) return '—';
    return const MoneyFormatter().format(
      amount,
      _currencies[amount.currencyCode] ??
          Currency(
            code: amount.currencyCode,
            name: amount.currencyCode,
            fractionDigits: 2,
            isPreset: true,
            isEnabled: true,
          ),
    );
  }

  int _compareByNextPayment(RecurringRule left, RecurringRule right) {
    final leftNext = _nextPayment(left);
    final rightNext = _nextPayment(right);
    if (leftNext == null && rightNext == null) {
      return left.id.compareTo(right.id);
    }
    if (leftNext == null) return 1;
    if (rightNext == null) return -1;
    final byDate = leftNext.compareTo(rightNext);
    return byDate != 0 ? byDate : left.id.compareTo(right.id);
  }

  String _nextLabel(RecurringRule rule) {
    final l10n = AppLocalizations.of(context);
    final next = _nextPayment(rule);
    if (next == null) {
      return rule.endDate == null
          ? l10n.recurringNextPaymentNone
          : l10n.recurringCompleted;
    }
    final formatted = const DateFormatter().format(next);
    if (next.compareTo(widget.today) < 0) {
      return l10n.recurringOverdueLabel(formatted);
    }
    return l10n.recurringNextLabel(formatted);
  }

  Future<void> _add() async {
    final saved = await context.push<bool>(
      AppRoutes.recurringNewPath(
        propertyId: widget.isAccount ? null : widget.assetId,
        accountId: widget.isAccount ? widget.assetId : null,
      ),
    );
    if (!mounted || saved != true) return;
    _subscribe();
  }

  Future<void> _open(RecurringRule rule) async {
    await context.push<bool>(AppRoutes.recurringEditPath(rule.id));
    if (!mounted) return;
    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSection(
      header: l10n.recurringTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_loading)
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
          else if (_rules.isEmpty)
            AppText(l10n.recurringSectionEmpty)
          else
            for (final rule in _rules)
              AppListTile(
                leading: AppIcon(
                  rule.kind == CashflowKind.income
                      ? Icons.trending_up
                      : Icons.trending_down,
                  semanticLabel: null,
                ),
                title: _categoryNames[rule.categoryId] ?? '—',
                subtitle:
                    '${rule.kind == CashflowKind.income ? l10n.cashflowIncome : l10n.cashflowExpense} · '
                    '${_nextLabel(rule)}'
                    '${_pending.contains(rule.id) ? ' · ${l10n.recurringPendingRate}' : ''}',
                trailing: ExcludeSemantics(
                  child: AppMoneyText(
                    '${rule.kind == CashflowKind.income ? '+' : '−'}'
                    '${_amount(rule)}',
                    tone: rule.kind == CashflowKind.income
                        ? AppMoneyTone.income
                        : AppMoneyTone.expense,
                  ),
                ),
                enabled: !widget.readOnly,
                onTap: widget.readOnly ? null : () => _open(rule),
                semanticLabel:
                    '${_categoryNames[rule.categoryId] ?? '—'}, '
                    '${rule.kind == CashflowKind.income ? l10n.cashflowIncome : l10n.cashflowExpense}, '
                    '${_amount(rule)}, ${_nextLabel(rule)}'
                    '${_pending.contains(rule.id) ? ', ${l10n.recurringPendingRate}' : ''}',
              ),
          if (!widget.readOnly) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.recurringAdd,
              variant: AppButtonVariant.tonal,
              onPressed: _add,
            ),
          ],
        ],
      ),
    );
  }
}
