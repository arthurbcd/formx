import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

void main() {
  test('Test CNPJ random', () {
    expect('12.175.094/0001-19'.isCnpj, true);
    expect('12.175.094/0001-18'.isCnpj, false);
    expect('17942159000128'.isCnpj, true);
    expect('17942159000128@mail.com'.isCnpj, false);
    expect('17942159000128'.isCnpj, true);
    expect('17942159000127'.isCnpj, false);
    expect('017942159000128'.isCnpj, false);

    var valids = [
      '87.837.979/0001-35',
      '88.412.860/0001-83',
      '47.703.549/0001-06',
      '12.401.581/0001-52',
      '65.486.858/0001-53',
      '98.249.110/0001-96',
      '85.137.090/0001-10',
      '35.736.071/0001-31',
      '03965584000128',
    ];

    var invalids = [
      '00000000000000',
      '11111111111111',
      '22222222222222',
      '33333333333333',
      '44444444444444',
      '55555555555555',
      '66666666666666',
      '77777777777777',
      '88888888888888',
      '99999999999999',
      '87.837.979/0001-34',
      '88.412.860/0001-82',
      '47.703.549/0001-05',
      '12.401.581/0001-51',
      '65.486.858/0001-52',
      '98.249.110/0001-95',
      '85.137.090/0001-11',
      '35.736.071/0001-30',
      '13965584000128',
    ];

    for (final value in valids) {
      expect(value.isCnpj, true);
    }

    for (final value in invalids) {
      expect(value.isCnpj, false);
    }
  });
}
