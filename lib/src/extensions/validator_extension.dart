import '../validator/validator.dart';

/// Extension for [Map] to convert it to an indented [String].





/// Extension for [Validator] to add syntactic sugar.
extension ValidatorExtension<T> on Validator<T> {
  /// Returns a copy of this [Validator] with the new values.
  // Validator<T> copyWith({
  //   ValidatorTest<T>? test,
  //   bool? isRequired,
  //   String? requiredText,
  //   String? invalidText,
  // }) {
  //   return Validator(
  //     test: test ?? _test,
  //     isRequired: isRequired ?? this.isRequired,
  //     requiredText: requiredText ?? this.requiredText,
  //     invalidText: invalidText ?? this.invalidText,
  //   );
  // }

  /// Sets [Validator.isRequired] to `true`.
  // Validator<T> required([String? requiredText]) {
  //   return copyWith(isRequired: true, requiredText: requiredText);
  // }

  /// Sets [ValidatorTest]. Optionally, you can set [invalidText].
  // Validator<T> test(ValidatorTest<T> test, [String? invalidText]) {
  //   return this..add(copyWith(test: test, invalidText: invalidText).validat);
  // }

  // /// Sets [ValidatorTest] that callbacks the value as a [num].
  // Validator<T> number(ValidatorTest<num> test, [String? invalidText]) {
  //   return this.test(
  //     (value) {
  //       if (value is num) return test(value);
  //       if (num.tryParse('$value') case num number) return test(number);
  //       return true;
  //     },
  //     invalidText,
  //   );
  // }

  // /// Sets [ValidatorTest] to check if the value is not null or empty.
  // Validator<T> notEquals(Object value, [String? invalidText]) {
  //   return test((val) => val != value, invalidText);
  // }

  // /// Sets [ValidatorTest] to check if the value is equals to [value].
  // Validator<T> equals(Object value, [String? invalidText]) {
  //   return test((val) => val == value, invalidText);
  // }

  // /// Sets [ValidatorTest] to check if the value is greater than [value].
  // Validator<T> contains(Object value, [String? invalidText]) {
  //   return test((val) => '$val'.contains('$value'), invalidText);
  // }

  // /// Validates the minimum length of the value.
  // Validator<T> min(int length, [String? invalidText]) {
  //   return test((value) => '$value'.length >= length, invalidText);
  // }

  // /// Validates the maximum length of the value.
  // Validator<T> max(int length, [String? invalidText]) {
  //   return test((value) => '$value'.length <= length, invalidText);
  // }

  // /// Validates the length range of the value.
  // Validator<T> range(int min, int max, [String? invalidText]) {
  //   return test(
  //     (value) => '$value'.length >= min && '$value'.length <= max,
  //     invalidText,
  //   );
  // }

  // /// Validates [RegExp] pattern.
  // Validator<T> pattern(RegExp pattern, [String? invalidText]) {
  //   return test((val) => pattern.hasMatch('$val'), invalidText);
  // }

  // /// Validates if the value is one of the [list].
  // Validator<T> oneOf(List<T> list, [String? invalidText]) {
  //   return test((val) => list.contains(val), invalidText);
  // }

  // /// Validates if the value is not one of the [list].
  // Validator<T> notOneOf(List<T> list, [String? invalidText]) {
  //   return test((val) => !list.contains(val), invalidText);
  // }
}
