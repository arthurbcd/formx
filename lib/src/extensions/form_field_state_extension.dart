// ignore_for_file: cast_nullable_to_non_nullable, overridden_fields

// Generated by Dart Safe Data Class Generator. * Change this header on extension settings *
// ignore_for_file: type=lint
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../formx.dart';

/// Extends [FormFieldState] with a programatic way to set [errorText].
extension FormFieldStateExtension<T> on FormFieldState<T> {
  /// The [Key] `value` of this [FormFieldState].
  String? get key => widget.key?.value;

  /// The [FieldAdapter] of this [FormFieldState].
  FieldKey<T>? get fieldKey {
    return widget.key?.tryCast<FieldKey<T>>();
  }

  /// Sets the [errorText] programatically.
  ///
  /// You need to set a [Validator] to use this method.
  void setErrorText(String? errorText) {
    attachToValidator(errorText: errorText);
    validate();
  }

  /// Returns the [FormFieldState.value] as a [String].
  @Deprecated('Use `.text` instead.')
  String get string => value?.toString() ?? '';

  /// Returns the [FormFieldState.value] as a [String].
  String get text {
    if (value is DateTime) {
      return Formx.options.dateAdapter(value as DateTime)?.toString() ?? '';
    }
    if (value is Enum) {
      return Formx.options.enumAdapter(value as Enum)?.toString() ?? '';
    }
    return value?.toString() ?? '';
  }

  /// Returns the [FormFieldState.value] as a [DateTime].
  DateTime? get date => value?.tryCast<DateTime>() ?? DateTime.tryParse(text);

  /// Returns the [FormFieldState.value] as a [num].
  num? get number => value?.tryCast<num>() ?? num.tryParse(text);
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

/// Extension for [Key] value.
extension FormFieldKeyExtension on Key {
  /// Attempts to get the [value] of this [Key] if it is an [String].
  String? get value {
    if (this case ValueKey(:String value)) return value;
    if (this case ObjectKey(:String value)) return value;
    if (this case GlobalObjectKey(:String value)) return value;
    return null;
  }

  /// Creates a [FieldKey] of type [T] of this [Key].
  ///
  /// - [adapter] is a function to adapt the [T] value to any value.
  /// - [unmask] overrides [FormxOptions.unmask].
  ///
  /// The type [T] must be the same type defined in the associated [FormField].
  /// This [Key] value must be a [String]. Otherwise, an [ArgumentError] is thrown.
  FieldKey<T> field<T>({
    FieldAdapter<T>? adapter,
    bool? unmask,
  }) {
    return FieldKey(
      ArgumentError.checkNotNull(value, 'value'),
      adapter: adapter,
      unmask: unmask,
    );
  }

  /// Creates a `FieldKey<String>` with this [Key] value.
  ///
  /// Use with a [FormField] of type [String]. Ex: [TextFormField].
  FieldKey<String> text([FieldAdapter<String>? adapter]) {
    return field(adapter: adapter);
  }

  /// Creates a `FieldKey<DateTime>` of this [Key] value.
  ///
  /// Use with a [FormField] of type [DateTime]. Ex: [DateFormField].
  FieldKey<DateTime> date([FieldAdapter<DateTime>? adapter]) {
    return field(adapter: adapter);
  }

  /// Creates a `FieldKey<List<T>>` of this [Key] value.
  ///
  /// Use with a [FormField] of type [List]. Ex: [CheckboxListFormField].
  FieldKey<List<T>> list<T>([FieldAdapter<List<T>>? adapter]) {
    return field(adapter: adapter);
  }

  /// Creates a `FieldKey<T>` of this [Key] value using a custom adapter function.
  ///
  /// This is a shorthand for `field(adapter: adapter)`.
  FieldKey<T> adapt<T>(dynamic Function(T value) adapter) => field(adapter: adapter);
}

/// Extension for `FieldKey<T>`.
extension FieldKeyExtension<T> on FieldKey<T> {
  /// Whether to unmask the value. Overrides [FormxOptions.unmask].
  FieldKey<T> unmasked() => copyWith(unmask: true);

  /// Whether to mask the value. Overrides [FormxOptions.unmask].
  FieldKey<T> masked() => copyWith(unmask: false);

  /// Adapts [T] `value` to `Object.toMap()` in `FormState.values`.
  ///
  /// If [T] is an [Iterable], it will map each element to `Object.toMap()`.
  FieldKey<T> toMap() {
    return copyWith(adapter: (value) {
      if (value is Iterable) return value.map((e) => e.toMap());
      return (value as dynamic).toMap();
    });
  }

  /// Adapts [T] `value` to `Object.toJson()` in `FormState.values`.
  ///
  /// If [T] is an [Iterable], it will map each element to `Object.toJson()`.
  FieldKey<T> toJson() {
    return copyWith(adapter: (value) {
      if (value is Iterable) return value.map((e) => e.toJson());
      return (value as dynamic).toJson();
    });
  }
}

/// Extension for `FieldKey<String>`.
extension NumberFieldKeyExtension on FieldKey<String> {
  /// Adapts [String] `value` to [int] in `FormState.values`.
  FieldKey<String> toInt() {
    return copyWith(adapter: int.tryParse);
  }

  /// Adapts [String] `value` to [double] in `FormState.values`.
  FieldKey<String> toDouble() {
    return copyWith(adapter: double.tryParse);
  }

  /// Adapts [String] `value` to [Color] in `FormState.values`.
  FieldKey<String> toColor() {
    return copyWith(adapter: (value) {
      if (value.startsWith('#')) value = value.substring(1);
      if (value.length == 6) value = 'FF$value';
      if (value.length != 8) return null;

      final colorValue = int.tryParse(value, radix: 16);
      return colorValue != null ? Color(colorValue) : null;
    });
  }
}

/// Extension for `FieldKey<String>`.
extension EnumFieldKeyExtension on FieldKey<Enum> {
  /// Adapts [Enum] `value` to [String] in `FormState.values`.
  FieldKey<Enum> toName() {
    return copyWith(adapter: (value) => value.name);
  }

  /// Adapts [Enum] `value` to [int] in `FormState.values`.
  FieldKey<Enum> toIndex() {
    return copyWith(adapter: (value) => value.index);
  }
}

/// Extension for `FieldKey<DateTime>`.
extension DateFieldKeyExtension on FieldKey<DateTime> {
  /// Adapts [DateTime] `value` to a [String] in `FormState.values`.
  FieldKey<DateTime> toLocalIso8601String() {
    return copyWith(adapter: (value) => value.toLocal().toIso8601String());
  }

  /// Adapts [DateTime] `value` to a [String] in `FormState.values`.
  FieldKey<DateTime> toUtcIso8601String() {
    return copyWith(adapter: (value) => value.toUtc().toIso8601String());
  }

  /// Adapts [DateTime] `value` to a [int] in `FormState.values`.
  FieldKey<DateTime> toMillisecondsSinceEpoch() {
    return copyWith(adapter: (value) => value.millisecondsSinceEpoch);
  }
}

/// Extension for `FieldKey<List<T>>`.
extension ListFieldKeyExtension<T> on FieldKey<List<T>> {
  /// Adapts List [T] by mapping [toElement] in `FormState.values`.
  FieldKey<List<T>> map(dynamic Function(T e) toElement) {
    return copyWith(adapter: (value) => value.map(toElement).toList());
  }
}

/// A function to adapt a [Object] value to any value.
typedef FieldAdapter<T extends Object?> = dynamic Function(T value);
typedef FieldAdapterTo<T extends Object?, To> = To Function(T? value);

/// A [Key] for a [FormField].
@immutable
class FieldKey<T> extends GlobalObjectKey<FormFieldState<T>> {
  /// Creates a [FieldKey] with a [value].
  const FieldKey(this.value, {this.adapter, this.unmask}) : super(value);

  @override
  final String value;

  /// The adapter function to convert the [T] to any value.
  final FieldAdapter<T>? adapter;

  /// Adapts the [value] if same type. Otherwise, returns the same [value].
  dynamic maybeAdapt(Object value) {
    if (value is! T) return value;

    return adapter?.call(value as T) ?? value;
  }

  /// Whether to unmask the value. Overrides [FormxOptions.unmask].
  final bool? unmask;

  /// Creates a new [FieldKey] with values from this [FieldKey].
  FieldKey<T> copyWith({
    String? value,
    FieldAdapter<T>? adapter,
    bool? unmask,
  }) {
    return FieldKey<T>(
      value ?? this.value,
      adapter: adapter ?? this.adapter,
      unmask: unmask ?? this.unmask,
    );
  }
}
