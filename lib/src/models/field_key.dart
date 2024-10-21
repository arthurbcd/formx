import 'package:flutter/material.dart';

import '../../formx.dart';

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
