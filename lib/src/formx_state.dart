import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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
  /// Behaves like [Form.of] but returns a [FormxState] instead.
  ///
  /// This will not search the tree like `context.formx` does, and will also
  /// rebuild the widget tree when the form changes.
  static FormxState of(BuildContext context) => FormxState(Form.of(context));
}
