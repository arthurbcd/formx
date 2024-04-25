import 'package:flutter/widgets.dart';

import '../formx_state.dart';
import 'form_field_state_extension.dart';
import 'form_state_extension.dart';

/// Extension for [BuildContext] to access the main [FormState].
extension FormxContextExtension on BuildContext {
  /// The main [FormxState] of this [BuildContext].
  ///
  /// Provide a [key] to search for a specific [Form] by its key. If absent,
  /// the root [Form] is returned.
  FormxState formx([String? key]) => FormxState(_form(key));

  FormState _form([String? key]) {
    assert(
      !debugDoingBuild,
      'Called `context.formx` during build, which is not allowed.\n'
      'This shortcut can only be used outside the build method, like\n'
      'onChanged, onPressed, etc.\n\n'
      'Ex:\n'
      '```dart\n'
      'Form(\n'
      '  onChanged: () => print(context.form().values),\n'
      ')\n'
      '```',
    );

    // we limit the search to the current scope for performance reasons.
    final formState = findAncestorStateOfType<FormState>()?.byKey(key) ??
        _visitForm(key) ??
        Navigator.maybeOf(this)?.context._visitForm(key);

    assert(formState != null, 'No [Form] found in this context. key: $key');
    return formState!;
  }

  FormState? _visitForm(String? key) {
    FormState? formState;
    void visit(Element el) {
      if (el case StatefulElement(:FormState state)) {
        if (key == null || state.key == key) {
          formState = state;
          return;
        }
      }
      el.visitChildren(visit);
    }

    visitChildElements(visit);
    return formState;
  }

  /// Shortcut to call parent [FormState]'s [Form.onChanged] method.
  ///
  /// This is useful when you have nested forms and you want to centralize all
  /// changes in the root [Form.onChanged] method.
  ///
  /// ```dart
  /// Form(
  ///   onChanged: () => print(context.form().values),
  ///   child: Column(
  ///     children: [
  ///       Form(
  ///         onChanged: context.onFormChanged, // <-- call parent onChanged.
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  VoidCallback get onFormChanged => () => _form().widget.onChanged?.call();

  /// Gets the [FormFieldState] of type [T] by [key].
  FormFieldState<T> field<T>(String key) {
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

  FormFieldState<T>? _visitField<T>(String key) {
    FormFieldState<T>? fieldState;
    void visit(Element el) {
      if (el case StatefulElement(:FormFieldState<T> state)) {
        if (state.key == key) {
          fieldState = state;
          return;
        }
      }
      el.visitChildren(visit);
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
