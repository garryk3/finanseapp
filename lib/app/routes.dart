/// Полная карта маршрутов приложения (navigation_and_screens §2).
///
/// Пути и имена не локализуются; динамические сегменты парсятся безопасно.
abstract final class AppRoutes {
  static const dashboard = '/';
  static const operations = '/operations';
  static const assets = '/assets';
  static const goals = '/goals';
  static const more = '/more';
  static const notFound = '/not-found';
  static const applockManage = '/applock';

  static const accountNew = '/assets/new/account';
  static const investmentNew = '/assets/new/investment';
  static const propertyNew = '/assets/new/property';
  static const assetDetails = '/assets/:id';
  static const accountEdit = '/assets/:id/edit/account';
  static const investmentEdit = '/assets/:id/edit/investment';
  static const propertyEdit = '/assets/:id/edit/property';
  static const valuationNew = '/assets/:id/valuations/new';

  static const transactionNew = '/transactions/new';
  static const transferNew = '/transactions/transfer/new';
  static const transactionDetails = '/transactions/:id';
  static const transactionEdit = '/transactions/:id/edit';
  static const transferEdit = '/transactions/transfer/:transferId/edit';

  static const cashflowNew = '/cashflow/new';
  static const cashflowDetails = '/cashflow/:id';
  static const cashflowEdit = '/cashflow/:id/edit';

  static const goalNew = '/goals/new';
  static const goalDetails = '/goals/:id';
  static const goalEdit = '/goals/:id/edit';

  static const analytics = '/more/analytics';
  static const settings = '/more/settings';
  static const categories = '/more/categories';
  static const categoryNew = '/more/categories/new';
  static const categoryEdit = '/more/categories/:id/edit';
  static const subgroups = '/more/subgroups';
  static const currencies = '/more/currencies';
  static const currencyNew = '/more/currencies/new';
  static const baseCurrency = '/more/currencies/base';
  static const audit = '/more/audit';
  static const auditAssetTransaction = '/more/audit/asset-transactions/:id';
  static const auditCashflow = '/more/audit/cashflow/:id';
  static const about = '/more/about';

  /// Значения вкладки журнала операций; неизвестное значение → cashflow.
  static const operationsTabs = <String>['cashflow', 'transactions'];

  static String operationsTab({required String tab}) => '$operations?tab=$tab';

  static String subgroupsPath(String kind) => '$subgroups?kind=$kind';

  static String categoriesPath(String kind) => '$categories?kind=$kind';

  static String categoryNewFor(String kind) => '$categoryNew?kind=$kind';

  static String assetDetailsPath(int id) => '/assets/$id';
  static String accountEditPath(int id) => '/assets/$id/edit/account';
  static String investmentEditPath(int id) => '/assets/$id/edit/investment';
  static String propertyEditPath(int id) => '/assets/$id/edit/property';
  static String valuationNewPath(int id) => '/assets/$id/valuations/new';
  static String transactionNewFor(int assetId, {bool deposit = true}) =>
      '$transactionNew?assetId=$assetId&kind=${deposit ? 'deposit' : 'withdrawal'}';
  static String transactionDetailsPath(int id) => '/transactions/$id';
  static String transactionEditPath(int id) => '/transactions/$id/edit';
  static String transferEditPath(int transferId) =>
      '/transactions/transfer/$transferId/edit';
  static String cashflowDetailsPath(int id) => '/cashflow/$id';
  static String cashflowEditPath(int id) => '/cashflow/$id/edit';
  static String goalDetailsPath(int id) => '/goals/$id';
  static String goalEditPath(int id) => '/goals/$id/edit';
  static String categoryEditPath(int id) => '/more/categories/$id/edit';
  static String auditAssetTransactionPath(int id) =>
      '/more/audit/asset-transactions/$id';
  static String auditCashflowPath(int id) => '/more/audit/cashflow/$id';

  /// Безопасный парс положительного decimal id; иначе `null`.
  static int? parseId(String? raw) {
    final value = int.tryParse(raw ?? '');
    if (value == null || value <= 0) return null;
    return value;
  }

  /// Вкладка операций из query; неизвестное значение не роняет экран.
  static String parseOperationsTab(String? raw) =>
      operationsTabs.contains(raw) ? raw! : 'cashflow';

  /// Allowlist значений `kind` для `/assets` и `/subgroups`.
  static String? parseAllowlisted(String? raw, Set<String> allowed) =>
      allowed.contains(raw) ? raw : null;
}
