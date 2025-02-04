import 'package:flutter_test/flutter_test.dart';

bool isValidUsername(String username) {
  return RegExp(r"^[a-zA-Z0-9_.-]{3,20}$").hasMatch(username);
}

void main() {
  group('Username Validation Tests', () {
    test('Valid usernames should pass', () {
      expect(isValidUsername('user123'), true);
      expect(isValidUsername('valid.name'), true);
      expect(isValidUsername('hello_world-123'), true);
    });

    test('Invalid usernames should fail', () {
      expect(isValidUsername('ab'), false);  // Too short
      expect(isValidUsername('this_is_a_very_long_username_over_limit'), false);  // Too long
      expect(isValidUsername('invalid username'), false); // Spaces not allowed
      expect(isValidUsername(r'!@#\$%^&*'), false); // Special characters not allowed
    });

    test('Injection attacks should fail', () {
      expect(isValidUsername("admin' OR '1'='1"), false); // SQL Injection attempt
      expect(isValidUsername("<script>alert('XSS')</script>"), false); // XSS attack
      expect(isValidUsername("DROP TABLE users;"), false); // SQL Drop Table attack
      expect(isValidUsername("1; DELETE FROM users --"), false); // SQL Command Injection
    });
  });
}
