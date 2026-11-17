import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PinCode.parse', () {
    test('принимает PIN из 4–6 цифр', () {
      expect(PinCode.parse('1234').digits, '1234');
      expect(PinCode.parse('123456').digits, '123456');
      expect(PinCode.parse('0000').digits, '0000');
    });

    test('отклоняет короткий, длинный и недопустимый ввод', () {
      expect(() => PinCode.parse('123'), throwsFormatException);
      expect(() => PinCode.parse('1234567'), throwsFormatException);
      expect(() => PinCode.parse(''), throwsFormatException);
      expect(() => PinCode.parse('12 45'), throwsFormatException);
      expect(() => PinCode.parse('12а4'), throwsFormatException);
      expect(() => PinCode.parse('-1234'), throwsFormatException);
    });
  });

  test('равенство по каноническим цифрам', () {
    expect(PinCode.parse('1234'), PinCode.parse('1234'));
    expect(PinCode.parse('1234'), isNot(PinCode.parse('1235')));
  });
}
