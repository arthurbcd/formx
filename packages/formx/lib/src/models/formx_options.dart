import 'package:flutter/services.dart';

import '../../formx.dart';
import '../formatter/formatters/masked_input_formatter.dart';
import '../formatter/formatters/phone_input_formatter.dart';

/// A function to adapt a [value] to any other.
typedef FieldAdapter<T> = dynamic Function(T value);

/// A function to unmask a formatted [value] from a [TextInputFormatter].
typedef Unmasker = String? Function(
  String value,
  TextInputFormatter formatter,
);

/// Global options for all `FormxState` methods.
class FormxOptions {
  /// Creates a new [FormxOptions] instance.
  ///
  /// By default, all options are enabled, except for [nonEmptyIterables].
  ///
  /// The custom values are processed by the provided options.
  /// - [keepMask] gets the unmasked value of [MaskedInputFormatter], if any.
  /// - [nonNulls] removes all null values.
  /// - [nonEmptyMaps] removes all empty maps.
  /// - [nonEmptyStrings] removes all empty strings.
  /// - [nonEmptyIterables] removes all empty iterables.
  ///
  /// `FormxState.rawValues` will always return the raw values, regardless of
  /// any option.
  ///
  const FormxOptions({
    this.keepMask = false,
    this.nonNulls = true,
    this.nonEmptyMaps = true,
    this.nonEmptyStrings = true,
    this.nonEmptyIterables = false,
    this.unmasker = defaultUnmasker,
    this.adapter = defaultAdapter,
  });

  /// Creates a new [FormxOptions] instance with all options disabled.
  const FormxOptions.none({
    this.keepMask = true,
    this.nonNulls = false,
    this.nonEmptyMaps = false,
    this.nonEmptyStrings = false,
    this.nonEmptyIterables = false,
    this.unmasker = defaultUnmasker,
    this.adapter = defaultAdapter,
  });

  /// The default JSON-serializable adapter for any value.
  static dynamic defaultAdapter(Object value) => switch (value) {
        DateTime _ => defaultDateAdapter(value),
        Enum _ => defaultEnumAdapter(value),
        String _ => value.trim(),
        _ => value,
      };

  /// The default JSON-serializable format for [DateTime].
  static dynamic defaultDateAdapter(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  /// The default JSON-serializable format for [Enum].
  static dynamic defaultEnumAdapter(Enum type) => type.name;

  /// The default unmasker for [TextInputFormatter].
  static String? defaultUnmasker(String value, TextInputFormatter formatter) {
    if (formatter is MaskedInputFormatter) return formatter.unmaskedValue;
    if (formatter is PhoneInputFormatter) return value.numeric;
    return null;
  }

  /// Whether to unmask all masked text fields.
  final bool keepMask;

  /// Whether to remove all null values.
  final bool nonNulls;

  /// Whether to remove all empty maps.
  final bool nonEmptyMaps;

  /// Whether to remove all empty strings.
  final bool nonEmptyStrings;

  /// Whether to remove all empty iterables.
  final bool nonEmptyIterables;

  /// Global adapter for any value.
  ///
  /// Use this for adapting any class to a JSON-serializable value.
  final FieldAdapter<Object> adapter;

  /// Global unmasker for unmasking [TextInputFormatter] values.
  final Unmasker unmasker;

  /// Creates a copy of this [FormxOptions] with the provided values.
  FormxOptions copyWith({
    bool? keepMask,
    bool? nonNulls,
    bool? nonEmptyMaps,
    bool? nonEmptyStrings,
    bool? nonEmptyIterables,
    FieldAdapter<Object>? adapter,
    Unmasker? unmasker,
  }) {
    return FormxOptions(
      keepMask: keepMask ?? this.keepMask,
      nonNulls: nonNulls ?? this.nonNulls,
      nonEmptyMaps: nonEmptyMaps ?? this.nonEmptyMaps,
      nonEmptyStrings: nonEmptyStrings ?? this.nonEmptyStrings,
      nonEmptyIterables: nonEmptyIterables ?? this.nonEmptyIterables,
      adapter: adapter ?? this.adapter,
      unmasker: unmasker ?? this.unmasker,
    );
  }
}
