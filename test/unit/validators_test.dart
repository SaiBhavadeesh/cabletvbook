import 'package:flutter_test/flutter_test.dart';
import 'package:cableTvBook/global/validators.dart';

void main() {
  group('Validators Test Suite', () {
    test('emailValidator should accept valid email addresses', () {
      expect(emailValidator('operator@cabletv.com'), isNull);
      expect(emailValidator('test.user+tag@domain.co.in'), isNull);
    });

    test('emailValidator should reject invalid email addresses or empty input', () {
      expect(emailValidator(''), equals('This field is required !'));
      expect(emailValidator(null), equals('This field is required !'));
      expect(emailValidator('notanemail'), equals('please enter valid email !'));
      expect(emailValidator('missing@domain'), equals('please enter valid email !'));
    });

    test('phoneValidator should accept valid 10-digit Indian numbers', () {
      expect(phoneValidator('9876543210'), isNull);
      expect(phoneValidator(' 9876543210 '), isNull);
    });

    test('phoneValidator should reject non-10 digit or non-numeric input', () {
      expect(phoneValidator('12345'), equals('please enter valid number !'));
      expect(phoneValidator('98765432100'), equals('please enter valid number !'));
      expect(phoneValidator('abcdefghij'), equals('please enter valid number !'));
      expect(phoneValidator(''), equals('This field is required !'));
    });

    test('passwordValidator should enforce security rules for sign-up', () {
      // Must contain: uppercase, lowercase, digit, special char, length >= 8
      expect(passwordValidator('StrongP@ss1', false), isNull);
      expect(
        passwordValidator('Str0n@', false), // 6 characters (less than 8)
        contains('must be at least 8 characters'),
      );
      expect(
        passwordValidator('weak', false),
        contains('must contain atleast 1 number'),
      );
      expect(
        passwordValidator('nocaps1@pass', false),
        contains('must contain atleast 1 number'),
      );
      expect(
        passwordValidator('NOLOWER1@PASS', false),
        contains('must contain atleast 1 number'),
      );
      expect(
        passwordValidator('NoNumbers@Pass', false),
        contains('must contain atleast 1 number'),
      );
      expect(
        passwordValidator('NoSpecialChar123', false),
        contains('must contain atleast 1 number'),
      );
    });

    test('passwordValidator should allow standard non-empty passwords for login', () {
      expect(passwordValidator('anyPassword', true), isNull);
      expect(passwordValidator('', true), equals('This field is required !'));
    });

    test('planValidator should accept valid numeric currency amounts', () {
      expect(planValidator('250'), isNull);
      expect(planValidator('350.50'), isNull);
      expect(planValidator('0'), isNull);
    });

    test('planValidator should reject non-numeric or out-of-range amounts', () {
      expect(planValidator('free'), equals('not a valid number !'));
      expect(planValidator(''), equals('This field is required !'));
      expect(planValidator('1000000'), equals('amount is too high!'));
    });

    test('reCheckValidator should verify password confirmation matches', () {
      expect(reCheckValidator('Pass123!', 'Pass123!'), isNull);
      expect(reCheckValidator('Pass123!', 'Pass456!'), equals('passwords did not match !'));
    });
  });
}
