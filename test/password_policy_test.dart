import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/auth/password_policy.dart';

void main() {
  group('PasswordPolicy.validate', () {
    test('rejects passwords shorter than the minimum', () {
      expect(PasswordPolicy.validate('Aa1!short'), isNotNull);
    });

    test('rejects passwords without an English letter', () {
      expect(PasswordPolicy.validate('123456789!'), isNotNull);
    });

    test('rejects passwords without a number', () {
      expect(PasswordPolicy.validate('Password!!'), isNotNull);
    });

    test('rejects passwords without a symbol', () {
      expect(PasswordPolicy.validate('Password12'), isNotNull);
    });

    test('accepts a password meeting the policy', () {
      expect(PasswordPolicy.validate('Numuw2026!Safe'), isNull);
    });
  });

  group('PasswordPolicy.validateConfirmation', () {
    test('rejects empty confirmation', () {
      expect(
        PasswordPolicy.validateConfirmation(
          confirmation: '',
          password: 'Numuw2026!Safe',
        ),
        isNotNull,
      );
    });

    test('rejects mismatched confirmation', () {
      expect(
        PasswordPolicy.validateConfirmation(
          confirmation: 'Numuw2026!Other',
          password: 'Numuw2026!Safe',
        ),
        isNotNull,
      );
    });

    test('accepts matching confirmation', () {
      expect(
        PasswordPolicy.validateConfirmation(
          confirmation: 'Numuw2026!Safe',
          password: 'Numuw2026!Safe',
        ),
        isNull,
      );
    });
  });

  test('strength differentiates compliant passwords', () {
    expect(PasswordPolicy.strength('short'), PasswordStrength.weak);
    expect(PasswordPolicy.strength('Numuw2026!'), PasswordStrength.fair);
    expect(
      PasswordPolicy.strength('Numuw2026!Safe#'),
      PasswordStrength.strong,
    );
  });
}
