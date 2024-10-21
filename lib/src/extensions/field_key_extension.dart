// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';

import '../fields/checkbox_list_form_field.dart';
import '../fields/date_form_field.dart';
import '../models/field_key.dart';
import '../models/formx_options.dart';

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
  FieldKey<T> adapt<T>(FieldAdapter<T> adapter) {
    return field(adapter: adapter);
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
