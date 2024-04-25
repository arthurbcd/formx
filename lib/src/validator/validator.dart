import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../extensions/form_field_state_extension.dart';

/// A class that handles the validation of a [FormField].
///
/// It can be used as a [FormField.validator] or as a programatic way to set
/// errorTexts, declaratively or imperatively.
class Validator<T> {
  /// Creates a [Validator] that handles [FormField] validation declaratively.
  ///
  /// - [isRequired] - Whether this field is required.
  /// - [test] - The test to check if the value is valid.
  /// - [requiredText] - The required text to show when the field is empty.
  /// - [invalidText] - The invalid text to show when the field is invalid.
  Validator({
    String? key,
    ValidatorTest<T>? test,
    this.isRequired = false,
    this.requiredText,
    this.invalidText,
    List<Validator<T>>? validators,
  })  : _key = key,
        _test = test {
    if (validators != null) this.validators.addAll(validators);
  }

  /// Shorthand to [Validator.new] with a [test] and an optional [invalidText].
  Validator.test(
    ValidatorTest<T> test, [
    this.invalidText,
  ])  : _key = null,
        _test = test,
        isRequired = false,
        requiredText = null;

  /// The test to check if the value is valid.
  ///
  /// Always called after [isRequired] check. So value is never null or empty.
  final ValidatorTest<T>? _test;

  /// Whether this field is required.
  final bool isRequired;

  /// The required text to show when the field is empty.
  ///
  /// Defaults to [Validator.defaultRequiredText].
  final String? requiredText;

  /// The invalid text to show when the field is invalid.
  ///
  /// Defaults to [Validator.defaultInvalidText].
  final String? invalidText;

  /// Additional validators to be merged with this one.
  final List<Validator<T>> validators = [];

  /// The default required text.
  static String defaultRequiredText = 'Required value';

  /// The default invalid text.
  static String defaultInvalidText = 'Invalid value';

  /// Whether to disable all [Validator]'s on debug mode.
  static bool disableOnDebug = false;

  /// Modifies the `errorText` returned by [Validator].
  static ValidatorModifier modifier = (validator, errorText) => errorText;

  // States
  String? _errorText;
  FormFieldState? _state;
  final String? _key;

  /// The [Key] value of the [FormField] that this [Validator] is attached.
  String? get key => _key ?? _state?.widget.key?.value;

  /// The resolved [FormField.validator] for this [Validator].
  FormFieldValidator<Object> get validator {
    return (value) {
      // 0. Check if it is disabled.
      if (Validator.disableOnDebug && kDebugMode) return null;

      // 1. Check if errorText was set programatically.
      if (_errorText case String errorText) {
        _errorText = null;
        return errorText;
      }

      // 2. Check if it is required.
      if (value == null || value.isEmpty) {
        return isRequired ? requiredText ?? defaultRequiredText : null;
      }

      // 3. Check if it passes the test.
      if (_test != null && value is T) {
        if (!_test(value as T)) return invalidText ?? defaultInvalidText;
      }

      // 4. Check if any other merged validator are valid.
      for (final validator in validators) {
        if (validator(value) case String errorText) return errorText;
      }

      return null;
    };
  }

  /// Caller for [validator].
  ///
  /// Applies the [Validator.modifier] before calling it.
  String? call(Object? value) {
    if (value case FormFieldData data) {
      if (data.errorText != null) _errorText = data.errorText;
      _state = data.state;
      return null;
    }

    if (validator(value) case String errorText) {
      return modifier(this, errorText);
    }

    return null;
  }
}

/// Signature for testing a value.
typedef ValidatorTest<T> = bool Function(T value);

/// Signature for modifying a [Validator] behavior.
typedef ValidatorModifier = String Function(
  Validator validator,
  String errorText,
);

extension on Object {
  bool get isEmpty {
    if (this case Iterable e) return e.isEmpty;
    if (this case String e) return e.isEmpty;
    if (this case Map e) return e.isEmpty;
    return false;
  }
}

/// Extension for [Key] value.
extension StringValueKeyExtension on Key {
  /// Attempts to get the [value] of this [Key] if it is an [String].
  String? get value {
    if (this case ValueKey(:String value)) return value;
    if (this case ObjectKey(:String value)) return value;
    if (this case GlobalObjectKey(:String value)) return value;
    return null;
  }
}
