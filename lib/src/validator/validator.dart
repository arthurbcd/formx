import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../extensions/form_field_state_extension.dart';
import '../models/field_key.dart';

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
  static String defaultRequiredText = 'form.required';

  /// The default invalid text.
  static String defaultInvalidText = 'form.invalid';

  /// Whether to disable all [Validator]'s on debug mode.
  static bool disableOnDebug = false;

  /// Modifies the `errorText` returned by [Validator], if not manually set.
  static ValidatorModifier translator = (key, errorText) => errorText;

  // States
  String? _errorText;
  FormFieldState<T>? _state;
  final String? _key;

  /// The [Key] value of the [FormField] that this [Validator] is attached.
  String? get key => _key ?? _state?.widget.key?.value;

  /// The [FormFieldState] of the [FormField] that this [Validator] is attached.
  FormFieldState<T>? get state => _state;

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
      if (value == null || value.isEmpty || value == false) {
        var e = validators.firstWhere((e) => e.isRequired, orElse: () => this);
        return e.isRequired ? e.requiredText ?? defaultRequiredText : null;
      }

      // 3. Check if it passes the test.
      if (_test != null && value is T) {
        if (!_test(value as T)) return invalidText ?? defaultInvalidText;
      }

      // 4. Check if any other merged validator are valid.
      for (final e in validators) {
        if (e.validator(value) case String errorText) return errorText;
      }

      return null;
    };
  }

  /// Caller for [validator].
  ///
  /// Applies the [Validator.translator] before calling it.
  String? call(Object? value) {
    if (value case FormFieldData<T> data) {
      if (data.errorText != null) _errorText = data.errorText;
      _state = data.state;
      return null;
    }

    if (validator(value) case String errorText) {
      if (defaultInvalidText == errorText) return translator(key, errorText);
      if (defaultRequiredText == errorText) return translator(key, errorText);
      return errorText;
    }

    return null;
  }

  /// Adds other [Validator] to this one.
  Validator<T> addValidator(Validator<T> other) => this..validators.add(other);
}

/// Signature for testing a value.
typedef ValidatorTest<T> = bool Function(T value);

/// Signature for modifying a [Validator] behavior.
typedef ValidatorModifier = String Function(
  String? key,
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

/// A Validator that accepts either this or [other].
class OrValidator<T> extends Validator<T> {
  /// Creates a [OrValidator].
  OrValidator(this.other);

  /// The other validator to be used.
  final Validator other;

  @override
  FormFieldValidator<Object> get validator {
    return (value) {
      final errors = (other.validator(value), super.validator(value));

      if (errors case (var error1?, var error2?)) {
        if (error1 == Validator.defaultInvalidText) return error2;
        if (error2 == Validator.defaultInvalidText) return error1;
        return '$error1; $error2';
      }

      return null;
    };
  }
}
