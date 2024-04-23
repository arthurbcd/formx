import 'package:flutter/cupertino.dart';

import '../../formx.dart';

/// Extends [FormFieldState] with a programatic way to set [errorText].
extension FormFieldStateExtension on FormFieldState {
  /// The [Key] `value` of this [FormFieldState].
  String? get key => widget.key?.value;

  /// Sets the [errorText] programatically.
  ///
  /// You need to set a [Validator] to use this method.
  void setErrorText(String? errorText) {
    _attachToValidator(errorText: errorText);
    validate();
  }

  void _attachToValidator({String? errorText}) {
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
