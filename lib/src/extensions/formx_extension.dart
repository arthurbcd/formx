import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../formx.dart';
import 'form_field_state_extension.dart';

/// Extension for [BuildContext] to access the [FormState].
extension Formx on FormState {
  /// Global setup for all [Formx] widgets.
  static FormxSetup setup = const FormxSetup();

  /// Global options for all [FormxState] methods.
  static FormxOptions options = const FormxOptions();

  /// The [Key] `value` of this [FormState].
  String? get key => widget.key?.value;

  /// The parent [FormState] of this [Form] node.
  FormState? get parent => context.findAncestorStateOfType();

  /// The root [FormState] of this [Form] tree. Can be itself.
  FormState get root => context.findRootAncestorStateOfType() ?? this;

  /// Returns a structured map with all keyed raw [FormFieldState.value].
  Map<String, dynamic> get rawValues {
    final map = <String, dynamic>{};
    visit(
      onField: (key, state) => map[key] = state.value,
      onForm: (key, state) => map[key] = state.rawValues,
      shouldStop: (key, state) => state is FormState,
    );
    return IndentedMap(map);
  }

  /// Returns a structured map with all keyed [FormFieldState.value].
  ///
  /// You can customize the output by setting [options].
  Map<String, dynamic> toMap({FormxOptions? options}) {
    options = getOptions(options);

    return _map(options).cleaned(
      nonNulls: options.nonNulls,
      nonEmptyMaps: options.nonEmptyMaps,
      nonEmptyStrings: options.nonEmptyStrings,
      nonEmptyIterables: options.nonEmptyIterables,
    );
  }

  Map<String, dynamic> _map(FormxOptions options) {
    final map = <String, dynamic>{};
    visit(
      onForm: (key, state) => map[key] = state.toMap(options: options),
      onField: (key, state) => map[key] = state.toValue(options: options),
      shouldStop: (key, state) => state is FormState,
    );
    return map;
  }

  /// Performs [validate], [save], and returns [toMap] with [options].
  /// Throws a [FormxException] if the form is invalid.
  Map<String, dynamic> submit({FormxOptions? options}) {
    final state = FormxState(this);

    if (!state.validate()) {
      throw FormxException(errorTexts);
    }
    state.save();
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
  ///
  /// If [format] is `true`, [TextField.inputFormatters] will be applied.
  void fill(Map<String, dynamic> map, {bool format = true}) {
    visit(
      onField: (key, state) {
        if (map.containsKey(key)) {
          final value = state.maybeFormat(map[key], format);
          state.didChange(value);
        }
      },
      onForm: (key, state) {
        if (map.containsKey(key)) {
          state.fill((map[key] as Map).cast());
        }
      },
      shouldStop: (key, state) => state is FormState,
    );
  }

  /// Logs the current state of this [FormState].
  void debug() {
    log(
      name: 'Formx',
      'keys (${rawValues.keys.length}): ${rawValues.keys}\n'
      'initialValues: ${initialValues.cleaned()}\n'
      'values: ${toMap()}\n'
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

extension on FormFieldState {
  /// Atempts to format the [value] with [TextField.inputFormatters].
  ///
  /// Returns [value] if [format] is `false` or if cannot be formatted.
  Object? maybeFormat(Object? value, bool format) {
    if (!format || value is! String || widget is! TextFormField) return value;

    final tff = widget as dynamic;
    final field = tff.builder(this).child as TextField;

    if (field.inputFormatters case var it?) {
      return it.fold<String>(value, (value, f) => f.format(value));
    }

    return value;
  }
}
