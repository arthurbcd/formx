// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';

import '../../formx.dart';

/// A function to adapt a [Object] value to any value.
typedef FieldAdapter<T extends Object?> = dynamic Function(T value);

/// Signature for binding a [FormFieldState] to a [FormFieldValidator].
typedef FormFieldData = ({FormFieldState state, String? errorText});

/// A [Key] for a [FormField].
@immutable
class FieldKey<T> extends GlobalObjectKey<FormFieldState<T>> {
  /// Creates a [FieldKey] with a [value].
  const FieldKey(this.value, {this.adapter, this.unmask}) : super(value);

  @override
  // ignore: overridden_fields
  final String value;

  /// The adapter function to convert the [T] to any value.
  final FieldAdapter<T>? adapter;

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

  /// Adapts the [value] if same type. Otherwise, returns the same [value].
  dynamic maybeAdapt(Object value) {
    if (value is! T) return value;

    return adapter?.call(value as T) ?? value;
  }
}

/// Extension for `FieldKey<DateTime>`.
extension DateFieldKeyExtension on FieldKey<DateTime> {
  /// Adapts [DateTime] `value` to a [String] in `FormState.values`.
  FieldKey<DateTime> toLocalIso8601String() {
    return copyWith(adapter: (value) => value.toLocal().toIso8601String());
  }

  /// Adapts [DateTime] `value` to a [int] in `FormState.values`.
  FieldKey<DateTime> toMillisecondsSinceEpoch() {
    return copyWith(adapter: (value) => value.millisecondsSinceEpoch);
  }

  /// Adapts [DateTime] `value` to a [String] in `FormState.values`.
  FieldKey<DateTime> toUtcIso8601String() {
    return copyWith(adapter: (value) => value.toUtc().toIso8601String());
  }
}

/// Extension for `FieldKey<String>`.
extension EnumFieldKeyExtension on FieldKey<Enum> {
  /// Adapts [Enum] `value` to [int] in `FormState.values`.
  FieldKey<Enum> toIndex() {
    return copyWith(adapter: (value) => value.index);
  }

  /// Adapts [Enum] `value` to [String] in `FormState.values`.
  FieldKey<Enum> toName() {
    return copyWith(adapter: (value) => value.name);
  }
}

/// Extension for `FieldKey<T>`.
extension FieldKeyExtension<T> on FieldKey<T> {
  /// Whether to mask the value. Overrides [FormxOptions.unmask].
  FieldKey<T> masked() => copyWith(unmask: false);

  /// Creates a `FieldKey<T>` of this [Key] value using a custom adapter.
  ///
  /// This is a shorthand for `field(adapter: adapter)`.
  FieldKey<T> adapt(dynamic Function(T value) adapter) {
    return field(adapter: adapter);
  }

  /// Adapts [T] `value` to `Object.toJson()` in `FormState.values`.
  ///
  /// If [T] is an [Iterable], it will map each element to `Object.toJson()`.
  FieldKey<T> toJson() {
    return copyWith(
      adapter: (value) {
        if (value is Iterable) return value.map((e) => e.toJson());
        return (value as dynamic).toJson();
      },
    );
  }

  /// Adapts [T] `value` to `Object.toMap()` in `FormState.values`.
  ///
  /// If [T] is an [Iterable], it will map each element to `Object.toMap()`.
  FieldKey<T> toMap() {
    return copyWith(
      adapter: (value) {
        if (value is Iterable) return value.map((e) => e.toMap());
        return (value as dynamic).toMap();
      },
    );
  }

  /// Whether to unmask the value. Overrides [FormxOptions.unmask].
  FieldKey<T> unmasked() => copyWith(unmask: true);
}

/// Extension for `FieldKey<List<T>>`.
extension FieldKeyListExtension<T> on FieldKey<List<T>> {
  /// Creates a `FieldKey<T>` of this [Key] value using a custom adapter.
  ///
  /// This is a shorthand for `field(adapter: adapter)`.
  FieldKey<List<T>> adapt(dynamic Function(T value) adapter) {
    return field(
      adapter: (value) => value.map(adapter).toList(),
    );
  }
}

/// Extension for [Key] value.
extension FormFieldKeyExtension on Key {
  /// Attempts to get the [value] of this [Key] if it is an [String].
  String? get value {
    if (this case ValueKey(:String value)) return value;
    if (this case ObjectKey(:String value)) return value;
    if (this case GlobalObjectKey(:String value)) return value;
    return null;
  }

  /// Creates a `FieldKey<DateTime>` of this [Key] value.
  ///
  /// Use with a [FormField] of type [DateTime]. Ex: [DateFormField].
  FieldKey<DateTime> date([FieldAdapter<DateTime>? adapter]) {
    return field(adapter: adapter);
  }

  /// Creates a [FieldKey] of type [T] of this [Key].
  ///
  /// - [adapter] is a function to adapt the [T] value to any value.
  /// - [unmask] overrides [FormxOptions.unmask].
  ///
  /// The type [T] must be the same type defined in the associated [FormField].
  /// This [Key] value must be a [String]. Otherwise, [ArgumentError] is thrown.
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

  /// Creates a `FieldKey<List<T>>` of this [Key] value.
  ///
  /// Use with a [FormField] of type [List]. Ex: [CheckboxListFormField].
  FieldKey<List<T>> list<T>([FieldAdapter<T>? adapter]) {
    if (adapter == null) return field();

    return field(adapter: (list) => list.map(adapter).toList());
  }

  /// Creates a `FieldKey<String>` with this [Key] value.
  ///
  /// Use with a [FormField] of type [String]. Ex: [TextFormField].
  FieldKey<String> text([FieldAdapter<String>? adapter]) {
    return field(adapter: adapter);
  }

  /// Creates a `FieldKey<T>` of this [Key] value using a custom adapter.
  ///
  /// This is a shorthand for `field(adapter: adapter)`.
  FieldKey<T> adapt<T>(dynamic Function(T value) adapter) {
    return field(adapter: adapter);
  }
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

/// Extends [FormFieldState] with a programatic way to set [errorText].
extension FormFieldStateExtension<T> on FormFieldState<T> {
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
  @Deprecated('Use `.text` instead.')
  String get string => value?.toString() ?? '';

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

  /// Sets the [errorText] programatically.
  ///
  /// You need to set a [Validator] to use this method.
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
