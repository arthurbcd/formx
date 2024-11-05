import 'package:flutter/material.dart';

import '../../formx.dart';

/// A [Key] for customizing [Formx.toMap] & other outputs.
class FieldKey<T> extends GlobalObjectKey<FormFieldState<T>> {
  /// Creates a [FieldKey] with a [value].
  const FieldKey(
    this.value, {
    this.keepMask,
    this.unmasker,
    this.adapter,
  }) : super(value);

  @override
  // ignore: overridden_fields
  final String value;

  /// Whether to unmask the value. Overrides [FormxOptions.keepMask].
  final bool? keepMask;

  /// The unmasker function to unmask the value.
  final Unmasker? unmasker;

  /// The adapter function to convert the [T] to any value.
  final FieldAdapter<T>? adapter;

  /// Resolves the [FormxOptions] for this [FieldKey].
  @protected
  FormxOptions options([FormxOptions? options]) {
    options ??= Formx.options;

    return options.copyWith(
      keepMask: keepMask,
      unmasker: unmasker,
      adapter: maybeAdapt,
    );
  }

  /// Adapts the [value] if same type. Otherwise, returns the same [value].
  dynamic maybeAdapt(Object value) {
    if (value is! T) return value;

    return adapter?.call(value as T) ?? value;
  }
}

/// Extension for [Key] value.
extension FormFieldKeyExtension on Key {
  /// Creates a [FieldKey] of type [T] of this [Key].
  ///
  /// - [adapter] is a function to adapt the [T] value to any value.
  /// - [keepMask] overrides [FormxOptions.keepMask].
  ///
  /// The type [T] must be the same type defined in the associated [FormField].
  /// This [Key] value must be a [String]. Otherwise, [ArgumentError] is thrown.
  FieldKey<T> options<T>({
    bool? keepMask,
    Unmasker? unmasker,
    FieldAdapter<T>? adapter,
  }) {
    return FieldKey(
      ArgumentError.checkNotNull(value, 'value'),
      keepMask: keepMask,
      unmasker: unmasker,
      adapter: adapter,
    );
  }

  /// Attempts to get the [value] of this [Key] if it is an [String].
  String? get value {
    if (this case ValueKey(:String value)) return value;
    if (this case ObjectKey(:String value)) return value;
    if (this case GlobalObjectKey(:String value)) return value;
    return null;
  }
}

///
extension FormFieldOptionsExtension on FormFieldState {
  /// Resolves the [FormxOptions] for this [FormFieldState].
  FormxOptions getOptions([FormxOptions? options]) => _options(options);
}

///
extension FormOptionsExtension on FormState {
  /// Resolves the [FormxOptions] for this [FormState].
  FormxOptions getOptions([FormxOptions? options]) => _options(options);
}

extension on State {
  FormxOptions _options(FormxOptions? options) {
    options ??= Formx.options;

    return widget.key?.tryCast<FieldKey>()?.options(options) ?? options;
  }
}
