import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// A salted, PBKDF2-derived password hash.
class PasswordHash {
  final String hash;
  final String salt;

  const PasswordHash({required this.hash, required this.salt});
}

/// Password hashing helper using PBKDF2-HMAC-SHA256.
///
/// Passwords are never stored in plain text. A per-user random salt is used so
/// identical passwords produce different hashes.
class PasswordHasher {
  PasswordHasher._();

  static const int _iterations = 20000;
  static const int _keyLength = 32;
  static const int _saltLength = 16;

  static PasswordHash create(String password) {
    final salt = _randomBytes(_saltLength);
    final hash = _pbkdf2(
      utf8.encode(password),
      salt,
      _iterations,
      _keyLength,
    );
    return PasswordHash(hash: _hex(hash), salt: _hex(salt));
  }

  static bool verify(String password, String saltHex, String hashHex) {
    final salt = _fromHex(saltHex);
    final expected = _fromHex(hashHex);
    final actual = _pbkdf2(
      utf8.encode(password),
      salt,
      _iterations,
      expected.length,
    );
    return _constantTimeEquals(actual, expected);
  }

  static List<int> _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int length,
  ) {
    final hmac = Hmac(sha256, password);
    final output = Uint8List(length);
    var blockIndex = 1;
    var offset = 0;

    while (offset < length) {
      final block = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt);
      block[salt.length] = (blockIndex >> 24) & 0xff;
      block[salt.length + 1] = (blockIndex >> 16) & 0xff;
      block[salt.length + 2] = (blockIndex >> 8) & 0xff;
      block[salt.length + 3] = blockIndex & 0xff;

      var u = Uint8List.fromList(hmac.convert(block).bytes);
      final t = Uint8List.fromList(u);
      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }

      final take = min(t.length, length - offset);
      output.setRange(offset, offset + take, t.sublist(0, take));
      offset += take;
      blockIndex++;
    }
    return output;
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  static String _hex(List<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static Uint8List _fromHex(String hex) {
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
