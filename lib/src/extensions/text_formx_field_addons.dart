import 'package:flutter/material.dart';

import '../widgets/text_formx_field.dart';
import 'text_formx_field_copy_with.dart';

/// Addons extension for [TextFormxField].
///
/// These are some examples of how powerful copyWith is.
/// Use as reference and create your own extensions.
extension TextFormxFieldAddons on TextFormxField {
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

  /// Adds a num formatter and num validator. Stackable.
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

  /// Adds a icon button to obscure the field.
  TextFormxField obscure({
    bool init = true,
    Widget on = const Icon(Icons.visibility),
    Widget off = const Icon(Icons.visibility_off),
  }) {
    var obscure = init;
    return copyWith(
      obscureText: obscure,
      decoration: (decoration ?? const InputDecoration()).copyWith(
        suffixIcon: StatefulBuilder(
          builder: (context, setState) {
            return IconButton(
              icon: obscure ? off : on,
              onPressed: () {
                setState(() {
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
  }
}
