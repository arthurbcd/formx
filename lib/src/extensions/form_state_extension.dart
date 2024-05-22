import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../formx.dart';
import 'form_field_state_extension.dart';

/// Extension for [BuildContext] to access the [FormState].
extension FormStateExtension on FormState {
  /// The parent [FormState] of this [Form] node.
  FormState? get parent => Form.maybeOf(context);

  /// The root [FormState] of this [Form] tree. Can be itself.
  FormState get root => parent?.root ?? this;

  /// The [Key] `value` of this [FormState].
  String? get key => widget.key?.value;

  /// Returns a structured map with all keyed [FormFieldState.value].
  Map<String, dynamic> get values {
    final map = <String, dynamic>{};
    visit(
      onField: (key, state) => map[key] = state.value,
      onForm: (key, state) => map[key] = state.values,
      shouldStop: (key, state) => state is FormState,
    );
    return IndentedMap(map);
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

  /// Returns true if all nested [FormFieldState.isValid].
  bool get isValid {
    var isValid = true;
    visit(
      onField: (key, state) {
        if (!state.isValid) isValid = false;
      },
      shouldStop: (key, state) => state is FormFieldState && !state.isValid,
    );
    return isValid;
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

  /// Fills this [FormState] with new [values]. Null values are ignored.
  void fill(Map<String, dynamic> values) {
    visit(
      onField: (key, state) {
        if (values[key] case var value?) state.didChange(value);
      },
      onForm: (key, state) {
        if (values[key] case Map<String, dynamic> map) state.fill(map);
      },
      shouldStop: (key, state) => state is FormState,
    );
  }

  /// Gets the [FormFieldState.value] by [key] as [T].
  T value<T>(String key) => this[key].value as T;

  /// Gets the [FormFieldState.value] by [key] as [String].
  String string(String key) => this[key].string;

  /// Gets the [FormFieldState.value] by [key] as [num].
  num number(String key) => this[key].number;

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

  /// Gets a [FormFieldState] by [key] in this [FormState.context].
  FormFieldState operator [](String key) => context.field(key);

  /// Sets either a [FormFieldState.value] or [values] by [key].
  ///
  /// This is useful for setting values programatically.
  ///
  /// ```dart
  /// formState['name'] = 'John Doe';
  /// ```
  ///
  /// You can also fill a specific [Form] by setting a [Map] value.
  ///
  /// ```dart
  /// formState['address'] = {
  ///  'street': 'Main St',
  ///  'number': 123,
  ///  'zip': '12345-678',
  /// };
  /// ```
  ///
  void operator []=(String key, Object value) {
    assertKeys([key], 'set');
    visit(
      onField: (k, state) {
        if (k == key) state.didChange(value);
      },
      onForm: (k, state) {
        if (k == key) state.fill(value.cast());
      },
      shouldStop: (k, state) => k == key,
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
