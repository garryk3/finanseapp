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
}
