// ignore_for_file: invalid_use_of_protected_member

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../formx.dart';
import 'validator/validator.dart';

extension on State {
  String? get key => widget.key?.value;
}

extension FormFieldStateMaybe<T> on FormFieldState<T> {
  /// Atempts to format the [value] with [TextField.inputFormatters].
  ///
  /// Returns [value] if [format] is `false` or if cannot be formatted.
  Object? maybeFormat(Object? value, [bool format = true]) {
    if (!format || value is! String || widget is! TextFormField) return value;

    final tff = widget as dynamic; // TextFormField
    final field = tff.builder(this).child as TextField;

    if (field.inputFormatters case var it?) {
      return it.fold<String>(value, (value, f) => f.format(value));
    }

    return value;
  }

  /// Atempts to change the [FormFieldState.value] if [value] is of type [T].
  void maybeChange(Object? value) {
    final t = value.runtimeType;
    assert(value is T, 'Invalid value: $t is not a subtype of $T.');
    if (value is T) {
      didChange(value);
    }
  }

  String get debugText {
    var text = '$value"/';
    var initialValue = widget.initialValue?.toString();
    if (['', '[]', '{}'].contains(initialValue)) initialValue = null;

    if (initialValue case var i?) text += ', i: $i';
    if (errorText case var e?) text += ', e: $e';
    return '$text. ${isValid ? '✔' : '✘'}';
  }
}

extension FormxFormStateExtension on FormState {
  /// The [Key] `value` of this [FormState].
  String? get key => widget.key?.value;

  /// The parent [FormState] of this [Form] node.
  FormState? get parent => context.findAncestorStateOfType();

  /// The root [FormState] of this [Form] tree. Can be itself.
  FormState get root => context.findRootAncestorStateOfType() ?? this;
}

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
      onForm: (key, state) => state.validate(),
      onField: (key, state) => state.validate(),
    ).values.contains(false);
  }

  @redeclare
  void save([List<String>? keys]) {
    visit(
      keys: keys,
      onForm: (key, state) => state.save(),
      onField: (key, state) => state.save(),
    );
  }

  @redeclare
  void reset([List<String>? keys]) {
    visit(
      keys: keys,
      onForm: (key, state) => state.reset(),
      onField: (key, state) => state.reset(),
    );
  }

  /// Returns a structured map with all keyed raw [FormFieldState.value].
  Map<String, dynamic> get rawValues {
    return IndentedMap({
      for (final field in fields) field.key!: field.value,
      for (final form in forms) form.key!: form.rawValues,
    });
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
    return IndentedMap({
      for (final field in fields) field.key!: field.widget.initialValue,
      for (final form in forms) form.key!: form.initialValues,
    });
  }

  /// Returns true if any nested [FormFieldState.hasInteractedByUser].
  bool get hasInteractedByUser {
    for (final field in fields) {
      if (field.hasInteractedByUser) return true;
    }
    for (final form in forms) {
      if (form.hasInteractedByUser) return true;
    }
    return false;
  }

  /// Returns true if any nested [FormFieldState.hasError].
  bool get hasError {
    for (final field in fields) {
      if (field.hasError) return true;
    }
    for (final form in forms) {
      if (form.hasError) return true;
    }
    return false;
  }

  /// Returns all nested invalid keys of this [FormState].
  Set<String> get invalids => {
        for (final field in fields)
          if (!field.isValid) field.key!,
        for (final form in forms) ...form.invalids,
      };

  /// Returns true if all nested [FormFieldState.isValid].
  bool get isValid {
    for (final field in fields) {
      if (!field.isValid) return false;
    }
    for (final form in forms) {
      if (!form.isValid) return false;
    }
    return true;
  }

  /// Returns true if all nested [FormFieldStateExtension.isInitial].
  bool get isInitial {
    for (final field in fields) {
      if (!field.isInitial) return false;
    }
    for (final form in forms) {
      if (!form.isInitial) return false;
    }
    return true;
  }

  /// Returns all [FormFieldState.errorText] of this [FormState].
  Map<String, String> get errorTexts => {
        for (final field in fields)
          if (field.hasError) field.key!: field.errorText!,
        for (final form in forms) ...form.errorTexts,
      };

  /// Fills this [FormState] with new [map].
  ///
  /// If [format] is `true`, [TextField.inputFormatters] will be applied.
  void fill(Map<String, dynamic> map, {bool format = true}) {
    for (final field in fields) {
      if (map.containsKey(field.key)) {
        final value = field.maybeFormat(map[field.key], format);

        field.maybeChange(value);
      }
    }
    for (final form in forms) {
      if (map.containsKey(form.key)) {
        final values = map[form.key];
        assert(
          values is Map,
          'Invalid form fill: "${form.key}" got a ${values.runtimeType}.',
        );
        if (values is! Map) continue;

        form.fill(values.cast(), format: format);
      }
    }
  }

  Map<String, dynamic> get _debugMap => IndentedMap({
        for (final field in fields) field.key!: field.debugText,
        for (final form in forms) form.key!: form._debugMap,
      });

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

  // we cache the children to avoid unnecessary recursion.
  static final _cache = <FormState, Set<State>>{};

  /// Returns the children [FormState]/[FormFieldState] of this [Form].
  /// - A [State] is considered a child if its `key.value != null`.
  Set<State> get children {
    final states = _cache[this] ??= <State>{};
    if (states.isNotEmpty) return states;

    void visit(Element el) {
      if (el case StatefulElement(:FormState state)) {
        if (state.key != null) states.add(state);
        return;
      }
      if (el case StatefulElement(:FormFieldState state)) {
        state.attachToValidator();
        if (state.key != null) states.add(state);
      }

      el.visitChildren(visit);
    }

    context.visitChildElements(visit);

    // we refresh it on next frame as a field could've be added/removed.
    WidgetsBinding.instance.addPostFrameCallback((_) => _cache.remove(this));

    return states;
  }

  /// Returns the children [FormState] of this [Form] tree.
  Iterable<FormxState> get forms sync* {
    for (final state in children) {
      if (state is FormState) yield FormxState(state);
    }
  }

  /// Returns the children [FormFieldState] of this [Form] tree.
  Iterable<FormFieldState> get fields sync* {
    for (final state in children) {
      if (state is FormFieldState) yield state;
    }
  }

  /// Visits all [FormFieldState] and [FormState] of this [Form] tree.
  ///
  /// - [onForm] is called for each [FormState].
  /// - [onField] is called for each [FormFieldState].
  @protected
  Map<String, R> visit<R>({
    List<String>? keys,
    R Function(String key, FormxState state)? onForm,
    R Function(String key, FormFieldState state)? onField,
  }) {
    assert(onForm != null || onField != null);

    final results = <String, R>{};
    final found = {
      for (final key in [...?keys]) key: false,
    };

    for (final state in children) {
      if (state.key case String key when keys?.contains(key) ?? true) {
        found[key] = true;

        // onForm
        if ((state, onForm) case (FormState state, var fn?)) {
          results[key] = fn(key, FormxState(state));
        }

        // onField
        if ((state, onField) case (FormFieldState state, var fn?)) {
          results[key] = fn(key, state);
        }

        // if all keys are found, stop.
        if (keys != null && found.values.every((e) => e)) break;
      }
    }

    final missingKeys = found.entries.where((e) => !e.value).map((e) => e.key);
    final foundKeys = found.entries.where((e) => e.value).map((e) => e.key);

    assert(
      keys == null || missingKeys.isEmpty,
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
