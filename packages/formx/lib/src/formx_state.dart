// ignore_for_file: invalid_use_of_protected_member

import 'dart:collection';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../formx.dart';
import 'validator/validator.dart';

extension FormxStateExtension on FormxState {
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

extension on State {
  String? get key => widget.key?.value;
}

extension<T> on FormFieldState<T> {
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
}

class Formx {
  Formx({
    this.initialValues = const {},
    FormxOptions? options,
  }) {
    _options = options ?? Formx.options;
    _flatInitials.forEach(setValue);
  }

  /// Global setup for all [Formx] widgets.
  static FormxSetup setup = const FormxSetup();

  /// Global options for all [FormxState] methods.
  static FormxOptions options = const FormxOptions();

  /// The default equality to use in [equals].
  /// Defaults to one-depth collections equality.
  static bool Function(dynamic a, dynamic b) defaultEquals =
      (a, b) => switch ((a, b)) {
            (List a, List b) => listEquals(a, b),
            (Set a, Set b) => setEquals(a, b),
            (Map a, Map b) => mapEquals(a, b),
            _ => a == b,
          };

  /// The equality used for isInitial.
  static bool equals(Object? a, Object? b) => defaultEquals(a, b);

  final Map<String, dynamic> initialValues;
  late final _flatInitials = _flatten(initialValues);
  late final FormxOptions _options;

  // states
  final _keys = <String, FieldKey>{};
  final _fields = <String, FormFieldState>{};

  // queues
  final _toValidate = <String>{};
  final _toChange = <String, dynamic>{};

  /// Sets the value of a form field by flat key path.
  ///
  /// This method only supports flat key operations using dot notation,
  /// e.g: "user.name".
  ///
  /// For setting complete structured/nested data, use the `values` setter instead:
  /// ```dart
  /// form.values = {"user": {"name": "John", "email": "john@example.com"}};
  /// ```
  void setValue(String key, dynamic value) {
    _toChange.remove(key);

    void setField(FormFieldState field) {
      final formattedValue = field.maybeFormat(value, true);

      if (field.mounted) {
        field.didChange(formattedValue);
      } else {
        field.setValue(formattedValue);
      }
    }

    return switch (_fields[key]) {
      var field? => setField(field),
      _ => _toChange[key] = value,
    };
  }

  Map<String, dynamic> get values {
    final map = Mapx();
    for (final (key, field) in _fields.pairs) {
      map[key] = field.toValue(options: _options);
    }
    for (final (key, value) in _toChange.pairs) {
      map[key] = value;
    }
    return map.cleaned(
      nonNulls: _options.nonNulls,
      nonEmptyMaps: _options.nonEmptyMaps,
      nonEmptyStrings: _options.nonEmptyStrings,
      nonEmptyIterables: _options.nonEmptyIterables,
    );
  }

  set values(Map<String, dynamic> map) {
    _flatten(map).forEach(setValue);
  }

  Map<String, dynamic> _flatten(
    Map<String, dynamic> map, [
    String prefix = '',
  ]) {
    final result = <String, dynamic>{};

    for (final e in map.entries) {
      final key = prefix.isEmpty ? e.key : '$prefix.${e.key}';

      if (e.value case Map<String, dynamic> map) {
        result.addAll(_flatten(map, key));
      } else {
        result[key] = e.value;
      }
    }

    return result;
  }

  /// Check if every field is in its initial state.
  bool get isInitial {
    for (final (key, field) in _fields.pairs) {
      if (_flatInitials.containsKey(key)) {
        if (!Formx.equals(field.value, _flatInitials[key])) {
          return false;
        }
      } else if (!field.isInitial) {
        return false;
      }
    }

    return true;
  }

  /// Check if any field has been interacted by the user.
  bool get hasInteractedByUser {
    for (final (key, field) in _fields.pairs) {
      if (_flatInitials.containsKey(key)) {
        if (!Formx.equals(field.value, _flatInitials[key])) {
          return true;
        }
      } else if (field.hasInteractedByUser) {
        return true;
      }
    }

    return false;
  }

  /// Registers a [FieldKey] for the given [key].
  Key key(
    String key, {
    bool? keepMask,
    String? Function(String, TextInputFormatter)? unmasker,
    dynamic Function(dynamic)? adapter,
  }) {
    final fieldKey = _keys[key] ??= FieldKey(
      key,
      keepMask: keepMask,
      unmasker: unmasker,
      adapter: adapter,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final oldField = _fields[key];
      final field = fieldKey.currentState;

      if (field == null) {
        throw Exception('FieldKey $key is not attached to a FormField.');
      }

      // field is already mounted, nothing to do.
      if (oldField == field) return;
      _fields[key] = field;

      if (oldField == null) {
        if (_toChange.containsKey(key)) {
          setValue(key, _toChange.remove(key));
        }
      } else {
        // if both are not null, we need to sync them.
        field.didChange(oldField.value);
      }

      if (_toValidate.remove(key)) {
        if (!field.validate()) _toValidate.add(key);
      }
    });

    return fieldKey;
  }

  // TODO(arthurbcd): this only validates registered fields.
  bool validate() {
    final invalids = <String>{};

    _flatInitials.keys.forEach(_toValidate.add);

    for (final (key, field) in _fields.pairs) {
      if (field.mounted) {
        _toValidate.remove(key);
        field.validate();
      } else {
        _toValidate.add(key);
      }
      if (!field.isValid) invalids.add(key);
    }

    return invalids.isEmpty;
  }

  void reset() {
    _toValidate.clear();

    for (final (key, field) in _fields.pairs) {
      final hasInitial = _flatInitials.containsKey(key);
      final value = hasInitial ? _flatInitials[key] : field.widget.initialValue;

      if (field.mounted) {
        field.reset();
        if (hasInitial) field.didChange(value);
      } else {
        setValue(key, value);
      }
    }
    for (final key in _toChange.keys.where(_flatInitials.containsKey)) {
      setValue(key, _flatInitials[key]);
    }
  }
}

class Mapx extends MapBase<String, dynamic> {
  Mapx([Map<String, dynamic>? map]) : _map = map ?? <String, dynamic>{};

  final Map<String, dynamic> _map;

  @override
  dynamic operator [](Object? key) {
    // Handle simple case
    if (key is! String || !key.contains('.')) {
      return _map[key];
    }

    // Handle dot notation for nested access
    final parts = key.split('.');
    dynamic current = _map;

    for (var i = 0; i < parts.length; i++) {
      if (current is! Map) return null;

      final part = parts[i];
      if (i == parts.length - 1) {
        return current[part];
      }

      current = current[part];
      if (current == null) return null;
    }

    return null;
  }

  @override
  void operator []=(String key, dynamic value) {
    // Handle simple case
    if (!key.contains('.')) {
      _map[key] = value;
      return;
    }

    // Handle dot notation for nested setting
    final parts = key.split('.');
    dynamic current = _map;

    for (var i = 0; i < parts.length - 1; i++) {
      final part = parts[i];

      // Create intermediate maps as needed
      if (current[part] == null) {
        current[part] = <String, dynamic>{};
      } else if (current[part] is! Map) {
        current[part] = <String, dynamic>{};
      }

      current = current[part];
    }

    current[parts.last] = value;
  }

  @override
  void clear() => _map.clear();

  @override
  Iterable<String> get keys => _map.keys;

  @override
  dynamic remove(Object? key) => _map.remove(key);
}
