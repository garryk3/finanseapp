import 'package:finanseapp/app/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('маршрут операции передаёт вид пополнения/снятия', () {
    expect(
      AppRoutes.transactionNewFor(5),
      '/transactions/new?assetId=5&kind=deposit',
    );
    expect(
      AppRoutes.transactionNewFor(5, deposit: false),
      '/transactions/new?assetId=5&kind=withdrawal',
    );
  });

  test('маршрут детализации передаёт период и фильтры', () {
    expect(
      AppRoutes.analyticsDetailsPath(),
      '/more/analytics/details?period=month',
    );
    expect(
      AppRoutes.analyticsDetailsPath(
        period: 'year',
        kind: 'expense',
        categoryId: 7,
      ),
      '/more/analytics/details?period=year&kind=expense&categoryId=7',
    );
    expect(
      AppRoutes.analyticsDetailsPath(period: 'all', kind: 'income'),
      '/more/analytics/details?period=all&kind=income',
    );
  });
}
