// ignore_for_file: null_check_on_nullable_type_parameter

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../formatter/formatter.dart';
import '../models/field_key.dart';
import '../models/formx_exception.dart';
import '../models/formx_options.dart';
import '../models/formx_setup.dart';
import 'form_field_state_extension.dart';
import 'sanitizers.dart';

/// Inline-class for [FormState] to add syntactic sugar.
///
/// [FormxState] methods works a little different from [FormState] methods.
/// Instead of just applying to [FormState] attached first level fields, it
/// applies to all nested [FormState] form/fields as well.
///
/// Additionally, you can pass a list of keys to apply the method only to
/// specific form/fields.
///
/// WIP - Update to reflect AutovalidateMode.onUnfocus.
extension type FormxState(FormState state) implements FormState {
  @redeclare
  bool validate([List<String>? keys]) {
    return !visit(
      keys: keys,
      onField: (key, state) => state.validate(),
      onForm: keys != null ? (key, state) => state.validate() : null,
    ).values.contains(false);
  }

  @redeclare
  void save([List<String>? keys]) {
    visit(
      keys: keys,
      onField: (key, state) => state.save(),
      onForm: keys != null ? (key, state) => state.save() : null,
    );
  }

  @redeclare
  void reset([List<String>? keys]) {
    visit(
      keys: keys,
      onField: (key, state) => state.reset(),
      onForm: keys != null ? (key, state) => state.reset() : null,
    );
  }

  // WIP - implement this method.
  // @redeclare
  // Set<FormFieldState<Object?>> validateGranularly([List<String>? keys]) {
  //   return visit(
  //     keys: keys,
  //     onForm: (key, state) => (state as FormState).validateGranularly(),
  //   ).values.expand((e) => e).toSet();
  // }
}

///
extension Formx on FormxState {
  /// Global setup for all [Formx] widgets.
  static FormxSetup setup = const FormxSetup();

  /// Global options for all [FormxState] methods.
  static FormxOptions options = const FormxOptions();

  /// Returns a structured map with all keyed raw [FormFieldState.value].
  Map<String, dynamic> get rawValues {
    final map = <String, dynamic>{};
    visit(
      onField: (key, state) => map[key] = state.value,
      onForm: (key, state) => map[key] = state.rawValues,
      shouldStop: (key, state, _) => state is FormState,
    );
    return IndentedMap(map);
  }

  /// Returns a structured map with all keyed [FormFieldState.value].
  ///
  /// You can customize the output by setting [options].
  Map<String, dynamic> toMap({FormxOptions? options, List<String>? keys}) {
    options = getOptions(options);

    return _map(options, keys).cleaned(
      nonNulls: options.nonNulls,
      nonEmptyMaps: options.nonEmptyMaps,
      nonEmptyStrings: options.nonEmptyStrings,
      nonEmptyIterables: options.nonEmptyIterables,
    );
  }

  Map<String, dynamic> _map(FormxOptions options, List<String>? keys) {
    final map = <String, dynamic>{};
    visit(
      keys: keys,
      onForm: (key, state) => map[key] = state.toMap(options: options),
      onField: (key, state) => map[key] = state.toValue(options: options),
      shouldStop: (key, state, _) => state is FormState,
    );
    return map;
  }

  /// Performs [validate], [save], and returns [toMap] with [options].
  /// Throws a [FormxException] if form is invalid.
  Map<String, dynamic> submit({
    FormxOptions? options,
    String? errorMessage,
    List<String>? keys,
  }) {
    if (!validate(keys)) {
      throw FormxException(errorTexts, errorMessage);
    }
    save(keys);
    return toMap(options: options, keys: keys);
  }

  /// Performs [validate], [save], and returns [toMap] with [options].
  /// Returns `null` if form is invalid.
  Map<String, dynamic>? trySubmit({FormxOptions? options, List<String>? keys}) {
    try {
      return submit(options: options, keys: keys);
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
      shouldStop: (key, state, _) => state is FormState,
    );
    return IndentedMap(map);
  }

  /// Returns true if any nested [FormFieldState.hasInteractedByUser].
  bool get hasInteractedByUser {
    return visit(
      onField: (key, state) => state.hasInteractedByUser,
      shouldStop: (key, state, itHas) => itHas,
    ).values.contains(true);
  }

  /// Returns true if any nested [FormFieldState.hasError].
  bool get hasError {
    return visit(
      onField: (key, state) => state.hasError,
      shouldStop: (key, state, itHas) => itHas,
    ).values.contains(true);
  }

  /// Returns all nested invalid keys of this [FormState].
  List<String> get invalids {
    return visit(
      onField: (k, state) => state.isValid,
    ).keysWhere((k, isValid) => !isValid);
  }

  /// Returns true if all nested [FormFieldState.isValid].
  bool get isValid => invalids.isEmpty;

  /// Returns true if all nested [FormFieldStateExtension.isInitial].
  bool get isInitial {
    return !visit(
      onField: (key, state) => state.isInitial,
      shouldStop: (key, state, itIs) => !itIs,
    ).values.contains(false);
  }

  /// Returns a flat [Map] with all nested [FormFieldState.errorText].
  Map<String, String> get errorTexts {
    return visit(onField: (k, state) => state.errorText).nonNulls.indented;
  }

  /// Fills this [FormState] with new [map].
  ///
  /// If [format] is `true`, [TextField.inputFormatters] will be applied.
  void fill(Map<String, dynamic> map, {bool format = true}) {
    visit(
      // keys: map.keys.toList(), // should assert keys ?
      onField: (key, state) {
        if (map.containsKey(key)) {
          final value = state.maybeFormat(map[key], format);
          state.didChange(value);
        }
      },
      onForm: (key, state) {
        if (map.containsKey(key)) {
          state.fill((map[key] as Map).cast(), format: format);
        }
      },
      shouldStop: (key, state, _) => state is FormState,
    );
  }

  Map<String, dynamic> get _debugMap {
    final map = <String, dynamic>{};
    visit(
      onField: (key, state) => map[key] = state.debugText,
      onForm: (key, state) => map['$key($state)'] = state._debugMap,
      shouldStop: (key, state, _) => state is FormState,
    );
    return map;
  }

  /// Logs the current state of this [FormState].
  void debug() {
    log(
      name: 'Formx',
      _debugMap.indentedText
          .replaceAll(r'\"/', '"')
          .replaceAll('",\n', '\n')
          .replaceAll('"\n', '\n'),
    );
  }

  /// Visits all [FormFieldState] and [FormState] of this [Form] tree.
  ///
  /// - [onForm] is called for each [FormState].
  /// - [onField] is called for each [FormFieldState].
  /// - [shouldStop] can be used to stop the recursion.
  @protected
  Map<String, R> visit<R>({
    List<String>? keys,
    R Function(String key, FormxState state)? onForm,
    R Function(String key, FormFieldState state)? onField,
    bool Function(String key, State state, R result)? shouldStop,
  }) {
    assert(onForm != null || onField != null);

    final results = <String, R>{};
    final found = {
      for (final key in [...?keys]) key: false,
    };

    void visit(Element el) {
      if (el.key case String key when keys?.contains(key) ?? true) {
        found[key] = true;

        // onForm
        if ((el.state, onForm) case (FormState state, var fn?)) {
          results[key] = fn(key, FormxState(state));
        }

        // onField
        if ((el.state, onField) case (FormFieldState state, var fn?)) {
          results[key] = fn(key, state..attachToValidator());
        }

        // if all keys are found, stop.
        if (keys != null && found.values.every((e) => e)) return;

        // if shouldStop is true, stop.
        if (shouldStop?.call(key, el.state!, results[key] as R) == true) return;
      }
      el.visitChildren(visit);
    }

    context.visitChildElements(visit);

    final missingKeys = found.entries.where((e) => !e.value).map((e) => e.key);
    final foundKeys = found.entries.where((e) => e.value).map((e) => e.key);

    assert(
      foundKeys.isNotEmpty && missingKeys.isEmpty,
      'No [Form] or [FormField] found with keys in this context.\n'
      'Keys found: $foundKeys\n'
      'Keys missing: $missingKeys\n'
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

    return results;
  }
}

extension on Element {
  State? get state => tryCast<StatefulElement>()?.state;

  String? get key {
    if (state is FormState || state is FormFieldState) {
      return state?.widget.key?.value;
    }

    return null;
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

  // Focus? get focus {
  //   Focus? focus;

  //   void visit(Element el) {
  //     if (el.widget case Focus it) {
  //       focus = it;
  //       return;
  //     }
  //     el.visitChildren(visit);
  //   }

  //   if (Form.maybeOf(context)?.widget.autovalidateMode ==
  //               AutovalidateMode.onUnfocus &&
  //           widget.autovalidateMode != AutovalidateMode.always ||
  //       widget.autovalidateMode == AutovalidateMode.onUnfocus) {
  //     context.visitChildElements(visit);
  //   }

  //   return focus;
  // }

  String get debugText {
    var text = '$value"/';
    var initialValue = widget.initialValue?.toString();
    if (['', '[]', '{}'].contains(initialValue)) initialValue = null;

    if (initialValue case var i?) text += ', i: $i';
    if (errorText case var e?) text += ', e: $e';
    return '$text. ${isValid ? '✔' : '✘'}';
  }
}

///
extension FormxFormStateExtension on FormState {
  /// The [Key] `value` of this [FormState].
  String? get key => widget.key?.value;

  /// The parent [FormState] of this [Form] node.
  FormState? get parent => context.findAncestorStateOfType();

  /// The root [FormState] of this [Form] tree. Can be itself.
  FormState get root => context.findRootAncestorStateOfType() ?? this;
}
