import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../models/field_key.dart';
import '../models/formx_exception.dart';
import '../models/formx_options.dart';
import '../models/formx_setup.dart';
import 'field_key_extension.dart';
import 'form_field_state_extension.dart';
import 'formx_state.dart';
import 'sanitizers.dart';

/// Extension for [BuildContext] to access the [FormState].
extension Formx on FormState {
  /// Global setup for all [Formx] widgets.
  static FormxSetup setup = const FormxSetup();

  /// Global options for all [FormxState] methods.
  static FormxOptions options = const FormxOptions();

  /// The [Key] `value` of this [FormState].
  String? get key => widget.key?.value;

  /// The parent [FormState] of this [Form] node.
  FormState? get parent => Form.maybeOf(context);

  /// The root [FormState] of this [Form] tree. Can be itself.
  FormState get root => parent?.root ?? this;

  /// Returns a structured map with all keyed raw [FormFieldState.value].
  Map<String, dynamic> get rawValues {
    final map = <String, dynamic>{};
    visit(
      onField: (key, state) => map[key] = state.value,
      onForm: (key, state) => map[key] = state.values,
      shouldStop: (key, state) => state is FormState,
    );
    return IndentedMap(map);
  }

  /// Returns a structured map with all keyed custom [FormFieldState.value].
  ///
  /// The custom values are processed by [Formx.options].
  @Deprecated('Use `.toMap()` instead.')
  Map<String, dynamic> get values => toMap();

  /// Returns a structured map with all keyed [FormFieldState.value].
  @Deprecated('Use `.toMap()` instead.')
  Map<String, dynamic> customValues({
    bool trim = false,
    bool unmask = false,
    bool nonNulls = false,
    bool nonEmptyMaps = false,
    bool nonEmptyStrings = false,
    bool nonEmptyIterables = false,
  }) {
    return toMap(
      options: FormxOptions(
        trim: trim,
        unmask: unmask,
        nonNulls: nonNulls,
        nonEmptyMaps: nonEmptyMaps,
        nonEmptyStrings: nonEmptyStrings,
        nonEmptyIterables: nonEmptyIterables,
      ),
    );
  }

  /// Returns a structured map with all keyed [FormFieldState.value].
  ///
  /// You can customize the output by setting [options].
  Map<String, dynamic> toMap({
    FormxOptions? options,
  }) {
    // when null, use the global options
    options ??= Formx.options;

    final map = <String, dynamic>{};
    var unmask = options.unmask;
    var trim = options.trim;

    visit(
      onField: (key, state) {
        Object? value = state.value;
        if (value == null) return map[key] = null;

        // ignore: parameter_assignments
        if (state.fieldKey?.unmask case bool value) unmask = value;

        // trim
        if (value case String text when trim) value = text.trim();

        // unmask
        if (state.widget case TextFormField field when unmask) {
          final f = (field.builder(state.cast()) as dynamic).child as TextField;
          final list = f.inputFormatters?.whereType<MaskTextInputFormatter>();

          if (list?.firstOrNull case var formatter?) {
            value = formatter.unmaskText(value.cast());
          }
        }

        // adapter
        if (state.fieldKey?.maybeAdapt case var adapter?) {
          map[key] = adapter(value);
        } else if (value is DateTime) {
          map[key] = options!.dateAdapter(value);
        } else if (value is Enum) {
          map[key] = options!.enumAdapter(value);
        } else {
          map[key] = value;
        }
      },
      onForm: (key, state) {
        Object value = state.toMap(options: options);

        if (state.widget.key case FieldKey fkey) {
          map[key] = fkey.maybeAdapt(value);
        } else {
          map[key] = value;
        }
      },
      shouldStop: (key, state) => state is FormState,
    );

    return map.cleaned(
      nonNulls: options.nonNulls,
      nonEmptyMaps: options.nonEmptyMaps,
      nonEmptyStrings: options.nonEmptyStrings,
      nonEmptyIterables: options.nonEmptyIterables,
    );
  }

  /// Performs [validate], [save], and returns [toMap] with [options].
  /// Throws a [FormxException] if the form is invalid.
  Map<String, dynamic> submit({FormxOptions? options}) {
    if (!validate()) {
      throw FormxException(errorTexts);
    }
    save();
    return toMap(options: options);
  }

  /// Performs [validate], [save], and returns [toMap] with [options].
  /// Returns `null` if the form is invalid.
  Map<String, dynamic>? trySubmit({FormxOptions? options}) {
    try {
      return submit(options: options);
    } catch (_) {
      return null;
    }
  }

  /// Returns a structured map with all keyed [FormField.initialValue].
  Map<String, dynamic> get initialValues {
    final map = <String, dynamic>{};
    visit(
      onField: (key, state) => map[key] = state.widget.initialValue,
      onForm: (key, state) => map[key] = state.initialValues,
      shouldStop: (key, state) => state is FormState,
    );
    return IndentedMap(map);
  }

  /// Returns true if any nested [FormFieldState.hasInteractedByUser].
  bool get hasInteractedByUser {
    var hasInteracted = false;
    visit(
      onField: (key, state) {
        if (state.hasInteractedByUser) hasInteracted = true;
      },
      shouldStop: (key, s) => s is FormFieldState && s.hasInteractedByUser,
    );
    return hasInteracted;
  }

  /// Returns true if any nested [FormFieldState.hasError].
  bool get hasError {
    var hasError = false;
    visit(
      onField: (key, state) {
        if (state.hasError) hasError = true;
      },
      shouldStop: (key, state) => state is FormFieldState && state.hasError,
    );
    return hasError;
  }

  /// Returns all the invalid keys of this [FormState].
  List<String> get invalids {
    final list = <String>[];
    visit(
      onField: (key, state) {
        if (!state.isValid) list.add(key);
      },
    );
    return list;
  }

  /// Returns true if all nested [FormFieldState.isValid].
  bool get isValid => invalids.isEmpty;

  /// Returns true if all nested [FormFieldStateExtension.isInitial].
  bool get isInitial {
    var test = true;
    visit(
      onField: (key, state) => test = state.isInitial,
      onForm: (key, state) => test = state.isInitial,
      shouldStop: (key, state) => !test || state is FormState,
    );
    return test;
  }

  /// Returns a flat [Map] with all nested [FormFieldState.errorText].
  Map<String, String> get errorTexts {
    final errorTexts = <String, String>{};
    visit(
      onField: (key, state) {
        if (state.hasError) errorTexts[key] = state.errorText ?? '';
      },
    );
    return IndentedMap(errorTexts);
  }

  /// Fills this [FormState] with new [map].
  void fill(Map<String, dynamic> map) {
    visit(
      onField: (key, state) {
        if (map.containsKey(key)) state.didChange(map[key]);
      },
      onForm: (key, state) {
        if (map.containsKey(key)) state.fill((map[key] as Map).cast());
      },
      shouldStop: (key, state) => state is FormState,
    );
  }

  /// Logs the current state of this [FormState].
  void debug() {
    final keys = rawValues.keys;

    log(
      name: 'Formx',
      'keys (${keys.length}): ${rawValues.keys}\n'
      'initialValues: ${initialValues.cleaned()}\n'
      'values: $values\n'
      'invalids: $invalids\n',
    );
  }

  /// Visits all [FormFieldState] and [FormState] of this [Form] tree.
  ///
  /// - [onForm] is called for each [FormState].
  /// - [onField] is called for each [FormFieldState].
  /// - [shouldStop] can be used to stop the recursion.
  @protected
  void visit({
    void Function(String key, FormState state)? onForm,
    void Function(String key, FormFieldState state)? onField,
    bool Function(String key, State state)? shouldStop,
  }) {
    var didFind = false;
    void visit(Element el) {
      if (el is StatefulElement && el.widget.key?.value != null) {
        final key = el.widget.key!.value!;

        if (el.state is FormState || el.state is FormFieldState) {
          didFind = true;
          if (el.state case FormState state) onForm?.call(key, state);
          if (el.state case FormFieldState state) {
            onField?.call(key, state..attachToValidator());
          }
          if (shouldStop?.call(key, el.state) ?? false) return;
        }
      }
      el.visitChildren(visit);
    }

    context.visitChildElements(visit);
    assert(
      didFind,
      'No [Form] or [FormField] found with keys in this context.\n'
      'Make sure you are settings a key to [Form] or [FormField] widget.\n\n'
      'Ex:\n'
      '```dart\n'
      'Form(\n'
      '  child: TextFormField(\n'
      '    key: const Key("name"), // <-- set a key here.\n'
      '  ),\n'
      ')\n'
      '```',
    );
  }

  /// Behaves like [Form.of], but returns a [FormxState] instead.
  ///
  /// This will not scan the widget tree like `context.formx`, but will create
  /// a dependency on the nearest [Form] ancestor, like [Form.of].
  ///
  /// NOTE: We do not recommend using formx in build methods, as all formx
  /// methods must be called after the build phase.
  @Deprecated('Use context.formx() instead.')
  static FormxState of(BuildContext context) => FormxState(Form.of(context));
}

/// Extension for [FormState] to assert if `keys` are valid.
extension AssertKeysExtension on FormState {
  /// Asserts if the [keys] are valid for this [FormState].
  @protected
  void assertKeys(List<String>? keys, String message) {
    if (!kDebugMode || keys == null) return;
    final list = <String>[];

    visit(
      onField: (key, state) {
        if (keys.contains(key)) list.add(key);
      },
      onForm: (key, state) {
        if (keys.contains(key)) list.add(key);
      },
    );

    for (final key in keys) {
      assert(
        list.contains(key),
        'Could not $message key: $key in this form.\n'
        'Found: $list',
      );
    }
  }
}
