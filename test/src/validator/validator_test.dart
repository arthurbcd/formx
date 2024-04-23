import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

void main() {
  test('CPF Validation', () {
    for (final cpf in validCPFs) {
      expect(
        cpf.isCpf,
        isTrue,
        reason: 'CPF: $cpf',
      );
    }
    for (final cpf in invalidCPFs) {
      expect(
        cpf.isCpf,
        isFalse,
        reason: 'CPF: $cpf',
      );
    }
  });
}

final validCPFs = [
  '529.982.247-25',
  '52998224725',
  '529.982.247-25',
  '123.456.789-09',
  '028.855.853-74',
  '662.305.114-79',
  '106.831.383-83',
  '113.411.555-52',
  '271.642.337-72',
  '125.487.014-84',
  '367.420.166-63',
  '175.671.355-31',
  '313.453.216-60',
  '468.133.648-39',
  '601.087.101-81',
  '552.373.751-89',
  '021.056.257-97',
  '752.172.345-71',
  '453.834.471-05',
];

final invalidCPFs = [
  'abc', // Letters
  '111.111.111-11', // All digits are the same
  '123.456.789-00', // Invalid verification digits
  '12345678901234567890', // More than 11 digits
  '000.000.000-00',
  '111.111.111-11',
  '222.222.222-22',
  '333.333.333-33',
  '444.444.444-44',
  '555.555.555-55',
  '666.666.666-66',
  '777.777.777-77',
  '888.888.888-88',
  '999.999.999-99',
  '12345678900',
  '98765432109',
  '45612378900',
  '12345678901',
  '98765432108',
  '123456789012',
  '987654321098',
  '1234567890',
  '9876543210',
  '123456789',
];
