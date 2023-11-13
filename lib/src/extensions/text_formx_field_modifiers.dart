import 'package:flutter/material.dart';

import '../widgets/text_formx_field.dart';
import 'text_formx_field_copy_with.dart';

/// Extension modifiers for [TextFormxField].
///
/// These are some examples of how powerful copyWith is.
/// Use as reference and create your own extensions.
extension TextFormxFieldModifiers on TextFormxField {
  /// Adds a traditional validator to the field. Stackable.
  TextFormxField addValidator(FormFieldValidator<String> validator) {
    return copyWith(
      validator: (value) {
        return this.validator?.call(value) ?? validator(value);
      },
    );
  }

  /// Adds a validator with condition [isValid]. Stackable.
  ///
  /// You can override all [errorText] with `Formx.onErrorText` callback.
  TextFormxField validate(
    bool Function(String value) isValid, [
    String errorText = 'form.invalid',
  ]) {
    return addValidator((value) {
      if (value == null) return null;
      if (isValid(value)) return null;
      return errorText;
    });
  }

  /// Adds a num validator. Stackable.
  ///
  /// You can override all [invalidText] with `Formx.onErrorText` callback.
  TextFormxField validateNum(
    bool Function(num value) isValid, [
    String invalidText = 'form.invalid',
  ]) {
    return validate(
      (value) {
        final number = num.tryParse(value);
        return number != null && isValid(number);
      },
    ).copyWith(
      keyboardType: TextInputType.number,
      // inputFormatters: {
      //   ...?field.inputFormatters,
      //   FilteringTextInputFormatter.digitsOnly,
      // }.toList(),
    );
  }

  /// Adds a validator that checks if the value is not null or empty.
  ///
  /// You can override all [errorText] with `Formx.onErrorText` callback.
  TextFormxField required([String errorText = 'form.required']) {
    return addValidator((value) {
      if (value == null) return errorText;
      if (value.isEmpty) return errorText;
      return null;
    });
  }

  /// Adds an suffixIcon to obscure the field.
  TextFormxField obscure({
    bool init = true,
    bool required = true,
    Widget on = const Icon(Icons.visibility),
    Widget off = const Icon(Icons.visibility_off),
  }) {
    var obscure = init;

    var field = copyWith(
      obscureText: obscure,
      decoration: decoration?.copyWith(
        suffixIcon: StatefulBuilder(
          builder: (context, setState) {
            return IconButton(
              icon: obscure ? off : on,
              onPressed: () {
                setState(() {
                  // convenient way to update the field programmatically.
                  TextFormxField.of(context).update((f) {
                    return f.copyWith(obscureText: obscure = !f.obscureText);
                  });
                });
              },
            );
          },
        ),
      ),
    );

    if (required) {
      field = field.required();
    }
    return field;
  }
}
