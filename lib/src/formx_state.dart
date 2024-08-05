import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../formx.dart';
import 'extensions/form_state_extension.dart';

/// Inline-class for [FormState] to add syntactic sugar.
///
/// [FormxState] methods works a little different from [FormState] methods.
/// Instead of just applying to [FormState] attached first level fields, it
/// applies to all nested [FormState] form/fields as well.
///
/// Additionally, you can pass a list of keys to apply the method only to
/// specific form/fields.
extension type FormxState(FormState state) implements FormState {
  @redeclare
  bool validate([List<String>? keys]) {
    assertKeys(keys, 'validate');
    final list = <bool>[];

    visit(
      onField: (key, state) {
        if (keys == null || keys.contains(key)) list.add(state.validate());
      },
      onForm: (key, state) {
        if (keys == null || keys.contains(key)) list.add(state.validate());
      },
      shouldStop: (key, state) => list.length == keys?.length,
    );

    assert(
      list.isNotEmpty,
      'No fields validated. Check if the keys are correct.',
    );
    return !list.contains(false);
  }

  @redeclare
  void save([List<String>? keys]) {
    assertKeys(keys, 'save');
    final list = <void>[];

    visit(
      onField: (key, state) {
        if (keys == null || keys.contains(key)) list.add(state.save());
      },
      onForm: (key, state) {
        if (keys == null || keys.contains(key)) list.add(state.save());
      },
      shouldStop: (key, state) => list.length == keys?.length,
    );

    assert(list.isNotEmpty, 'No fields saved. Check if the keys are correct.');
  }

  @redeclare
  void reset([List<String>? keys]) {
    assertKeys(keys, 'reset');
    final list = <void>[];

    visit(
      onField: (key, state) {
        if (keys == null || keys.contains(key)) list.add(state.reset());
      },
      onForm: (key, state) {
        if (keys == null || keys.contains(key)) list.add(state.reset());
      },
      shouldStop: (key, state) => list.length == keys?.length,
    );

    assert(list.isNotEmpty, 'No fields reset. Check if the keys are correct.');
  }
}

/// Syntactic sugar for [Form.of].
mixin Formx {
  /// Behaves like [Form.of], but returns a [FormxState] instead.
  ///
  /// This will not scan the widget tree like `context.formx`, but will create
  /// a dependency on the nearest [Form] ancestor, like [Form.of].
  static FormxState of(BuildContext context) => FormxState(Form.of(context));

  /// Global options for all [FormxState] instances.
  static FormxOptions options = const FormxOptions();
}

/// Global options for all [FormxState] instances.
class FormxOptions {
  /// Creates a new [FormxOptions] instance.
  ///
  /// By default, all options are enabled, except for [nonEmptyIterables].
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
    this.defaultTitle = _defaultTitle,
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
    this.defaultTitle = _defaultTitle,
  });

  static String _defaultDateAdapter(DateTime value) {
    return value.toUtc().toIso8601String();
  }

  static String _defaultEnumAdapter(Enum value) {
    return value.name;
  }

  static String _defaultTitle(Object value) {
    if (value is String) return value;

    try {
      return (value as dynamic).title as String;
    } catch (_) {}
    try {
      return (value as dynamic).name as String;
    } catch (_) {}

    return value.toString();
  }

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
  final String Function(Object value) defaultTitle;
}
