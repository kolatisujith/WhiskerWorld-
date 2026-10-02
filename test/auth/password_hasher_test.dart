import 'package:flutter_test/flutter_test.dart';
import 'package:whisker_world/utils/password_hasher.dart';

void main() {
  group('PasswordHasher Cryptographic Security Tests', () {
    test('Hashes password with random salt and HMAC-SHA256', () {
      const password = 'SuperSecretPassword!123';
      final hash = PasswordHasher.hashPassword(password);

      expect(hash, isNotEmpty);
      expect(hash.contains(':'), true);

      final parts = hash.split(':');
      expect(parts.length, 2);
      expect(parts[0].length, 32); // 16 bytes hex salt = 32 chars
      expect(parts[1].length, 64); // SHA-256 hex digest = 64 chars

      // Never equal to plaintext
      expect(hash, isNot(contains(password)));
    });

    test('Two hashes of the same password produce unique salts and distinct outputs', () {
      const password = 'ConsistentPassword456';
      final hash1 = PasswordHasher.hashPassword(password);
      final hash2 = PasswordHasher.hashPassword(password);

      expect(hash1, isNot(equals(hash2)));
      expect(hash1.split(':')[0], isNot(equals(hash2.split(':')[0])));
    });

    test('Verifies correct password successfully', () {
      const password = 'CorrectHorseBatteryStaple';
      final hash = PasswordHasher.hashPassword(password);

      final isValid = PasswordHasher.verifyPassword(password, hash);
      expect(isValid, true);
    });

    test('Rejects incorrect password', () {
      const password = 'RealPassword123';
      const wrongPassword = 'WrongPassword321';
      final hash = PasswordHasher.hashPassword(password);

      final isValid = PasswordHasher.verifyPassword(wrongPassword, hash);
      expect(isValid, false);
    });

    test('Handles empty password error and malformed hash safely', () {
      expect(() => PasswordHasher.hashPassword(''), throwsArgumentError);

      expect(PasswordHasher.verifyPassword('test', ''), false);
      expect(PasswordHasher.verifyPassword('test', 'malformed_hash_without_colon'), false);
      expect(PasswordHasher.verifyPassword('test', 'salt:wronglength'), false);
    });
  });
}
