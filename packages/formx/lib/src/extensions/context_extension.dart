import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/formx_options.dart';
import 'form_field_state_extension.dart';
import 'formx_state.dart';

/// Extension for [BuildContext] to access the main [FormState].
extension FormxContextExtension on BuildContext {
  /// The main [FormxState] of this [BuildContext].
  ///
  /// Provide a [key] to search for a specific [Form] by its key. If absent,
  /// the root [Form] is returned.
  FormxState formx([String? key]) => FormxState(_form(key));

  /// Gets the [FormFieldState] of type [T] by [key].
  FormFieldState<T> field<T>(String key) => _field<T>(key);

  /// Submits the [FormState] of this [BuildContext].
  ///
  /// - Performs [FormState.validate], [FormState.save] and [Formx.toMap].
  /// - Throws an [Exception] with [Formx.errorTexts] if invalid.
  Map<String, dynamic> submit({
    String? key,
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
  /// - Performs [FormState.validate], [FormState.save] and [Formx.toMap].
  /// - Returns `null` if the form is invalid.
  Map<String, dynamic>? trySubmit({
    String? key,
    FormxOptions? options,
    List<String>? keys,
  }) {
    try {
      return submit(key: key, options: options, keys: keys);
    } catch (_) {
      return null;
    }
  }

  /// Fills this [FormState] with new [map].
  ///
  /// If [format] is true, [TextField.inputFormatters] will be applied.
  void fill(Map<String, dynamic> map, {String? key, bool format = true}) {
    formx(key).fill(map, format: format);
  }

  /// Calls [callback] when [FormState] is on its initial state.
  ///
  /// This is useful for setting initial values, for example.
  void onInitialForm(ValueSetter<FormxState> callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = formx();
      if (!state.hasInteractedByUser && state.isInitial) {
        callback(state);
      }
    });
  }

  /// Debugs the [FormState] of this [BuildContext].
  void debugForm([String? key]) {
    if (kDebugMode) formx(key).debug();
  }

  FormFieldState<T> _field<T>(String key) {
    assert(
      !debugDoingBuild,
      'Called `context.field` during build, which is not allowed.\n'
      'This shortcut can only be used outside the build method, like\n'
      'onChanged, onPressed, etc.\n\n'
      'Ex:\n'
      '```dart\n'
      'void submit() {\n'
      "  final state = context.field('email');\n"
      '  if (state.validate()) print(state.value);\n'
      '}\n'
      '```',
    );

    final fieldState = _visitField<T>(key) ??
        Navigator.maybeOf(this)?.context._visitField<T>(key);

    assert(fieldState != null, 'No [FormFieldState<$T>] found. key: $key');
    return fieldState!;
  }

  FormState _form([String? key]) {
    assert(
      !debugDoingBuild,
      'Called `context.formx` during build, which is not allowed.\n'
      'This shortcut can only be used outside the build method, like\n'
      'onChanged, onPressed, etc.\n\n'
      'Ex:\n'
      '```dart\n'
      'Form(\n'
      '  onChanged: () => print(context.formx().toMap()),\n'
      ')\n'
      '```',
    );

    // we limit the search to the current scope for performance reasons.
    final formState = findAncestorStateOfType<FormState>()?.byKey(key) ??
        _visitForm(key) ??
        Navigator.maybeOf(this)?.context._visitForm(key);

    assert(formState != null, 'No [Form] found. key: $key');
    return formState!;
  }

  FormState? _visitForm(String? key) {
    FormState? formState;
    void visit(Element el) {
      if (el case StatefulElement(:FormState state)) {
        if (key == null || FormxState(state).key == key) formState = state;
      }
      if (formState == null) el.visitChildren(visit);
    }

    visitChildElements(visit);
    return formState;
  }

  FormFieldState<T>? _visitField<T>(String key) {
    FormFieldState<T>? fieldState;
    void visit(Element el) {
      if (el case StatefulElement(:FormFieldState<T> state)) {
        if (state.key == key) fieldState = state;
      }
      if (fieldState == null) el.visitChildren(visit);
    }

    visitChildElements(visit);
    return fieldState;
  }
}

extension on FormState {
  FormState? byKey(String? key) {
    if (key == null) return root;
    if (key == this.key) return this;
    return parent?.byKey(key);
  }
}
