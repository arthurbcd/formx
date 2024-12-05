/// Extension for [String] for validations.
extension FormxAlphaNumExtension on String {
  /// Returns the alpha characters of this [String].
  String get alpha => replaceAll(RegExp('[^a-zA-Z]'), '');

  /// Returns `true` if this [String] contains only alpha characters.
  bool get isAlpha => RegExp(r'^[a-zA-Z]+$').hasMatch(this);

  /// Check if the string has at least one letter
  bool get hasAlpha => contains(RegExp('[a-zA-Z]'));

  /// Returns the numeric characters of this [String].
  String get numeric => replaceAll(RegExp('[^0-9]'), '');

  /// Returns `true` if this [String] contains only numeric characters.
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Check if the string has at least one number
  bool get hasNumeric => contains(RegExp(r'\d'));

  /// Returns the alphanumeric characters of this [String].
  String get alphanumeric => replaceAll(RegExp('[^a-zA-Z0-9]'), '');

  /// Returns `true` if this [String] contains only alphanumeric characters.
  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  /// Check if the string has at least one alphanumeric character
  bool get hasAlphanumeric => contains(RegExp('[a-zA-Z0-9]'));

  /// Check if the string has at least one uppercase letter
  bool get hasUppercase => contains(RegExp('[A-Z]'));

  /// Check if the string has at least one lowercase letter
  bool get hasLowercase => contains(RegExp('[a-z]'));

  /// Check if the string has at least one special character
  bool get hasSpecialCharacter => contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  /// Whether this is equals to [other], ignoring case.
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}

/// Extension for [String] for case utilities.
extension FormxStringCaseExtension on String {
  /// The initials of this string.
  /// - John Doe P. -> JD
  /// - John    -> J
  String get initials =>
      isEmpty ? '' : split(' ').map((e) => e[0]).take(2).join().toUpperCase();

  /// Returns a new [String] with the first letter capitalized.
  String capitalize() {
    if (isEmpty) return '';
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  /// Returns a new [String] with all words capitalized.
  String capitalizeWords() {
    return split(' ').map((e) => e.capitalize()).join(' ');
  }
}

/// A set of extensions for [String] for regex validations.
extension RegexValidatorsExtension on String {
  /// Returns `true` if this [String] is a valid email.
  bool get isEmail => RegExp(
        r"^((([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+(\.([a-z]|\d|[!#\$%&'\*\+\-\/=\?\^_`{\|}~]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+)*)|((\x22)((((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(([\x01-\x08\x0b\x0c\x0e-\x1f\x7f]|\x21|[\x23-\x5b]|[\x5d-\x7e]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(\\([\x01-\x09\x0b\x0c\x0d-\x7f]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF]))))*(((\x20|\x09)*(\x0d\x0a))?(\x20|\x09)+)?(\x22)))@((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))$",
      ).hasMatch(this);

  /// Returns `true` if this [String] is a valid url with HTTP/HTTPS protocols.
  bool get isHttpUrl => RegExp(
        r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      ).hasMatch(this);

  /// Returns `true` if this [String] is a valid url. Ignores HTTP protocols.
  bool get isUrl => RegExp(
        r'[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
      ).hasMatch(this);

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

  /// Returns `true` if this [String] is a valid Credit Card.
  bool get isCreditCard {
    final isValid = RegExp(
      r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$',
    ).hasMatch(this);

    if (!isValid) return false;

    // Luhn algorithm
    var sum = 0;
    String digit;
    var shouldDouble = false;

    for (var i = length - 1; i >= 0; i--) {
      digit = substring(i, i + 1);
      var tmpNum = int.parse(digit);

      if (shouldDouble) {
        tmpNum *= 2;
        if (tmpNum >= 10) {
          sum += (tmpNum % 10) + 1;
        } else {
          sum += tmpNum;
        }
      } else {
        sum += tmpNum;
      }
      shouldDouble = !shouldDouble;
    }

    return (sum % 10 == 0);
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
}

/// Extension for [List<String>] for validations.
extension ListStringValidatorExtension on List<String> {
  /// Whether this list contains [value], ignoring case.
  bool containsIgnoreCase(String value) =>
      any((e) => e.equalsIgnoreCase(value));
}
