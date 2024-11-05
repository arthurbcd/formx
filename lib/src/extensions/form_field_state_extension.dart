import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../models/field_key.dart';
import '../models/formx_options.dart';
import '../validator/validator.dart';
import 'sanitizers.dart';

/// Signature for binding a [FormFieldState] to a [FormFieldValidator].
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
  /// Whether [FormFieldState.value] is the same as [FormField.initialValue].
  bool get isInitial => value == widget.initialValue;

  /// Returns the [FormFieldState.value] as a [DateTime].
  DateTime? get date => value?.tryCast<DateTime>() ?? DateTime.tryParse(text);

  /// The [FieldAdapter] of this [FormFieldState].
  FieldKey<T>? get fieldKey {
    return widget.key?.tryCast<FieldKey<T>>();
  }

  /// The [Key] `value` of this [FormFieldState].
  String? get key => widget.key?.value;

  /// Returns the [FormFieldState.value] as a [num].
  num? get number => value?.tryCast<num>() ?? num.tryParse(text);

  /// Returns the [FormFieldState.value] as a [String].
  String get text => value?.toString() ?? '';

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

  /// Returns the [FormFieldState.value] adapted with [FieldKey.adapter].
  Object? get valueAdapted {
    final fn = fieldKey?.maybeAdapt;
    if (fn == null || value == null) return value;

    return fn(value!);
  }

  /// Whether [value] is empty.
  bool? get isEmpty {
    final value = this.value;
    if (value is String) return value.isEmpty;
    if (value is Iterable) return value.isEmpty;
    if (value is Map) return value.isEmpty;
    return null;
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

    return options.unmasker(state.value ?? '', field.inputFormatters ?? []);
  }
}
