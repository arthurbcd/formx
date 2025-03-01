import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../formatter/formatter.dart';
import '../models/field_key.dart';
import '../models/formx_exception.dart';
import '../models/formx_options.dart';
import '../validator/validator.dart';
import 'sanitizers.dart';

/// Signature for attaching a [FormFieldState] to a [FormFieldValidator].
typedef FormFieldData<T> = ({FormFieldState<T> state, String? errorText});

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

/// Extends [FormFieldState] with a programatic way to set [errorText].
extension FormFieldStateExtension<T> on FormFieldState<T> {
  /// The [Key] `value` of this [FormFieldState].
  String? get key => widget.key?.value;

  /// The options of this [FormField].
  FieldKey<T>? get fieldKey => widget.key?.tryCast<FieldKey<T>>();

  /// Whether [FormFieldState.value] is the same as [FormField.initialValue].
  bool get isInitial => value == widget.initialValue;

  /// Returns the [FormFieldState.value] as a [String].
  String get text => value?.toString() ?? '';

  /// Returns the [FormFieldState.value] as a [num].
  num? get number => value?.tryCast<num>() ?? num.tryParse(text);

  /// Returns the [FormFieldState.value] as a [DateTime].
  DateTime? get date =>
      value?.tryCast<DateTime>() ??
      DateTime.tryParse(text) ??
      Localizations.of<MaterialLocalizations>(context, MaterialLocalizations)
          ?.parseCompactDate(text);

  /// Whether [value] is empty.
  bool? get isEmpty {
    final value = this.value;
    if (value is String) return value.isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return null;
  }

  /// Returns the [FormFieldState.value] modified by form/field options.
  Object? toValue({FormxOptions? options}) {
    Object? value = this.value;
    if (value == null) return null;

    // options
    options = getOptions(options);

    // unmask
    if (widget case TextFormField it when !options.keepMask) {
      value = it.maybeUnmask(cast(), options);
    }

    // adapter
    return options.adapter(value);
  }

  /// Performs [validate], [save], and returns [toValue] with [options].
  /// Throws a [FormxException] if field is invalid.
  Object? submit({FormxOptions? options, String? errorMessage}) {
    if (!validate()) {
      throw FormxException({key ?? '': errorText ?? ''}, errorMessage);
    }
    save();
    return toValue(options: options);
  }

  /// Performs [validate], [save], and returns [toValue] with [options].
  /// Returns `null` if field is invalid.
  Object? trySubmit({FormxOptions? options}) {
    try {
      return submit(options: options);
    } catch (_) {
      return null;
    }
  }

  /// Sets the [errorText] of this [FormFieldState].
  void setErrorText(String? errorText) {
    attachToValidator(errorText: errorText);
    validate();
  }
}

/// Extension for XFile.
extension TimestampName on XFile {
  /// Returns the [XFile] with a timestamp instead of the original name.
  /// Example: `image_name.jpg` -> `1632345678901.jpg`.
  String get timestampName {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '$timestamp.$extension';
  }

  /// Returns the extension of the file.
  String get extension => name.split('.').last;
}

extension on TextFormField {
  /// Attempts to unmask the [FormFieldState.value] of this [TextFormField].
  ///
  /// Returns the unmasked value or the original value.
  String maybeUnmask(FormFieldState<String> state, FormxOptions options) {
    final field = (builder(state) as dynamic).child as TextField;
    final value = state.value ?? '';

    if (field.inputFormatters case var it?) {
      // when in initial state, formatter is still not applied, so we do it
      final formatted = state.isInitial
          ? it.fold<String>(value, (value, f) => f.format(value))
          : value;

      for (final formatter in it) {
        if (options.unmasker(formatted, formatter) case var it?) return it;
      }
    }

    return value;
  }
}
