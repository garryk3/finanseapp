import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/theme/app_spacing.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_rule.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_view_model.dart';
import 'package:finanseapp/core/presentation/date_formatter.dart';
import 'package:finanseapp/core/presentation/view_state.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_empty_state.dart';
import 'package:finanseapp/uikit/app_error_state.dart';
import 'package:finanseapp/uikit/app_floating_action_button.dart';
import 'package:finanseapp/uikit/app_icon.dart';
import 'package:finanseapp/uikit/app_list_tile.dart';
import 'package:finanseapp/uikit/app_list_view.dart';
import 'package:finanseapp/uikit/app_money_text.dart';
import 'package:finanseapp/uikit/app_scaffold.dart';
import 'package:finanseapp/uikit/app_spinner.dart';
import 'package:finanseapp/app/theme/app_semantic_colors.dart';
import 'package:finanseapp/core/features/cashflow/ui/operations_tabs.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Вкладка «Регулярные»: единый список ежемесячных платежей (15.2).
class RecurringRulesScreen extends StatefulWidget {
  const RecurringRulesScreen({
    super.key,
    required this.viewModel,
    required this.onTabChanged,
  });

  final RecurringRulesViewModel viewModel;
  final ValueChanged<String> onTabChanged;

  @override
  State<RecurringRulesScreen> createState() => _RecurringRulesScreenState();
}

class _RecurringRulesScreenState extends State<RecurringRulesScreen> {
  late RecurringRulesViewModel _viewModel = widget.viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.init();
  }

  @override
  void didUpdateWidget(covariant RecurringRulesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.viewModel, widget.viewModel)) {
      oldWidget.viewModel.dispose();
      _viewModel = widget.viewModel..init();
    }
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final saved = await context.push<bool>(AppRoutes.recurringNewPath());
    if (!mounted || saved != true) return;
    _viewModel.reload();
  }

  Future<void> _open(RecurringRule rule) async {
    final path = _viewModel.isAuto(rule)
        ? (rule.accountId == null
              ? null
              : AppRoutes.assetDetailsPath(rule.accountId!))
        : AppRoutes.recurringEditPath(rule.id);
    if (path == null) return;
    await context.push<bool>(path);
    if (!mounted) return;
    _viewModel.reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.navOperations,
      floatingActionButton: AppFloatingActionButton(
        icon: Icons.add,
        tooltip: l10n.recurringAdd,
        onPressed: _add,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding(
                MediaQuery.sizeOf(context).width,
              ),
              vertical: AppSpacing.sm,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppSpacing.formMaxWidth,
                ),
                child: OperationsTabs(
                  current: 'recurring',
                  onChanged: widget.onTabChanged,
                ),
              ),
            ),
          ),
          Expanded(
            child: SignalBuilder(
              builder: (context) {
                final vm = _viewModel;
                final state = vm.state.value;
                if (state is ViewError<List<RecurringRule>>) {
                  return AppErrorState(
                    title: l10n.errorStateTitle,
                    message: l10n.errorStateMessage,
                    errorLabel: l10n.errorLabel,
                    retryLabel: l10n.retry,
                    onRetry: vm.reload,
                  );
                }
                if (state is! ViewData<List<RecurringRule>>) {
                  return Center(
                    child: AppSpinner(semanticLabel: l10n.commonLoading),
                  );
                }
                final rules = state.value;
                if (rules.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.event_repeat,
                    title: l10n.recurringEmpty,
                    message: l10n.recurringEmptyHint,
                    actionLabel: l10n.recurringAdd,
                    onAction: _add,
                  );
                }
                return AppListView.builder(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
                  itemCount: rules.length,
                  itemBuilder: (context, index) {
                    final rule = rules[index];
                    final pending = vm.ratePending.value.contains(rule.id);
                    final next = vm.nextPayment(rule);
                    final target = vm.assetName(rule);
                    final auto = vm.isAuto(rule);
                    final income = rule.kind == CashflowKind.income;
                    final title = auto
                        ? l10n.recurringAutoInterestTitle
                        : vm.categoryName(rule.categoryId);
                    final amount = auto
                        ? l10n.recurringAutoBadge
                        : '${income ? '+' : '−'}${vm.formatAmount(rule)}';
                    return AppListTile(
                      leading: AppIcon(
                        income ? Icons.trending_up : Icons.trending_down,
                        semanticLabel: null,
                      ),
                      title: title,
                      subtitle: _subtitle(
                        l10n,
                        vm,
                        rule,
                        target,
                        next,
                        auto,
                        pending,
                      ),
                      trailing: ExcludeSemantics(
                        child: AppMoneyText(
                          amount,
                          tone: income
                              ? AppMoneyTone.income
                              : AppMoneyTone.expense,
                        ),
                      ),
                      onTap: () => _open(rule),
                      semanticLabel: _semantic(
                        l10n,
                        vm,
                        rule,
                        target,
                        next,
                        auto,
                        pending,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _subtitle(
    AppLocalizations l10n,
    RecurringRulesViewModel vm,
    RecurringRule rule,
    String target,
    LocalDate? next,
    bool auto,
    bool pending,
  ) {
    final formatter = const DateFormatter();
    final parts = <String>[
      if (auto)
        l10n.recurringAutoInterestTitle
      else
        (rule.kind == CashflowKind.income
            ? l10n.cashflowIncome
            : l10n.cashflowExpense),
      l10n.recurringScheduleFrom(formatter.format(rule.startDate)),
      if (rule.endDate != null)
        l10n.recurringScheduleUntil(formatter.format(rule.endDate!)),
      if (target.isNotEmpty) target else l10n.recurringNoTargetHint,
      _nextLabel(l10n, vm, rule, next),
      if (pending) l10n.recurringPendingRate,
    ];
    return parts.join(' · ');
  }

  static String _nextLabel(
    AppLocalizations l10n,
    RecurringRulesViewModel vm,
    RecurringRule rule,
    LocalDate? next,
  ) {
    if (next == null) {
      return rule.endDate == null
          ? l10n.recurringNextPaymentNone
          : l10n.recurringCompleted;
    }
    final formatted = const DateFormatter().format(next);
    if (next.compareTo(vm.today) < 0) {
      return l10n.recurringOverdueLabel(formatted);
    }
    return l10n.recurringNextLabel(formatted);
  }

  static String _semantic(
    AppLocalizations l10n,
    RecurringRulesViewModel vm,
    RecurringRule rule,
    String target,
    LocalDate? next,
    bool auto,
    bool pending,
  ) {
    final amount = auto
        ? l10n.recurringAutoBadge
        : '${rule.kind == CashflowKind.income ? '+' : '−'}'
              '${vm.formatAmount(rule)}';
    return '${auto ? l10n.recurringAutoInterestTitle : vm.categoryName(rule.categoryId)}, '
        '$amount, '
        '${_subtitle(l10n, vm, rule, target, next, auto, pending)}';
  }
}
