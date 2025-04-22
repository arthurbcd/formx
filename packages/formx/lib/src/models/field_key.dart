import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../formx.dart';

/// A [Key] for customizing [Formx.toMap] & other outputs.
class FieldKey<T> extends GlobalKey<FormFieldState<T>> {
  /// Creates a [FieldKey] with a [key].
  FieldKey(
    this.key, {
    this.keepMask,
    this.unmasker,
    this.adapter,
  }) : super.constructor() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final (state, element) = (currentState, currentContext);
      if (state == null && element is! Element) return;

      final field = (element! as StatefulElement).state;
      String? subtype;

      if (field is FormFieldState) {
        subtype = field.value?.runtimeType.toString();
      }
      assert(
        state != null,
        'Field key type `$T` incompatible '
        'with ${field.widget.runtimeType} `$subtype`',
      );
    });
  }

  /// The [FormField.key] value.
  @protected
  final String key;

  /// Whether to unmask the value. Overrides [FormxOptions.keepMask].
  final bool? keepMask;

  /// The unmasker function to unmask the value.
  final Unmasker? unmasker;

  /// The adapter function to convert the [T] to any value.
  final FieldAdapter<T>? adapter;

  /// Resolves the [FormxOptions] for this [FieldKey].
  @protected
  FormxOptions options([FormxOptions? options]) {
    options ??= Formx.options;

    return options.copyWith(
      keepMask: keepMask,
      unmasker: unmasker,
      adapter: adapter != null ? _maybeAdapt : null,
    );
  }

  /// Adapts the [value] if same type. Otherwise, returns the same [value].
  dynamic _maybeAdapt(Object value) {
    final t = value.runtimeType;
    final key = this.key;
    assert(
      value is T,
      "Invalid `Key('$key')` adapter: $t is not a subtype of $T.\n\n"
      ' ❌ Invalid:\n'
      '`adapter: ($T value) => value.toSomething()`\n\n'
      ' ✅ Valid:\n'
      '`adapter: ($t value) => value.toSomething()`\n\n'
      'You should use an adapter compatible with this `FormState<$t>`\n',
    );
    if (value is! T) return value;

    return adapter!(value as T);
  }
}

class FormKey extends GlobalKey<FormState> {
  // factory FormKey(String value) => FormKey._(value);
  FormKey([this.key]) : super.constructor() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final (state, element) = (currentState, currentContext);
      if (state == null && element is! Element) return;

      assert(
        state != null,
        '${element?.widget.runtimeType} is not a Form widget',
      );
    });
  }

  /// The [Form.key] value.
  @protected
  final String? key;
}

extension FormxFormKeyExtension on GlobalKey<FormState> {
  /// Requires the [FormxState] of this [FormState].
  FormxState get state => FormxState(currentState!);
}

extension FormxFormFieldKeyExtension on GlobalKey<FormFieldState> {
  /// Requires the [FormxFieldState] of this [FormFieldState].
  FormFieldState get state => currentState!;
}

/// Extension for [Key] value.
extension FormFieldKeyExtension on Key {
  /// Creates a [FieldKey] of type [T] of this [Key].
  ///
  /// - [adapter] is a function to adapt the [T] value to any value.
  /// - [keepMask] overrides [FormxOptions.keepMask].
  ///
  /// The type [T] must be the same type defined in the associated [FormField].
  /// This [Key] value must be a [String]. Otherwise, [ArgumentError] is thrown.
  FieldKey<T> options<T>({
    bool? keepMask,
    Unmasker? unmasker,
    FieldAdapter<T>? adapter,
  }) {
    return FieldKey(
      ArgumentError.checkNotNull(value, 'value'),
      keepMask: keepMask,
      unmasker: unmasker,
      adapter: adapter,
    );
  }

  /// Attempts to get the [value] of this [Key] if it is an [String].
  String? get value {
    if (this case FormKey(key: String value)) return value;
    if (this case FieldKey(key: String value)) return value;
    if (this case ValueKey(:String value)) return value;
    if (this case ObjectKey(:String value)) return value;
    if (this case GlobalObjectKey(:String value)) return value;
    return null;
  }
}

///
extension FormFieldOptionsExtension on FormFieldState {
  /// Resolves the [FormxOptions] for this [FormFieldState].
  FormxOptions getOptions([FormxOptions? options]) => _options(options);
}

///
extension FormOptionsExtension on FormState {
  /// Resolves the [FormxOptions] for this [FormState].
  FormxOptions getOptions([FormxOptions? options]) => _options(options);
}

extension on State {
  FormxOptions _options(FormxOptions? options) {
    options ??= Formx.options;

    return widget.key?.tryCast<FieldKey>()?.options(options) ?? options;
  }
}
