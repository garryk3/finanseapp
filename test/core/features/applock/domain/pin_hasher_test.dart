import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:finanseapp/core/features/applock/domain/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const hasher = PinHasher();

  test('PBKDF2-HMAC-SHA256 соответствует эталонному вектору (1 итерация)', () {
    // Эталон из стандартных тест-векторов PBKDF2-HMAC-SHA256.
    const vector =
        '120fb6cffcf8b32c43e7225256c4f837'
        'a86548c92ccc35480805987cb70be17b';
    expect(PinHasher.pbkdf2Sha256('password', 'salt', 1, 32), vector);
  });

  test('соль влияет на хэш; одинаковые входы дают одинаковый хэш', () async {
    final pin = PinCode.parse('1234');
    final saltA = hasher.generateSalt();
    final saltB = hasher.generateSalt();

    expect(saltA, isNot(saltB));
    expect(await hasher.hash(pin, saltA), isNot(await hasher.hash(pin, saltB)));
    expect(await hasher.hash(pin, saltA), await hasher.hash(pin, saltA));
  });

  test('verify принимает верный PIN и отклоняет неверный', () async {
    final pin = PinCode.parse('4321');
    final other = PinCode.parse('4322');
    final salt = hasher.generateSalt();
    final hash = await hasher.hash(pin, salt);

    expect(await hasher.verify(pin, salt, hash), isTrue);
    expect(await hasher.verify(other, salt, hash), isFalse);
  });
}
