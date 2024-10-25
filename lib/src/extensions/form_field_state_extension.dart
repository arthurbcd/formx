// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';
import 'package:material_file_icon/material_file_icon.dart';

import '../models/field_key.dart';
import '../models/formx_options.dart';
import '../validator/validator.dart';
import 'field_key_extension.dart';
import 'formx_extension.dart';
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
  String get text {
    if (value is DateTime) {
      return Formx.options.dateAdapter(value! as DateTime)?.toString() ?? '';
    }
    if (value is Enum) {
      return Formx.options.enumAdapter(value! as Enum)?.toString() ?? '';
    }
    return value?.toString() ?? '';
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

/// Extension for `FieldKey<List<T>>`.
extension ListFieldKeyExtension<T> on FieldKey<List<T>> {
  /// Adapts List [T] by mapping [toElement] in `FormState.values`.
  FieldKey<List<T>> map(dynamic Function(T e) toElement) {
    return copyWith(adapter: (value) => value.map(toElement).toList());
  }
}

/// Extension for `FieldKey<String>`.
extension NumberFieldKeyExtension on FieldKey<String> {
  /// Adapts [String] `value` to [Color] in `FormState.values`.
  FieldKey<String> toColor() {
    return copyWith(
      adapter: (value) {
        if (value.startsWith('#')) value = value.substring(1);
        if (value.length == 6) value = 'FF$value';
        if (value.length != 8) return null;

        final colorValue = int.tryParse(value, radix: 16);
        return colorValue != null ? Color(colorValue) : null;
      },
    );
  }

  /// Adapts [String] `value` to [double] in `FormState.values`.
  FieldKey<String> toDouble() {
    return copyWith(adapter: double.tryParse);
  }

  /// Adapts [String] `value` to [int] in `FormState.values`.
  FieldKey<String> toInt() {
    return copyWith(adapter: int.tryParse);
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
