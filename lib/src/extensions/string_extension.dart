import 'package:string_validator/string_validator.dart' as lib;

/// Extension for [String] for validations.
extension StringValidatorExtension on String {
  /// Whether is a valid email.
  bool get isEmail => lib.isEmail(this);

  /// Where it contains only letters.
  bool get isAlpha => lib.isAlpha(this);

  /// Where it contains only numbers.
  bool get isNumeric => lib.isNumeric(this);

  /// Where it contains only letters and numbers.
  bool get isAlphanumeric => lib.isAlphanumeric(this);

  /// Whether is a valid parseable DateTime.
  bool get isDate => lib.isDate(this);

  /// Whether is a valid credit card number.
  bool get isCreditCard => lib.isCreditCard(this);

  /// Whether is a valid URL.
  bool get isUrl => lib.isURL(this);

  /// Check if the string has at least one number
  bool get hasNumeric => contains(RegExp(r'\d'));

  /// Check if the string has at least one letter
  bool get hasAlpha => contains(RegExp('[a-zA-Z]'));

  /// Check if the string has at least one alphanumeric character
  bool get hasAlphanumeric => contains(RegExp('[a-zA-Z0-9]'));

  /// Check if the string has at least one uppercase letter
  bool get hasUppercase => contains(RegExp('[A-Z]'));

  /// Check if the string has at least one lowercase letter
  bool get hasLowercase => contains(RegExp('[a-z]'));

  /// Check if the string has at least one special character
  bool get hasSpecialCharacter => contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  /// Whether is a valid phone number.
  ///
  /// International phone numbers are supported.
  /// +1 (555) 555-5555
  /// +33 6 12 34 56 78
  /// +55 15 12345-6789
  /// (99) 9 8888-4444
  /// +123456789
  ///
  /// Allowed: +, -, ., space, and parenthesis.
  /// Duplicated plus signs or separators are not allowed.
  /// Optional parenthesis, but must open and close.
  /// Must end with a number.
  bool get isPhone => RegExp(
        r'^(?:\+[0-9]+(?:[-. ]?[0-9]+)*)?(?: ?\([0-9]{1,4}\))? ?[0-9]+(?:[-. ]?[0-9]+)*$',
      ).hasMatch(this);

  /// Whether is a valid cnpj. Special characters are ignored.
  bool get isCnpj {
    if (RegExp('[a-zA-Z]').hasMatch(this)) return false;

    final cnpj = replaceAll(RegExp(r'\D'), '');

    if (cnpj.length != 14) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

    int digit(String digits, List<int> weights) {
      var sum = 0;
      for (var i = 0; i < digits.length; i++) {
        sum += int.parse(digits[i]) * weights[i];
      }
      final mod = sum % 11;
      return mod < 2 ? 0 : 11 - mod;
    }

    final weight1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    final weight2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

    final d1 = digit(cnpj.substring(0, 12), weight1);
    final d2 = digit(cnpj.substring(0, 12) + d1.toString(), weight2);

    return cnpj.substring(12) == d1.toString() + d2.toString();
  }

  /// Whether is a valid cpf. Special characters are ignored.
  bool get isCpf {
    if (RegExp('[a-zA-Z]').hasMatch(this)) return false;

    final cpf = replaceAll(RegExp(r'\D'), '');
    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) return false;
    var sum1 = 0;
    var sum2 = 0;
    for (var i = 0; i < 9; i++) {
      sum1 += int.parse(cpf[i]) * (10 - i);
    }
    var digit1 = (sum1 % 11 < 2) ? 0 : 11 - (sum1 % 11);
    for (var i = 0; i < 10; i++) {
      sum2 += int.parse(cpf[i]) * (11 - i);
    }
    var digit2 = (sum2 % 11 < 2) ? 0 : 11 - (sum2 % 11);
    return int.parse(cpf[9]) == digit1 && int.parse(cpf[10]) == digit2;
  }

  /// Whether this is equals to [other], ignoring case.
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}

/// Extension for [List<String>] for validations.
extension ListStringValidatorExtension on List<String> {
  /// Whether this list contains [value], ignoring case.
  bool containsIgnoreCase(String value) =>
      any((e) => e.equalsIgnoreCase(value));
}
