import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

void main() {
  group('String.isPhone extension', () {
    test('Valid phone numbers', () {
      final validPhoneNumbers = [
        '+123456789',
        '+123 456 7890',
        '+12 345 67890',
        '+1 (123) 456-7890',
        '(12) 3 4567-8910',
        '123-456-7890',
        '123.456.7890',
        '(123)456-7890',
        '(123) 456.7890',
        '+123 456 7890',
        '+44 1234 567890',
        '+49 170 1234567',
        '123456789012345',
        '06 12 12 12 12',
        '+33 1 12 12 12 12',
      ];
      for (final phoneNumber in validPhoneNumbers) {
        expect(
          phoneNumber.isPhone,
          isTrue,
          reason: 'Phone number: $phoneNumber',
        );
      }
    });

    test('Invalid phone numbers', () {
      final invalidPhoneNumbers = [
        'abc', // Letters
        '++123 456 7890', // Double plus sign
        '+(123) 456 7890', // Plus sign with parenthesis
        '(91) 9 8222--4111', // Separators
        '91) 9 8222--4111', // Parenthesis without opening
        '(91 9 8222--4111', // Parenthesis without closing
        '(123)-456-7890', // Separator immediately after closing parenthesis
        '123-456-7890-', // Separator at the end
      ];
      for (final phoneNumber in invalidPhoneNumbers) {
        expect(
          phoneNumber.isPhone,
          isFalse,
          reason: 'Phone number: $phoneNumber',
        );
      }
    });
  });
}
