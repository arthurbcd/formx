// ignore_for_file: cast_nullable_to_non_nullable

import 'package:flutter/cupertino.dart';

import '../../formx.dart';

/// Extends [FormFieldState] with a programatic way to set [errorText].
extension FormFieldStateExtension<T> on FormFieldState<T> {
  /// The [Key] `value` of this [FormFieldState].
  String? get key => widget.key?.value;

  /// Sets the [errorText] programatically.
  ///
  /// You need to set a [Validator] to use this method.
  void setErrorText(String? errorText) {
    attachToValidator(errorText: errorText);
    validate();
  }

  /// Returns the [FormFieldState.value] as a [String].
  String get string => value?.toString() ?? '';

  /// Returns the [FormFieldState.value] as a [num].
  num get number => value is num ? value as num : num.tryParse(string) ?? 0;
}

/// Attaches a [FormFieldState] to a [Validator].
extension FormFieldStateAttacher on FormFieldState {
  /// Attaches this [FormFieldState] to the [Validator].
  @protected
  void attachToValidator({String? errorText}) {
    final FormFieldData data;
    try {
      data = (
        state: this,
        errorText: errorText,
      );
      widget.validator?.call(data);
    } catch (_) {
      assert(
        errorText == null,
        'No `Validator` was set for this `$this`.\n'
        'You must set `Validator` class in order to call `setErrorText`.\n'
        'Ex:\n'
        '```dart\n'
        'TextFormField(\n'
        "   key: const Key('email'),\n "
        '  validator: Validator(), // <-- set your `Validator` here\n'
        ')\n'
        '```\n'
        'Then call:\n'
        '```dart\n'
        "emailState?.setErrorText('errorText');\n"
        '```\n',
      );
    }
  }
}

/// Signature for binding a [FormFieldState] to a [FormFieldValidator].
typedef FormFieldData = ({FormFieldState state, String? errorText});
