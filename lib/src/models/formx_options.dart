import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../fields/date_form_field.dart';

/// A function to adapt a [value] to any other.
typedef FieldAdapter<T> = dynamic Function(T value);

/// Global options for all `FormxState` methods.
class FormxOptions {
  /// Creates a new [FormxOptions] instance.
  ///
  /// By default, all options are enabled, except for [nonEmptyIterables].
  ///
  /// The custom values are processed by the provided options.
  /// - [trim] trims all string values.
  /// - [unmask] gets the unmasked value of [MaskTextInputFormatter], if any.
  /// - [nonNulls] removes all null values.
  /// - [nonEmptyMaps] removes all empty maps.
  /// - [nonEmptyStrings] removes all empty strings.
  /// - [nonEmptyIterables] removes all empty iterables.
  ///
  /// `FormxState.rawValues` will always return the raw values, regardless of
  /// any option.
  ///
  const FormxOptions({
    this.trim = true,
    this.unmask = true,
    this.nonNulls = true,
    this.nonEmptyMaps = true,
    this.nonEmptyStrings = true,
    this.nonEmptyIterables = false,
    this.dateAdapter = _defaultDateAdapter,
    this.enumAdapter = _defaultEnumAdapter,
    @Deprecated('Moved to FormxSetup') this.defaultTitle,
  });

  /// Creates a new [FormxOptions] instance with all options disabled.
  const FormxOptions.none({
    this.trim = false,
    this.unmask = false,
    this.nonNulls = false,
    this.nonEmptyMaps = false,
    this.nonEmptyStrings = false,
    this.nonEmptyIterables = false,
    this.dateAdapter = _defaultDateAdapter,
    this.enumAdapter = _defaultEnumAdapter,
    @Deprecated('Moved to FormxSetup') this.defaultTitle,
  });

  static dynamic _defaultDateAdapter(DateTime date) {
    return date.toUtc().toIso8601String();
  }

  static dynamic _defaultEnumAdapter(Enum type) => type.name;

  /// Whether to trim all string values.
  final bool trim;

  /// Whether to unmask all masked text fields.
  final bool unmask;

  /// Whether to remove all null values.
  final bool nonNulls;

  /// Whether to remove all empty maps.
  final bool nonEmptyMaps;

  /// Whether to remove all empty strings.
  final bool nonEmptyStrings;

  /// Whether to remove all empty iterables.
  final bool nonEmptyIterables;

  /// Global adapter for [DateFormField] values.
  final FieldAdapter<DateTime> dateAdapter;

  /// Global adapter for [Enum] values.
  final FieldAdapter<Enum> enumAdapter;

  /// The default title for all fields.
  @Deprecated('Moved to FormxSetup')
  final String Function(Object value)? defaultTitle;
}
