import 'package:finanseapp/app/routes.dart';
import 'package:finanseapp/app/shell_screen.dart';
import 'package:finanseapp/core/di/service_locator.dart';
import 'package:finanseapp/core/features/app_info/ui/not_found_screen.dart';
import 'package:finanseapp/core/features/app_info/ui/not_found_view_model.dart';
import 'package:finanseapp/core/features/applock/logic/applock_settings_view_model.dart';
import 'package:finanseapp/core/features/applock/ui/applock_manage_screen.dart';
import 'package:finanseapp/core/features/assets/ui/assets_screen.dart';
import 'package:finanseapp/core/features/assets/ui/assets_view_model.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_screen.dart';
import 'package:finanseapp/core/features/cashflow/ui/cashflow_view_model.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_screen.dart';
import 'package:finanseapp/core/features/dashboard/ui/dashboard_view_model.dart';
import 'package:finanseapp/core/features/goals/ui/goals_screen.dart';
import 'package:finanseapp/core/features/goals/ui/goals_view_model.dart';
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
                  _placeholderRoute(
                    'new/account',
                    'account-new',
                    (l10n) => l10n.navAssets,
                  ),
                  _placeholderRoute(
                    'new/investment',
                    'investment-new',
                    (l10n) => l10n.navAssets,
                  ),
                  _placeholderRoute(
                    'new/property',
                    'property-new',
                    (l10n) => l10n.navAssets,
                  ),
                  GoRoute(
                    path: ':id',
                    name: 'asset-details',
                    builder: (context, state) {
                      final id = AppRoutes.parseId(state.pathParameters['id']);
                      return id == null
                          ? _notFound(locator)
                          : ComingSoonScreen(title: l10nOf(context).navAssets);
                    },
                    routes: [
                      _placeholderRoute(
                        'edit/account',
                        'account-edit',
                        (l10n) => l10n.navAssets,
                      ),
                      _placeholderRoute(
                        'edit/investment',
                        'investment-edit',
                        (l10n) => l10n.navAssets,
                      ),
                      _placeholderRoute(
                        'edit/property',
                        'property-edit',
                        (l10n) => l10n.navAssets,
                      ),
                      _placeholderRoute(
                        'valuations/new',
                        'valuation-new',
                        (l10n) => l10n.navAssets,
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
                  _placeholderRoute('new', 'goal-new', (l10n) => l10n.navGoals),
                  GoRoute(
                    path: ':id',
                    name: 'goal-details',
                    builder: (context, state) {
                      final id = AppRoutes.parseId(state.pathParameters['id']);
                      return id == null
                          ? _notFound(locator)
                          : ComingSoonScreen(title: l10nOf(context).navGoals);
                    },
                    routes: [
                      _placeholderRoute(
                        'edit',
                        'goal-edit',
                        (l10n) => l10n.navGoals,
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
                  for (final entry in _morePlaceholders)
                    _placeholderRoute(
                      entry.path,
                      entry.name,
                      (l10n) => l10n.navMore,
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
        builder: (context, state) =>
            ComingSoonScreen(title: l10nOf(context).operationsTransactionsTab),
      ),
      GoRoute(
        path: AppRoutes.transferNew,
        name: 'transfer-new',
        builder: (context, state) =>
            ComingSoonScreen(title: l10nOf(context).operationsTransactionsTab),
      ),
      GoRoute(
        path: AppRoutes.transactionDetails,
        name: 'transaction-details',
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
        builder: (context, state) =>
            ComingSoonScreen(title: l10nOf(context).operationsCashflowTab),
      ),
      GoRoute(
        path: AppRoutes.cashflowDetails,
        name: 'cashflow-details',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : ComingSoonScreen(title: l10nOf(context).operationsCashflowTab);
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
        builder: (context, state) =>
            AppRoutes.parseId(state.pathParameters['id']) == null
            ? _notFound(locator)
            : ComingSoonScreen(title: l10nOf(context).navMore),
      ),
      GoRoute(
        path: AppRoutes.auditCashflow,
        name: 'audit-cashflow',
        builder: (context, state) =>
            AppRoutes.parseId(state.pathParameters['id']) == null
            ? _notFound(locator)
            : ComingSoonScreen(title: l10nOf(context).navMore),
      ),
      GoRoute(
        path: AppRoutes.cashflowEdit,
        name: 'cashflow-edit',
        builder: (context, state) {
          final id = AppRoutes.parseId(state.pathParameters['id']);
          return id == null
              ? _notFound(locator)
              : ComingSoonScreen(title: l10nOf(context).operationsCashflowTab);
        },
      ),
    ],
    errorBuilder: (context, state) => _notFound(locator),
  );
}

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
  return CashflowScreen(
    viewModel: locator.get<CashflowViewModel>(),
    onTabChanged: changeTab,
  );
}

Widget _notFound(ServiceLocator locator) =>
    NotFoundScreen(viewModel: locator.get<NotFoundViewModel>());

GoRoute _placeholderRoute(
  String path,
  String name,
  String Function(AppLocalizations l10n) sectionTitle,
) => GoRoute(
  path: path,
  name: name,
  builder: (context, state) =>
      ComingSoonScreen(title: sectionTitle(l10nOf(context))),
);

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

const _morePlaceholders = <({String path, String name})>[
  (path: 'analytics', name: 'analytics'),
  (path: 'settings', name: 'settings'),
  (path: 'categories', name: 'categories'),
  (path: 'categories/new', name: 'category-new'),
  (path: 'subgroups', name: 'subgroups'),
  (path: 'currencies', name: 'currencies'),
  (path: 'currencies/new', name: 'currency-new'),
  (path: 'currencies/base', name: 'base-currency'),
  (path: 'audit', name: 'audit'),
  (path: 'about', name: 'about'),
];
