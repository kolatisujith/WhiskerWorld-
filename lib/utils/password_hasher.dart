import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Cryptographically secure password hashing and verification utility.
/// Never stores plaintext passwords. Combines a secure 16-byte random salt
/// with HMAC-SHA256 and constant-time digest verification.
class PasswordHasher {
  PasswordHasher._();

  /// Generates a salted HMAC-SHA256 hash for [password].
  /// Returns a composite string in the format: "`hex_salt:hex_hash`".
  static String hashPassword(String password) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty.');
    }

    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final saltHex = saltBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    final hmac = Hmac(sha256, saltBytes);
    final digest = hmac.convert(utf8.encode(password));

    return '$saltHex:${digest.toString()}';
  }

  /// Verifies whether [password] matches the stored [compositeHash].
  static bool verifyPassword(String password, String compositeHash) {
    final parts = compositeHash.split(':');
    if (parts.length != 2) {
      return false;
    }

    final saltHex = parts[0];
    final expectedHash = parts[1];

    final saltBytes = <int>[];
    try {
      if (saltHex.length % 2 != 0) return false;
      for (int i = 0; i < saltHex.length; i += 2) {
        saltBytes.add(int.parse(saltHex.substring(i, i + 2), radix: 16));
      }
    } catch (_) {
      return false;
    }

    final hmac = Hmac(sha256, saltBytes);
    final computedDigest = hmac.convert(utf8.encode(password));
    final computedHash = computedDigest.toString();

    // Constant-time comparison to prevent timing attacks
    if (computedHash.length != expectedHash.length) {
      return false;
    }

    int result = 0;
    for (int i = 0; i < computedHash.length; i++) {
      result |= computedHash.codeUnitAt(i) ^ expectedHash.codeUnitAt(i);
    }
    return result == 0;
  }
}
