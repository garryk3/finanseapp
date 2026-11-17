import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:finanseapp/core/features/applock/domain/pin_code.dart';
import 'package:flutter/foundation.dart';

/// Хэширование PIN: PBKDF2-HMAC-SHA256 со случайной солью (BR-Sec-1).
/// Открытый PIN не сохраняется; соль и хэш — вне БД (BR-Sec-2).
/// Хэширование выполняется в отдельном изоляте: 100k итераций на
/// главном изоляте заметно фризят UI при каждой попытке ввода.
class PinHasher {
  const PinHasher({this.useIsolate = true});

  static const iterations = 100000;
  static const keyLength = 32;

  /// Хэширование в отдельном изоляте (прод). В тестах отключается —
  /// widget-тесты живут в FakeAsync и не могут дождаться real-isolate.
  final bool useIsolate;

  String generateSalt() {
    final random = Random.secure();
    return base64Encode(List<int>.generate(16, (_) => random.nextInt(0x100)));
  }

  Future<String> hash(PinCode pin, String salt) => useIsolate
      ? compute(
          _pbkdf2InIsolate,
          _Pbkdf2Request(pin.digits, salt, iterations, keyLength),
        )
      : Future<String>.value(
          pbkdf2Sha256(pin.digits, salt, iterations, keyLength),
        );

  Future<bool> verify(PinCode pin, String salt, String expectedHash) async =>
      (await hash(pin, salt)) == expectedHash;

  /// PBKDF2 (RFC 8018) на HMAC-SHA256; результат — hex длиной [length] байт.
  static String pbkdf2Sha256(
    String password,
    String salt,
    int iterations,
    int length,
  ) {
    final key = utf8.encode(password);
    final saltBytes = utf8.encode(salt);
    final blockCount = (length + 31) ~/ 32;
    final output = BytesBuilder();
    for (var block = 1; block <= blockCount; block++) {
      var u = Hmac(sha256, key).convert([...saltBytes, ..._int32be(block)]);
      final t = Uint8List.fromList(u.bytes);
      var uBytes = u.bytes;
      for (var i = 1; i < iterations; i++) {
        u = Hmac(sha256, key).convert(uBytes);
        uBytes = u.bytes;
        for (var j = 0; j < 32; j++) {
          t[j] ^= uBytes[j];
        }
      }
      output.add(t);
    }
    return output
        .toBytes()
        .sublist(0, length)
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  static List<int> _int32be(int value) => [
    (value >> 24) & 0xff,
    (value >> 16) & 0xff,
    (value >> 8) & 0xff,
    value & 0xff,
  ];
}

class _Pbkdf2Request {
  const _Pbkdf2Request(this.password, this.salt, this.iterations, this.length);

  final String password;
  final String salt;
  final int iterations;
  final int length;
}

String _pbkdf2InIsolate(_Pbkdf2Request request) => PinHasher.pbkdf2Sha256(
  request.password,
  request.salt,
  request.iterations,
  request.length,
);
