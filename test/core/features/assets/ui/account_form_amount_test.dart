import 'package:finanseapp/core/domain/common/currency.dart';
import 'package:finanseapp/core/features/assets/ui/account_form_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _rub = Currency(
  code: 'RUB',
  name: 'Рубль',
  fractionDigits: 2,
  isPreset: true,
  isEnabled: true,
);

void main() {
  test('начальный баланс вводится в основных единицах', () {
    expect(parseOpeningAmount('100000', _rub)!.minorUnits, 10000000);
    expect(parseOpeningAmount('100000,50', _rub)!.minorUnits, 10000050);
    expect(parseOpeningAmount(' 1 234,56 ', _rub)!.minorUnits, 123456);
  });

  test('нулевой и невалидный ввод отклоняются', () {
    expect(parseOpeningAmount('0', _rub)!.minorUnits, 0);
    expect(parseOpeningAmount('-1', _rub), isNull);
    expect(parseOpeningAmount('abc', _rub), isNull);
    expect(parseOpeningAmount('', _rub), isNull);
  });
}
