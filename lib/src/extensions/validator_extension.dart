import '../validator/validator.dart';
import 'string_extension.dart';

/// Extension for [Map] to convert it to an indented [String].

/// Extension for [Validator] to add syntactic sugar.
extension ValidatorExtension<T> on Validator<T> {
  /// Sets [Validator.isRequired] to `true`.
  Validator<T> required([String? requiredText]) {
    return this
      ..validators.add(
        Validator<T>(isRequired: true, requiredText: requiredText),
      );
  }

  /// Sets [ValidatorTest]. Optionally, you can set [invalidText].
  Validator<T> test(ValidatorTest<T> test, [String? invalidText]) {
    return this
      ..validators.add(
        Validator<T>(test: test, invalidText: invalidText),
      );
  }

  /// Sets [ValidatorTest] that callbacks the value as a [num].
  Validator<T> number(ValidatorTest<num> test, [String? invalidText]) {
    return this.test(
      (value) {
        if (value is num) return test(value);
        if (num.tryParse('$value') case num number) return test(number);
        return true;
      },
      invalidText,
    );
  }

  /// Sets [ValidatorTest] that callbacks the value as a [DateTime].
  Validator<T> datetime(ValidatorTest<DateTime> test, [String? invalidText]) {
    return this.test(
      (value) {
        if (value is DateTime) return test(value);
        if (DateTime.tryParse('$value') case DateTime date) return test(date);
        return true;
      },
      invalidText,
    );
  }

  /// Tests if the value is a valid email.
  Validator<T> email([String? invalidText]) {
    return test((value) => '$value'.isEmail, invalidText);
  }

  /// Tests if the value is a valid URL.
  Validator<T> url([String? invalidText]) {
    return test((value) => '$value'.isUrl, invalidText);
  }

  /// Tests if the value is a valid phone number.
  Validator<T> phone([String? invalidText]) {
    return test((value) => '$value'.isPhone, invalidText);
  }

  /// Tests if the value is a valid credit card number.
  Validator<T> creditCard([String? invalidText]) {
    return test((value) => '$value'.isCreditCard, invalidText);
  }

  /// Tests if the value is a valid CPF.
  Validator<T> cpf([String? invalidText]) {
    return test((value) => '$value'.isCpf, invalidText);
  }

  /// Tests if the value is a valid CNPJ.
  Validator<T> cnpj([String? invalidText]) {
    return test((value) => '$value'.isCnpj, invalidText);
  }

  /// Tests if the value is a valid date.
  Validator<T> date([String? invalidText]) {
    return test((value) => '$value'.isDate, invalidText);
  }

  /// Tests if the value is only letters.
  Validator<T> alpha([String? invalidText]) {
    return test((value) => '$value'.isAlpha, invalidText);
  }

  /// Tests if the value is only numbers.
  Validator<T> numeric([String? invalidText]) {
    return test((value) => '$value'.isNumeric, invalidText);
  }

  /// Tests if the value is only letters and numbers.
  Validator<T> alphanumeric([String? invalidText]) {
    return test((value) => '$value'.isAlphanumeric, invalidText);
  }

  /// Tests if the value has at least one number.
  Validator<T> hasNumeric([String? invalidText]) {
    return test((value) => '$value'.hasNumeric, invalidText);
  }

  /// Tests if the value has at least one letter.
  Validator<T> hasAlpha([String? invalidText]) {
    return test((value) => '$value'.hasAlpha, invalidText);
  }

  /// Tests if the value has at least one alphanumeric character.
  Validator<T> hasAlphanumeric([String? invalidText]) {
    return test((value) => '$value'.hasAlphanumeric, invalidText);
  }

  /// Tests if the value has at least one uppercase letter.
  Validator<T> hasUppercase([String? invalidText]) {
    return test((value) => '$value'.hasUppercase, invalidText);
  }

  /// Tests if the value has at least one lowercase letter.
  Validator<T> hasLowercase([String? invalidText]) {
    return test((value) => '$value'.hasLowercase, invalidText);
  }

  /// Tests if the value has at least one special character.
  Validator<T> hasSpecialCharacter([String? invalidText]) {
    return test((value) => '$value'.hasSpecialCharacter, invalidText);
  }

  /// Validates the minimum length of the value.
  Validator<T> minLength(int length, [String? invalidText]) {
    return test((value) => '$value'.length >= length, invalidText);
  }

  /// Validates the maximum length of the value.
  Validator<T> maxLength(int length, [String? invalidText]) {
    return test((value) => '$value'.length <= length, invalidText);
  }

  /// Validates the minimum length of the value in words.
  Validator<T> minWords(int words, [String? invalidText]) {
    return test((value) => '$value'.split(' ').length >= words, invalidText);
  }

  /// Validates the maximum length of the value in words.
  Validator<T> maxWords(int words, [String? invalidText]) {
    return test((value) => '$value'.split(' ').length <= words, invalidText);
  }

  /// Validates the minimum value of a number.
  Validator<T> minNumber(num number, [String? invalidText]) {
    return this.number((value) => value >= number, invalidText);
  }

  /// Validates the maximum value of a number.
  Validator<T> maxNumber(num number, [String? invalidText]) {
    return this.number((value) => value <= number, invalidText);
  }

  /// Validates the minimum value of a date.
  Validator<T> isAfter(DateTime date, [String? invalidText]) {
    return datetime((value) => value.isAfter(date), invalidText);
  }

  /// Validates the maximum value of a date.
  Validator<T> isBefore(DateTime date, [String? invalidText]) {
    return datetime((value) => value.isBefore(date), invalidText);
  }
}
