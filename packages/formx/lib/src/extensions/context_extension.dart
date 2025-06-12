// ignore_for_file: type_annotate_public_apis

import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../formx_state.dart';
import '../models/formx_options.dart';
import '../validator/validator.dart';
import 'form_field_state_extension.dart';

/// Extension for [BuildContext] to access the main [FormState].
extension ContextFormx on BuildContext {
  /// The main [FormxState] of this [BuildContext].
  ///
  /// Provide a [key] to search for a specific [Form] by its key. If absent,
  /// the root [Form] is returned.
  FormxState formx(String key) => FormxState(_form(key));

  /// Gets the [FormFieldState] of type [T] by [key].
  FormFieldState<T> field<T>(String key) => _field<T>(key)..attachToValidator();

  /// Submits the [FormState] of this [BuildContext].
  ///x
  /// - Performs [FormState.validate], [FormState.save] and [FormxState.toMap].
  /// - Throws an [Exception] with [FormxState.errorTexts] if invalid.
  Map<String, dynamic> submit(
    String key, {
    FormxOptions? options,
    String? errorMessage,
    List<String>? keys,
  }) {
    return formx(key).submit(
      options: options,
      errorMessage: errorMessage,
      keys: keys,
    );
  }

  /// Submits the [FormState] of this [BuildContext].
  ///
  /// - Performs [FormState.validate], [FormState.save] and [FormxState.toMap].
  /// - Returns `null` if the form is invalid.
  Map<String, dynamic>? trySubmit(
    String key, {
    FormxOptions? options,
    List<String>? keys,
  }) {
    try {
      return submit(key, options: options, keys: keys);
    } catch (_) {
      return null;
    }
  }

  /// Fills this [FormState] with new [map].
  ///
  /// If [format] is true, [TextField.inputFormatters] will be applied.
  void fill(String key, Map<String, dynamic> map, {bool format = true}) {
    formx(key).fill(map, format: format);
  }

  /// Debugs the [FormState] of this [BuildContext].
  void debugForm(String key) {
    if (kDebugMode) formx(key).debug();
  }

  static final _fieldCache = _StateCache<FormFieldState>();

  FormFieldState<T> _field<T>(String key) {
    assert(
      !debugDoingBuild,
      'Called `context.field` during build, which is not allowed.\n'
      'Visiting can only be done outside the build phase, e.g:\n'
      'onChanged, onPressed, etc.\n\n'
      'Ex:\n'
      'void submit() {\n'
      "  final state = context.field('email');\n"
      '  if (state.validate()) print(state.value);\n'
      '}\n',
    );

    final fieldState = _fieldCache[(this, key)] ??= _visitField<T>(key) ??
        findAncestorStateOfType<FormState>()?.context._visitField<T>(key) ??
        Navigator.maybeOf(this)?.context._visitField<T>(key);

    assert(fieldState != null, 'No [FormFieldState<$T>] found. key: $key');
    assert(
      fieldState is FormFieldState<T>,
      'Invalid ${fieldState.runtimeType} found. Expected FormFieldState<$T>.',
    );
    return fieldState! as FormFieldState<T>;
  }

  static final _formCache = _StateCache<FormState>();

  FormState _form(String key) {
    assert(
      !debugDoingBuild,
      'Called `context.formx` during build, which is not allowed.\n'
      'Visiting can only be done outside the build phase, e.g:\n'
      'onChanged, onPressed, etc.\n\n'
      'Ex:\n'
      'Form(\n'
      '  onChanged: () => print(context.formx("key").toMap()),\n'
      ')\n',
    );

    // this makes subsequent calls O(1)
    final formState = _formCache[(this, key)] ??=
        findAncestorStateOfType<FormState>()?.byKey(key) ??
            _visitForm(key) ??
            Navigator.maybeOf(this)?.context._visitForm(key);

    assert(formState != null, 'No [Form] found. key: $key');
    return formState!;
  }

  FormState? _visitForm(String key) {
    final keys = key.split('.');

    FormState? formState;
    void visit(Element el) {
      if (el case StatefulElement(:FormState state)) {
        if (keys.length > 1 && !listEquals(keys, state.keys)) {
          return el.visitChildren(visit);
        }
        if (keys.length <= 1 && keys.singleOrNull != state.key) {
          return el.visitChildren(visit);
        }

        assert(
          formState == null || state.keys.isEmpty,
          'Duplicate [Form.key] found: $key.\n\n'
          '${formState?.widget.runtimeType}(\n'
          "  key: Key('$key'), \n"
          ')\n'
          '${state.widget.runtimeType}(\n'
          "  key: Key('$key'), <- duplicate  \n"
          ')\n'
          'Duplicated keys in the same level are not allowed.\n\n'
          'Provide a unique key for each [Form].\n',
        );
        assert(
          formState == null || state.keys.isNotEmpty,
          'Duplicate [Form.key] found: $key.\n\n'
          '${formState?.widget.runtimeType}(\n'
          "  key: Key('$key'), \n"
          ')\n'
          '${state.widget.runtimeType}('
          "  key: Key('$key'), <- duplicate  \n"
          ')\n\n'
          'Be more specific when visiting, try:\n'
          "final $key = context.formx('${state.keys.join('.')}');\n",
        );
        formState = state;
      }
      if (formState == null || kDebugMode) el.visitChildren(visit);
    }

    visitChildElements(visit);
    return formState;
  }

  FormFieldState<T>? _visitField<T>(String key) {
    final keys = key.split('.');

    FormFieldState<T>? fieldState;

    void visit(Element el) {
      if (el case StatefulElement(:FormFieldState<T> state)) {
        if (state.key == null) return;

        if (keys.length != 1 && !listEquals(keys, state.keys)) {
          return;
        }
        if (keys.length == 1 && keys.single != state.key) {
          return;
        }

        assert(
          fieldState == null || state.keys.isNotEmpty,
          'Duplicate [FormField.key] found: $key.\n\n'
          '${fieldState?.widget.runtimeType}(\n'
          "  key: Key('$key'), \n"
          ')\n'
          '${state.widget.runtimeType}(\n'
          "  key: Key('$key'), <- duplicate  \n"
          ')\n'
          'Duplicated keys in the same [Form] are not allowed.\n\n'
          'Provide a unique key for each [FormField]\n',
        );
        assert(
          fieldState == null || state.keys.isEmpty,
          'Duplicate [FormField.key] found: $key.\n\n'
          '${fieldState?.widget.runtimeType}(\n'
          "  key: Key('$key'), \n"
          ')\n'
          '${state.widget.runtimeType}(\n'
          "  key: Key('$key'), <- duplicate  \n"
          ')\n\n'
          'Be more specific when visiting, try either:\n\n'
          "final $key = context.field('${fieldState?.keys.join('.')}');\n"
          "final ${key}Child = context.field('${state.keys.join('.')}');\n"
          '\n',
        );
        fieldState = state;
      }
      if (fieldState == null || kDebugMode) el.visitChildren(visit);
    }

    visitChildElements(visit);
    return fieldState;
  }
}

extension on FormFieldState {
  List<String> get keys => [...?parent?.keys, if (key != null) key!];
  FormState? get parent => Form.maybeOf(context);
}

extension on FormState {
  List<String> get keys => [...?parent?.keys, if (key != null) key!];

  FormState? byKey(String key) {
    if (key == this.key) {
      assert(
        parent?.key != key,
        'Duplicated [Form.key] found: $key.\n\n'
        'Direct parent/child [Form.key] should be different:\n'
        '${parent?.widget.runtimeType}(\n'
        "  key: Key('$key'), \n"
        '  child: ${widget.runtimeType}(\n'
        "    key: Key('$key'), <- duplicated \n"
        '  )\n'
        ');\n'
        '.\n',
      );
      return this;
    }

    // look for nested forms, ex: 'nested.form'
    if (key.split('.') case var keys when keys.length > 1) {
      FormState? state = this;

      for (final (index, key) in keys.indexed) {
        if (state?.key != key) break;
        state = state?.parent;

        if (index < keys.length - 1) continue;
        return this;
      }
    }

    return parent?.byKey(key);
  }
}

class _StateCache<T extends State> extends MapBase<(BuildContext, String), T?> {
  final cache = <(BuildContext, String), T>{};

  @override
  T? operator [](key) {
    if (cache[key] case var state? when state.mounted) {
      return state;
    }
    cache.remove(key);
    return null;
  }

  @override
  void operator []=(key, state) {
    if (state == null || !state.mounted) return;
    if (cache[key] == state) return;

    // we only trigger the garbage collector when adding a new value
    // so reading is always O(1)
    keys.length;
    cache[key] = state;
  }

  @override
  Iterable<(BuildContext, String)> get keys sync* {
    final garbage = <Object?>[];

    for (final key in cache.keys) {
      if (key case (BuildContext it, _) when it.mounted) {
        yield key;
      } else {
        garbage.add(key);
      }
    }

    garbage.forEach(cache.remove);
  }

  @override
  T? remove(key) => cache.remove(key);

  @override
  void clear() => cache.clear();
}
