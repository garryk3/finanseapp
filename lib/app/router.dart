import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/core/features/backup/logic/backup_view_model.dart';
import 'package:finanseapp/core/features/settings/logic/update_check_view_model.dart';
import 'package:finanseapp/core/database/app_database.dart';
import 'package:finanseapp/app/shell_screen.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/app_info/ui/not_found_screen.dart';
import 'package:finanseapp/core/features/app_info/ui/not_found_view_model.dart';
import 'package:finanseapp/core/features/analytics/domain/analytics_queries.dart';
import 'package:finanseapp/core/features/analytics/logic/analytics_periods.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_screen.dart';
import 'package:finanseapp/core/features/analytics/ui/asset_comparison_screen.dart';
import 'package:finanseapp/core/features/analytics/ui/asset_comparison_view_model.dart';
import 'package:finanseapp/core/features/analytics/ui/analytics_view_model.dart';
import 'package:finanseapp/core/features/analytics/ui/cashflow_details_screen.dart'
    as analytics_details;
import 'package:finanseapp/core/features/analytics/ui/cashflow_details_view_model.dart'
    as analytics_details;
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_manage_screen.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup.dart';
import 'package:finanseapp/core/domain/common/local_date.dart';
import 'package:finanseapp/core/features/assets/domain/asset_repository.dart';
import 'package:finanseapp/core/features/assets/domain/subgroup_repository.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_screen.dart';
import 'package:finanseapp/core/features/assets/ui/account_details_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/assets_screen.dart';
import 'package:finanseapp/core/features/assets/ui/investment_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/property_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/property_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/investment_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/valuation_form_screen.dart';
import 'package:finanseapp/core/features/assets/ui/valuation_form_view_model.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction.dart';
import 'package:finanseapp/core/features/transactions/domain/asset_transaction_repository.dart';
import 'package:finanseapp/core/features/audit/domain/audit_repository.dart';
import 'package:finanseapp/core/features/audit/ui/audit_screen.dart';
import 'package:finanseapp/core/features/audit/ui/audit_view_model.dart';
import 'package:finanseapp/core/features/audit/ui/audit_asset_transaction_screen.dart';
import 'package:finanseapp/core/features/audit/ui/audit_asset_transaction_view_model.dart';
import 'package:finanseapp/core/features/audit/ui/audit_cashflow_screen.dart';
import 'package:finanseapp/core/features/audit/ui/audit_cashflow_view_model.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_details_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_details_view_model.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_form_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transaction_form_view_model.dart';
import 'package:finanseapp/core/features/transactions/ui/transfer_form_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transfer_form_view_model.dart';
import 'package:finanseapp/core/features/currencies/domain/currency_repository.dart';
import 'package:finanseapp/core/features/currencies/domain/exchange_rate_repository.dart';
import 'package:finanseapp/core/features/settings/domain/settings_repository.dart';
import 'package:finanseapp/core/features/settings/ui/about_screen.dart';
import 'package:finanseapp/core/features/settings/ui/about_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/settings_screen.dart';
import 'package:finanseapp/core/features/settings/ui/settings_view_model.dart';
import 'package:finanseapp/core/features/categories/domain/category.dart';
import 'package:finanseapp/core/features/categories/domain/category_repository.dart';
import 'package:finanseapp/core/features/categories/ui/categories_screen.dart';
import 'package:finanseapp/core/features/categories/ui/categories_view_model.dart';
import 'package:finanseapp/core/features/categories/ui/category_form_screen.dart';
import 'package:finanseapp/core/features/categories/ui/category_form_view_model.dart';
import 'package:finanseapp/core/features/currencies/ui/base_currency_screen.dart';
import 'package:finanseapp/core/features/currencies/ui/base_currency_view_model.dart';
import 'package:finanseapp/core/features/currencies/ui/currencies_screen.dart';
import 'package:finanseapp/core/features/currencies/ui/currencies_view_model.dart';
import 'package:finanseapp/core/features/currencies/ui/currency_form_screen.dart';
import 'package:finanseapp/core/features/currencies/ui/currency_form_view_model.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/core/features/cashflow/domain/cashflow_repository.dart';
import 'package:finanseapp/core/features/cashflow/logic/cashflow_commands.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_details_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_details_view_model.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_form_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_screen.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/features/goals/domain/goal_repository.dart';
import 'package:finanseapp/core/features/goals/ui/goal_details_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goal_details_view_model.dart';
import 'package:finanseapp/core/features/goals/ui/goal_form_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goals_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
import 'package:finanseapp/core/features/references/ui/subgroups_screen.dart';
import 'package:finanseapp/core/features/references/ui/subgroups_view_model.dart';
import 'package:finanseapp/core/features/recurring/domain/recurring_repository.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_catchup_service.dart';
import 'package:finanseapp/core/features/recurring/logic/recurring_commands.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rule_form_screen.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rule_form_view_model.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_screen.dart';
import 'package:finanseapp/core/features/recurring/ui/recurring_rules_view_model.dart';
import 'package:finanseapp/core/features/settings/ui/more_screen.dart';
import 'package:finanseapp/core/features/settings/ui/more_view_model.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_screen.dart';
import 'package:finanseapp/core/features/transactions/ui/transactions_view_model.dart';
import 'package:finanseapp/l10n/app_localizations.dart';
import 'package:finanseapp/uikit/app_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

/// Единая точка маршрутизации приложения (go_router).
///
/// Системный BACK под локом перехватывается `ApplockBackDispatcher` в
/// `app.dart`; secondary-экраны подключаются своими feature-задачами.
GoRouter buildRouter({required ServiceLocator locator}) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ShellScreen(
          navigationShell: navigationShell,
          destinations: _destinations(context),
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                name: 'dashboard',
                builder: (context, state) => DashboardScreen(
                  viewModel: locator.get<DashboardViewModel>(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.operations,
                name: 'operations',
                builder: (context, state) =>
                    _operationsScreen(context, state, locator),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.assets,
                name: 'assets',
                builder: (context, state) =>
                    AssetsScreen(viewModel: locator.get<AssetsViewModel>()),
                routes: [
                  GoRoute(
                    path: 'new/account',
                    name: 'account-new',
                    builder: (context, state) => AccountFormScreen(
                      viewModel: AccountFormViewModel(
                        repository: locator.get<AssetRepository>(),
                        subgroupRepository: locator.get<SubgroupRepository>(),
                        currencyRepository: locator.get<CurrencyRepository>(),
                        catchup: locator.get<RecurringCatchupService>().catchUp,
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'new/investment',
                    name: 'investment-new',
                    builder: (context, state) => InvestmentFormScreen(
                      viewModel: InvestmentFormViewModel(
                        repository: locator.get<AssetRepository>(),
                        subgroupRepository: locator.get<SubgroupRepository>(),
                        currencyRepository: locator.get<CurrencyRepository>(),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'new/property',
                    name: 'property-new',
                    builder: (context, state) => PropertyFormScreen(
                      viewModel: PropertyFormViewModel(
                        repository: locator.get<AssetRepository>(),
                        currencyRepository: locator.get<CurrencyRepository>(),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'asset-details',
                    builder: (context, state) {
                      final id = AppRoutes.parseId(state.pathParameters['id']);
                      return id == null
                          ? _notFound(locator)
                          : AccountDetailsScreen(
                              viewModel: AccountDetailsViewModel(
                                repository: locator.get<AssetRepository>(),
                                assetId: id,
                                today: LocalDate.fromDateTime(DateTime.now()),
                                settingsRepository: locator
                                    .get<SettingsRepository>(),
                                currencyRepository: locator
                                    .get<CurrencyRepository>(),
                                rateRepository: locator
                                    .get<ExchangeRateRepository>(),
                                cashflowRepository: locator
                                    .get<CashflowRepository>(),
                                recurringRepository: locator
                                    .get<RecurringRepository>(),
                                categoryRepository: locator
                                    .get<CategoryRepository>(),
                              ),
                            );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit/account',
                        name: 'account-edit',
                        builder: (context, state) {
                          final id = AppRoutes.parseId(
                            state.pathParameters['id'],
                          );
                          return id == null
                              ? _notFound(locator)
                              : AccountFormScreen(
                                  viewModel: AccountFormViewModel(
                                    repository: locator.get<AssetRepository>(),
                                    subgroupRepository: locator
                                        .get<SubgroupRepository>(),
                                    currencyRepository: locator
                                        .get<CurrencyRepository>(),
                                    editingId: id,
                                    catchup: locator
                                        .get<RecurringCatchupService>()
                                        .catchUp,
                                  ),
                                );
                        },
                      ),
                      GoRoute(
                        path: 'edit/investment',
                        name: 'investment-edit',
                        builder: (context, state) {
                          final id = AppRoutes.parseId(
                            state.pathParameters['id'],
                          );
                          return id == null
                              ? _notFound(locator)
                              : InvestmentFormScreen(
                                  viewModel: InvestmentFormViewModel(
                                    repository: locator.get<AssetRepository>(),
                                    subgroupRepository: locator
                                        .get<SubgroupRepository>(),
                                    currencyRepository: locator
                                        .get<CurrencyRepository>(),
                                    editingId: id,
                                  ),
                                );
                        },
                      ),
                      GoRoute(
                        path: 'edit/property',
                        name: 'property-edit',
                        builder: (context, state) {
                          final id = AppRoutes.parseId(
                            state.pathParameters['id'],
                          );
                          return id == null
                              ? _notFound(locator)
                              : PropertyFormScreen(
                                  viewModel: PropertyFormViewModel(
                                    repository: locator.get<AssetRepository>(),
                                    currencyRepository: locator
                                        .get<CurrencyRepository>(),
                                    editingId: id,
                                  ),
                                );
                        },
                      ),
                      GoRoute(
                        path: 'valuations/new',
                        name: 'valuation-new',
                        builder: (context, state) {
                          final id = AppRoutes.parseId(
                            state.pathParameters['id'],
                          );
                          return id == null
                              ? _notFound(locator)
                              : ValuationFormScreen(
                                  viewModel: ValuationFormViewModel(
                                    repository: locator.get<AssetRepository>(),
                                    rateRepository: locator
                                        .get<ExchangeRateRepository>(),
                                    currencyRepository: locator
                                        .get<CurrencyRepository>(),
                                    assetId: id,
                                    today: LocalDate.fromDateTime(
                                      DateTime.now(),
                                    ),
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.goals,
                name: 'goals',
                builder: (context, state) =>
                    GoalsScreen(viewModel: locator.get<GoalsViewModel>()),
                routes: [
                  GoRoute(
                    path: 'new',
                    name: 'goal-new',
                    builder: (context, state) => GoalFormScreen(
                      viewModel: GoalFormViewModel(
                        repository: locator.get<GoalRepository>(),
                        assetRepository: locator.get<AssetRepository>(),
                        currencyRepository: locator.get<CurrencyRepository>(),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'goal-details',
                    builder: (context, state) {
                      final id = AppRoutes.parseId(state.pathParameters['id']);
                      return id == null
                          ? _notFound(locator)
                          : GoalDetailsScreen(
                              viewModel: GoalDetailsViewModel(
                                repository: locator.get<GoalRepository>(),
                                assetRepository: locator.get<AssetRepository>(),
                                currencyRepository: locator
                                    .get<CurrencyRepository>(),
                                rateRepository: locator
                                    .get<ExchangeRateRepository>(),
                                today: LocalDate.fromDateTime(DateTime.now()),
                                goalId: id,
                              ),
                            );
                    },
                    routes: [
                      GoRoute(
                        path: 'edit',
                        name: 'goal-edit',
                        builder: (context, state) {
                          final id = AppRoutes.parseId(
                            state.pathParameters['id'],
                          );
                          return id == null
                              ? _notFound(locator)
                              : GoalFormScreen(
                                  viewModel: GoalFormViewModel(
                                    repository: locator.get<GoalRepository>(),
                                    assetRepository: locator
                                        .get<AssetRepository>(),
                                    currencyRepository: locator
                                        .get<CurrencyRepository>(),
                                    editingId: id,
                                  ),
                                );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.more,
                name: 'more',
                builder: (context, state) =>
                    MoreScreen(viewModel: locator.get<MoreViewModel>()),
                routes: [
                  GoRoute(
                    path: 'subgroups',
                    name: 'subgroups',
                    builder: (context, state) {
                      final kind =
                          AppRoutes.parseAllowlisted(
                                state.uri.queryParameters['kind'],
                                const {'bank', 'broker'},
                              ) ==
                              'broker'
                          ? SubgroupKind.broker
                          : SubgroupKind.bank;
                      return SubgroupsScreen(
                        viewModel: locator.get<SubgroupsViewModel>(),
                        initialKind: kind,
                        onKindChanged: (next) {
                          final path = AppRoutes.subgroupsPath(
                            next == SubgroupKind.broker ? 'broker' : 'bank',
                          );
                          // Если справочник открыт поверх формы (push), `go`
                          // сбросил бы стек и потерял несохранённые данные.
                          final route = ModalRoute.of(context);
                          if (route != null && !route.isFirst) {
                            context.pushReplacement(path);
                          } else {
                            context.go(path);
                          }
                        },
                      );
                    },
                  ),
                  GoRoute(
                    path: 'categories',
                    name: 'categories',
                    builder: (context, state) {
                      final kind =
                          AppRoutes.parseAllowlisted(
                                state.uri.queryParameters['kind'],
                                const {'income', 'expense'},
                              ) ==
                              'income'
                          ? CashflowKind.income
                          : CashflowKind.expense;
                      return CategoriesScreen(
                        viewModel: locator.get<CategoriesViewModel>(),
                        initialKind: kind,
                        onKindChanged: (next) => context.go(
                          AppRoutes.categoriesPath(
                            next == CashflowKind.income ? 'income' : 'expense',
                          ),
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'categories/new',
                    name: 'category-new',
                    builder: (context, state) {
                      final kind =
                          AppRoutes.parseAllowlisted(
                                state.uri.queryParameters['kind'],
                                const {'income', 'expense'},
                              ) ==
                              'income'
                          ? CashflowKind.income
                          : CashflowKind.expense;
                      return CategoryFormScreen(
                        viewModel: CategoryFormViewModel(
                          repository: locator.get<CategoryRepository>(),
                          kind: kind,
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    path: 'currencies',
                    name: 'currencies',
                    builder: (context, state) => CurrenciesScreen(
                      viewModel: locator.get<CurrenciesViewModel>(),
                    ),
                  ),
                  GoRoute(
                    path: 'currencies/new',
                    name: 'currency-new',
                    builder: (context, state) => CurrencyFormScreen(
                      viewModel: locator.get<CurrencyFormViewModel>(),
                    ),
                  ),
                  GoRoute(
                    path: 'currencies/base',
                    name: 'base-currency',
                    builder: (context, state) => BaseCurrencyScreen(
                      viewModel: locator.get<BaseCurrencyViewModel>(),
                    ),
                  ),
                  GoRoute(
                    path: 'compare',
                    name: 'comparison',
                    builder: (context, state) => AssetComparisonScreen(
                      viewModel: AssetComparisonViewModel(
                        queries: locator.get<AnalyticsQueries>(),
                        assetRepository: locator.get<AssetRepository>(),
                        settingsRepository: locator.get<SettingsRepository>(),
                        now: () => LocalDate.fromDateTime(DateTime.now()),
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'analytics',
                    name: 'analytics',
                    builder: (context, state) {
                      final viewModel = locator.get<AnalyticsViewModel>();
                      final period = _analyticsPeriod(
                        state.uri.queryParameters['period'],
                      );
                      if (period != null) {
                        viewModel.setInitialPeriod(period);
                      }
                      return AnalyticsScreen(
                        viewModel: viewModel,
                        disposeViewModel: false,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'analytics/details',
                    name: 'analytics-details',
                    builder: (context, state) {
                      final query = state.uri.queryParameters;
                      final kind = switch (AppRoutes.parseAllowlisted(
                        query['kind'],
                        const {'income', 'expense'},
                      )) {
                        'income' => CashflowKind.income,
                        'expense' => CashflowKind.expense,
                        _ => null,
                      };
                      final viewModel =
                          analytics_details.CashflowDetailsViewModel(
                              queries: locator.get<AnalyticsQueries>(),
                              settingsRepository: locator
                                  .get<SettingsRepository>(),
                              currencyRepository: locator
                                  .get<CurrencyRepository>(),
                              rateRepository: locator
                                  .get<ExchangeRateRepository>(),
                              now: () => LocalDate.fromDateTime(DateTime.now()),
                            )
                            ..setInitialPeriod(
                              _analyticsPeriod(query['period']) ??
                                  AnalyticsPeriod.month,
                            )
                            ..setInitialKind(kind)
                            ..setInitialCategoryId(
                              AppRoutes.parseId(query['categoryId']),
                            );
                      return analytics_details.CashflowDetailsScreen(
                        viewModel: viewModel,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'settings',
                    name: 'settings',
                    builder: (context, state) => SettingsScreen(
                      viewModel: locator.get<SettingsViewModel>(),
                      backupViewModel: locator.get<BackupViewModel>(),
                      updateViewModel: locator.get<UpdateCheckViewModel>(),
                    ),
                  ),
                  GoRoute(
                    path: 'about',
                    name: 'about',
                    builder: (context, state) =>
                        AboutScreen(viewModel: locator.get<AboutViewModel>()),
                  ),
                  GoRoute(
                    path: 'audit',
                    name: 'audit',
                    builder: (context, state) => AuditScreen(
                      viewModel: AuditViewModel(
                        transactionRepository: locator
                            .get<AssetTransactionRepository>(),
                        cashflowRepository: locator.get<CashflowRepository>(),
                        currencyRepository: locator.get<CurrencyRepository>(),
                        assetRepository: locator.get<AssetRepository>(),
                        categoryRepository: locator.get<CategoryRepository>(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.applockManage,
        name: 'applock-manage',
        builder: (context, state) => ApplockManageScreen(
          viewModel: locator.get<ApplockSettingsViewModel>(),
        ),
      ),
      GoRoute(
        path: AppRoutes.notFound,
        name: 'not-found',
        builder: (context, state) => _notFound(locator),
      ),
      // Secondary journal routes: экраны придут в 6.1/7.1.
      GoRoute(
        path: AppRoutes.transactionNew,
        name: 'transaction-new',
        builder: (context, state) => TransactionFormScreen(
          viewModel: TransactionFormViewModel(
            assetRepository: locator.get<AssetRepository>(),
            transactionRepository: locator.get<AssetTransactionRepository>(),
            categoryRepository: locator.get<CategoryRepository>(),
            currencyRepository: locator.get<CurrencyRepository>(),
            rateRepository: locator.get<ExchangeRateRepository>(),
            today: LocalDate.fromDateTime(DateTime.now()),
            initialAssetId: int.tryParse(
              state.uri.queryParameters['assetId'] ?? '',
            ),
            initialKind: state.uri.queryParameters['kind'] == 'withdrawal'
                ? AssetTransactionKind.withdrawal
                : AssetTransactionKind.deposit,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.transferNew,
        name: 'transfer-new',
        builder: (context, state) => TransferFormScreen(
          viewModel: TransferFormViewModel(
            assetRepository: locator.get<AssetRepository>(),
            transactionRepository: locator.get<AssetTransactionRepository>(),
            currencyRepository: locator.get<CurrencyRepository>(),
            rateRepository: locator.get<ExchangeRateRepository>(),
            today: LocalDate.fromDateTime(DateTime.now()),
            initialFromId: int.tryParse(
              state.uri.queryParameters['fromId'] ?? '',
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.transactionDetails,
        name: 'transaction-details',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : TransactionDetailsScreen(
                  viewModel: TransactionDetailsViewModel(
                    repository: locator.get<AssetTransactionRepository>(),
                    assetRepository: locator.get<AssetRepository>(),
                    auditRepository: locator.get<AuditRepository>(),
                    settingsRepository: locator.get<SettingsRepository>(),
                    currencyRepository: locator.get<CurrencyRepository>(),
                    rateRepository: locator.get<ExchangeRateRepository>(),
                    today: LocalDate.fromDateTime(DateTime.now()),
                    transactionId: id,
                  ),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.transactionEdit,
        name: 'transaction-edit',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : ComingSoonScreen(
                  title: l10nOf(context).operationsTransactionsTab,
                );
        },
      ),
      GoRoute(
        path: AppRoutes.transferEdit,
        name: 'transfer-edit',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['transferId']);
          return id == null
              ? _notFound(locator)
              : ComingSoonScreen(
                  title: l10nOf(context).operationsTransactionsTab,
                );
        },
      ),
      GoRoute(
        path: AppRoutes.cashflowNew,
        name: 'cashflow-new',
        builder: (context, state) => CashflowFormScreen(
          propertyId: int.tryParse(
            state.uri.queryParameters['propertyId'] ?? '',
          ),
          viewModel: CashflowFormViewModel(
            repository: locator.get<CashflowRepository>(),
            categoryRepository: locator.get<CategoryRepository>(),
            currencyRepository: locator.get<CurrencyRepository>(),
            commands: _cashflowCommands(locator),
            assetRepository: locator.get<AssetRepository>(),
            initialKind: state.uri.queryParameters['kind'] == 'income'
                ? CashflowKind.income
                : CashflowKind.expense,
            propertyId: int.tryParse(
              state.uri.queryParameters['propertyId'] ?? '',
            ),
            recurringCommands: _recurringCommands(locator),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.recurringNew,
        name: 'recurring-new',
        builder: (context, state) => RecurringRuleFormScreen(
          viewModel: RecurringRuleFormViewModel(
            repository: locator.get<RecurringRepository>(),
            categoryRepository: locator.get<CategoryRepository>(),
            currencyRepository: locator.get<CurrencyRepository>(),
            assetRepository: locator.get<AssetRepository>(),
            commands: _recurringCommands(locator),
            initialKind: state.uri.queryParameters['kind'] == 'income'
                ? CashflowKind.income
                : CashflowKind.expense,
            presetPropertyId: int.tryParse(
              state.uri.queryParameters['propertyId'] ?? '',
            ),
            presetAccountId: int.tryParse(
              state.uri.queryParameters['accountId'] ?? '',
            ),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.recurringEdit,
        name: 'recurring-edit',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : RecurringRuleFormScreen(
                  viewModel: RecurringRuleFormViewModel(
                    repository: locator.get<RecurringRepository>(),
                    categoryRepository: locator.get<CategoryRepository>(),
                    currencyRepository: locator.get<CurrencyRepository>(),
                    assetRepository: locator.get<AssetRepository>(),
                    commands: _recurringCommands(locator),
                    editingId: id,
                  ),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.cashflowDetails,
        name: 'cashflow-details',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : CashflowDetailsScreen(
                  viewModel: CashflowDetailsViewModel(
                    repository: locator.get<CashflowRepository>(),
                    categoryRepository: locator.get<CategoryRepository>(),
                    auditRepository: locator.get<AuditRepository>(),
                    currencyRepository: locator.get<CurrencyRepository>(),
                    commands: _cashflowCommands(locator),
                    assetRepository: locator.get<AssetRepository>(),
                    entryId: id,
                  ),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.categoryEdit,
        name: 'category-edit',
        builder: (context, state) =>
            AppRoutes.parseId(state.pathParameters['id']) == null
            ? _notFound(locator)
            : ComingSoonScreen(title: l10nOf(context).navMore),
      ),
      GoRoute(
        path: AppRoutes.auditAssetTransaction,
        name: 'audit-asset-transaction',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : AuditAssetTransactionScreen(
                  viewModel: AuditAssetTransactionViewModel(
                    auditRepository: locator.get<AuditRepository>(),
                    assetRepository: locator.get<AssetRepository>(),
                    transactionRepository: locator
                        .get<AssetTransactionRepository>(),
                    transactionId: id,
                  ),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.auditCashflow,
        name: 'audit-cashflow',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : AuditCashflowScreen(
                  viewModel: AuditCashflowViewModel(
                    auditRepository: locator.get<AuditRepository>(),
                    cashflowRepository: locator.get<CashflowRepository>(),
                    entryId: id,
                  ),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.cashflowEdit,
        name: 'cashflow-edit',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : CashflowFormScreen(
                  viewModel: CashflowFormViewModel(
                    repository: locator.get<CashflowRepository>(),
                    categoryRepository: locator.get<CategoryRepository>(),
                    currencyRepository: locator.get<CurrencyRepository>(),
                    commands: _cashflowCommands(locator),
                    assetRepository: locator.get<AssetRepository>(),
                    editingId: id,
                  ),
                );
        },
      ),
    ],
    errorBuilder: (context, state) => _notFound(locator),
  );
}

CashflowCommands _cashflowCommands(ServiceLocator locator) => CashflowCommands(
  repository: locator.get<CashflowRepository>(),
  currencyRepository: locator.get<CurrencyRepository>(),
  rateRepository: locator.get<ExchangeRateRepository>(),
  today: LocalDate.fromDateTime(DateTime.now()),
  db: locator.get<AppDatabase>(),
);

RecurringCommands _recurringCommands(ServiceLocator locator) =>
    RecurringCommands(
      repository: locator.get<RecurringRepository>(),
      catchup: locator.get<RecurringCatchupService>().catchUp,
      today: LocalDate.fromDateTime(DateTime.now()),
    );

/// Вкладки журнала операций с сохранением выбора в query.
Widget _operationsScreen(
  BuildContext context,
  GoRouterState state,
  ServiceLocator locator,
) {
  final tab = AppRoutes.parseOperationsTab(state.uri.queryParameters['tab']);
  void changeTab(String next) => context.go(AppRoutes.operationsTab(tab: next));
  if (tab == 'transactions') {
    return TransactionsScreen(
      viewModel: locator.get<TransactionsViewModel>(),
      onTabChanged: changeTab,
    );
  }
  if (tab == 'recurring') {
    return RecurringRulesScreen(
      viewModel: locator.get<RecurringRulesViewModel>(),
      onTabChanged: changeTab,
    );
  }
  return CashflowScreen(
    viewModel: locator.get<CashflowViewModel>(),
    onTabChanged: changeTab,
  );
}

Widget _notFound(ServiceLocator locator) =>
    NotFoundScreen(viewModel: locator.get<NotFoundViewModel>());

List<AppNavigationDestination> _destinations(BuildContext context) {
  final l10n = l10nOf(context);
  return [
    AppNavigationDestination(
      label: l10n.navDashboard,
      icon: Icons.dashboard_outlined,
    ),
    AppNavigationDestination(
      label: l10n.navOperations,
      icon: Icons.receipt_long_outlined,
    ),
    AppNavigationDestination(
      label: l10n.navAssets,
      icon: Icons.account_balance_wallet_outlined,
    ),
    AppNavigationDestination(label: l10n.navGoals, icon: Icons.flag_outlined),
    AppNavigationDestination(label: l10n.navMore, icon: Icons.more_horiz),
  ];
}

AppLocalizations l10nOf(BuildContext context) => AppLocalizations.of(context);

AnalyticsPeriod? _analyticsPeriod(String? value) => switch (value) {
  'month' => AnalyticsPeriod.month,
  '3m' => AnalyticsPeriod.threeMonths,
  '6m' => AnalyticsPeriod.sixMonths,
  'year' => AnalyticsPeriod.year,
  'all' => AnalyticsPeriod.all,
  _ => null,
};
