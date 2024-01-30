// ignore_for_file: public_member_api_docs, invalid_use_of_protected_member

import 'package:flutter/material.dart';

import '../extensions/context.dart';
import 'text_formx_field.dart';

/// A widget that builds a form with [TextFormxField] widgets.
class Formx extends StatefulWidget {
  /// A widget that builds a form with [TextFormxField] widgets.
  ///
  /// A form can also be nested in another [Formx] for more complex forms.
  ///
  /// Use `Formx.at/of(context)` or `GlobalKey` to access the formx state.
  ///
  /// Example:
  ///
  /// ```dart
  /// Formx(
  ///   tag: null,
  ///   child: Formx(
  ///     tag: 'my_nested_form',
  ///     child: TextFormxField('my_field'),
  ///   ),
  /// )
  /// ```
  ///
  /// Which results in the form:
  ///
  /// ```dart
  /// {
  ///  'my_nested_form': {'my_field': 'value'},
  /// }
  const Formx({
    super.key,
    this.tag,
    this.enabled,
    this.initialValues,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.fieldWrapper,
    this.fieldModifier,
    this.valueModifier,
    this.errorTextModifier,
    this.decorationModifier,
    this.autovalidateMode,
    required this.child,
  });

  /// When present, links this form to a parent [FormxState.form]. This also enables parent/child callbacks.
  /// The tagged form map will be nested in the parent form map.
  ///
  /// Ex: {'my_tag': {'my_field': 'value'}}
  final String? tag;

  /// When false, disables all descendants.
  final bool? enabled;

  /// The initial value for each [TextFormxField.tag] or nested [Formx.tag].
  final FormMap? initialValues;

  /// Listens to all changes of this [FormxState.form].
  final FormCallback? onChanged;

  /// Called when `onFieldSubmitted` or `submit()` are called and valid.
  final FormCallback? onSubmitted;

  /// Called when [FormxState.save] is called.
  final FormCallback? onSaved;

  /// Wrapper for each resolved field [Widget].
  final FieldWrapper? fieldWrapper;

  /// Modifier for each [TextFormxField].
  final FieldModifier? fieldModifier;

  /// Modifier for each [FormMap] value. [FormxState.form] is built with this.
  final ValueModifier? valueModifier;

  /// Modifier for each `TextFormxField.validator` errorText.
  final ErrorTextModifier? errorTextModifier;

  /// Modifier for each `TextFormxField.decoration`.
  final DecorationModifier? decorationModifier;

  /// When null, starts disabled and changes to always on [onSubmitted].
  final AutovalidateMode? autovalidateMode;

  /// The widget tree with [TextFormxField] widgets (or [Formx] with [tag]).
  final Widget child;

  /// When true, disables all validators. Works only on debug mode.
  static bool disableValidatorsOnDebugMode = false;

  /// Returns the first [FormxState] above [BuildContext].
  static FormxState of(BuildContext context) {
    final maybe = maybeOf(context);
    assert(maybe != null, 'No [Formx] of this context.');
    return maybe!;
  }

  /// Returns the first [FormxState] above [BuildContext] or null.
  static FormxState? maybeOf(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<_FormxScope>()
        ?.widget as _FormxScope?;

    return widget?.state;
  }

  /// Returns the first [FormxState] below [context]. Filters by [key] or [tag].
  static FormxState at(BuildContext context, {Key? key, String? tag}) {
    return context.visitState(
      assertType: 'Formx',
      filter: (state) =>
          (tag == null || tag == state.widget.tag) &&
          (key == null || key == state.widget.key),
    );
  }

  @override
  State<Formx> createState() => FormxState();
}

/// Map signature for [Formx] form, where:
/// - `key` is the [TextFormxField.tag] or [Formx.tag].
/// - `value` is either a field value [String] or a nested form [FormMap].
typedef FormMap = Map<String, dynamic>;

/// Signature for [FormMap] callback.
typedef FormCallback = void Function(FormMap form);

/// Signature for field wrapper by [TextFormxField.tag].
typedef FieldWrapper = Widget Function(String tag, Widget widget);

/// Signature for field modifier by [TextFormxField.tag].
typedef FieldModifier = TextFormxField Function(
  String tag,
  TextFormxField field,
);

/// Signature for form value modifier by [Formx.tag].
typedef ValueModifier = dynamic Function(String tag, dynamic value);

/// Signature for error text modifier by [TextFormxField.tag].
typedef ErrorTextModifier = String Function(String tag, String errorText);

/// Signature for decoration modifier by [TextFormxField.tag].
typedef DecorationModifier = InputDecoration? Function(
  String tag,
  InputDecoration? decoration,
);

/// A [Map] of [FormxState] by [Formx.tag].
typedef FormxStateMap = Map<String, FormxState>;

/// A [Map] of [FormFieldState] by [TextFormxField.tag].
typedef FieldStateMap = Map<String, TextFormxFieldState>;

/// The state of a [Formx] widget.
///
/// You can access the state using [Formx.key], [Formx.of] or [Formx.at].
class FormxState extends State<Formx> {
  /// The parent [FormxState] descendant of this [context].
  late final FormxState? parent = () {
    final scope = Formx.maybeOf(context);
    if (!hasTag) return scope;
    assert(
      hasTag && scope != null,
      'This [Formx] has a tag but no parent was found. '
      'When [tag] is present, you must wrap this form '
      'in a parent [Formx] widget',
    );
    scope?._nested[widget.tag!] = this;
    return scope;
  }();

  /// Whether this [Formx] has a tag.
  bool get hasTag => widget.tag != null;

  // * Formx inheritance
  bool? get enabled => widget.enabled ?? (hasTag ? parent?.enabled : null);
  FieldWrapper? get fieldWrapper => widget.fieldWrapper ?? parent?.fieldWrapper;
  ValueModifier? get valueModifier =>
      widget.valueModifier ?? parent?.valueModifier;
  FieldModifier? get fieldModifier =>
      widget.fieldModifier ?? parent?.fieldModifier;
  ErrorTextModifier? get errorTextModifier =>
      widget.errorTextModifier ?? parent?.errorTextModifier;
  DecorationModifier? get decorationModifier =>
      widget.decorationModifier ?? parent?.decorationModifier;
  AutovalidateMode? get autovalidateMode =>
      widget.autovalidateMode ?? (hasTag ? parent?.autovalidateMode : null);

  /// The initial values for this [form]. Applied to [_fields] and [_nested].
  late final FormMap initialValues = widget.initialValues != null
      ? Map.of(widget.initialValues!)
      : Map.of(parent?.initialValues[widget.tag] as FormMap? ?? {});

  final _nested = <String, FormxState>{};
  final _fields = <String, TextFormxFieldState>{};

  /// The nested [FormxState] immediate children, keyed by [Formx.tag].
  FormxStateMap get nested => Map.of(_nested);

  /// The [FormFieldState] immediate fields, keyed by [TextFormxField.tag].
  FieldStateMap get fields => Map.of(_fields);

  /// Returns a flat [Map] of all [_fields] and [_nested] errorTexts.
  ///
  /// Note, if they were not validated, they will not be present.
  Map<String, String> get errorTexts {
    final errorTexts = <String, String>{};
    _fields.forEach((tag, field) => errorTexts[tag] = field.errorText ?? '');
    _nested.forEach((tag, formx) => errorTexts.addAll(formx.errorTexts));
    return errorTexts..removeWhere((key, value) => value.isEmpty);
  }

  // /// Returns a [FormMap] if [validate] succeeds, or throws a [FormxException].
  // FormMap submit() {
  //   return trySubmit() ?? (throw FormxException.withErrorTexts(errorTexts));
  // }

  // /// Returns a [FormMap] if [isValid] succeeds, or null.
  // FormMap? trySubmit() {
  //   if (!validate()) return null;
  //   widget.onSubmitted?.call(form);
  //   return form;
  // }

  /// Returns a [FormMap] with all [_fields] and [_nested] values.
  ///
  /// If [valueModifier] is present, it will be applied to each value.
  FormMap get form {
    var form = <String, dynamic>{};

    void maybeModify(String tag, dynamic value) {
      if (valueModifier != null) {
        form[tag] = valueModifier!(tag, value);
      } else {
        form[tag] = value;
      }
    }

    _fields.forEach((tag, field) => maybeModify(tag, field.value));
    _nested.forEach((tag, formx) => maybeModify(tag, formx.form));
    return form;
  }

  /// Returns true if [_fields] or [_nested] have errors. Doesn't set ui state.
  bool get hasError => [
        _fields.values.any((field) => field.hasError),
        _nested.values.any((formx) => formx.hasError),
      ].any((hasError) => hasError);

  /// Returns true if [_fields] and [_nested] are valid. Doesn't set ui state.
  bool get isValid => [
        _fields.values.every((field) => field.isValid),
        _nested.values.every((formx) => formx.isValid),
      ].every((isValid) => isValid);

  /// Validates and returns `true` if all [fields] and [nested] have no errors.
  ///
  /// Additionally, you can specify by:
  /// - Use [tag] or [tags] to validate by [TextFormxField.tag] or [Formx.tag];
  /// - Use [key] or [keys] to validate by [TextFormxField.key] or [Formx.key];
  ///
  /// Usually, you will want to validate by [tag] or [tags]. Only use [key] or
  /// [keys] in case of duplicated tags.
  ///
  /// If no specified validations are called, all [fields] and [nested] will be
  /// validated, as calling `Formx.validate()`.
  ///
  bool validate({String? tag, Key? key, List<String>? tags, List<Key>? keys}) {
    // assert that unmounted fields are valid, as they cannot be validated.
    assertUnmountedFields('validate', (field) => field.isValid);
    final validations = <dynamic, bool>{};

    if (key != null) {
      final state = stateWhere((k, v) => v.widget.key == key);
      if (state is TextFormxFieldState) validations[key] = state.validate();
      if (state is FormxState) validations[key] = state.validate();
      assert(validations.containsKey(key), 'Formx.validate key $key not found');
    }

    if (tag != null) {
      final state = stateWhere((k, v) => k == tag);
      if (state is TextFormxFieldState) validations[tag] = state.validate();
      if (state is FormxState) validations[tag] = state.validate();
      assert(validations.containsKey(tag), 'Formx.validate tag $tag not found');
    }

    if (keys != null) {
      for (final key in keys) {
        validations[key] = validate(key: key);
      }
    }

    if (tags != null) {
      for (final tag in tags) {
        validations[tag] = validate(tag: tag);
      }
    }

    // if any tag/key validations were called, returns if all are valid.
    if (validations.isNotEmpty) {
      return validations.values.every((isValid) => isValid);
    }

    // otherwise, validates all fields and nested.
    _fields.mounted.forEach((tag, field) => field.validate());
    _nested.mounted.forEach((tag, formx) => formx.validate());
    return !hasError;
  }

  /// Fills this [FormxState.form] with new [values].
  ///
  /// Values that are not a [FormMap] or [String] will be stringified.
  void fill(FormMap values) {
    values.forEach((tag, value) {
      if (value is FormMap) _nested[tag]?.fill(value);
      if (value != null) setValue(tag, value.toString());
    });
  }

  /// Resets all [fields] and [nested] to their initial values.
  void reset() {
    // assert that unmounted fields !hasError, as they cannot be reset.
    assertUnmountedFields('reset', (field) => !field.hasError);
    _fields.unmounted.forEach((k, v) => v.setValue(v.widget.initialValue));
    _fields.mounted.forEach((tag, field) => field.reset());
    _nested.forEach((tag, formx) => formx.reset());
  }

  /// Saves this [form], all [fields] and [nested] fields.
  void save() {
    _fields.forEach((tag, field) => field.save());
    _nested.forEach((tag, formx) => formx.save());
    widget.onSaved?.call(form);
  }

  /// Silently sets [value] of the field by [tag]. Does not setState.
  void setValue(String tag, String value) {
    _fields[tag]?.setValue(value);
  }

  /// Sets [value] and state of the field by [tag]. Calls onChanged.
  void didChange(String tag, String value) {
    _fields[tag]?.didChange(value);
  }

  /// Attaches a [TextFormxFieldState] to this [FormxState].
  @protected
  void attachField(String tag, TextFormxFieldState field) {
    _fields[tag] = field;
  }

  /// Reports a change to this [FormxState.form].
  @protected
  void onChanged(String tag, String value) {
    widget.onChanged?.call(form);

    //If tag is present, callbacks to parent.
    if (hasTag) parent?.widget.onChanged?.call(parent!.form);
  }

  /// Reports a submit to this [FormxState.form].
  @protected
  void onSubmitted(String tag, String value) {
    // if (!validate()) return;
    widget.onSubmitted?.call(form);

    //If tag is present, callbacks to parent.
    if (hasTag) parent?.widget.onSubmitted?.call(parent!.form);
  }

  @override
  Widget build(BuildContext context) {
    return _FormxScope(
      state: this,
      child: widget.child,
    );
  }
}

class _FormxScope extends InheritedWidget {
  const _FormxScope({required super.child, required this.state});
  final FormxState state;

  @override
  bool updateShouldNotify(_FormxScope oldWidget) => false;
}

extension on FormxState {
  State? stateWhere(bool Function(String tag, State state) visitor) {
    for (final e in _fields.entries) {
      if (visitor(e.key, e.value)) return e.value;
    }
    for (final e in _nested.entries) {
      if (visitor(e.key, e.value)) return e.value;
    }
    for (final e in _nested.entries) {
      if (e.value.stateWhere(visitor) != null) return e.value;
    }
    return null;
  }

  void assertUnmountedFields(
    String action,
    bool Function(TextFormxFieldState field) test,
  ) {
    final acted = action.endsWith('e') ? '${action}d' : '${action}ed';

    assert(
      _fields.unmounted.values.every(test),
      'Formx: Tried to $action while having unmounted fields below this Formx. '
      'Unmounted fields cannot be $acted once disposed. '
      'Consider calling $action() before unmounting.'
      '\n'
      'The following fields entries were not $acted: \n'
      '${_fields.unmounted.entries.where((e) => test(e.value)).join('\n')}'
      '\n'
      'You must either: \n'
      '1. Do $action the field before disposing (recommended). \n'
      '2. Keep the field alive with AutomaticKeepAliveClientMixin. \n'
      '3. Move or remove the field entirely. \n'
      '\n'
      'This can happen when you are using a PageView, TabBarView or others. '
      'Flutter automatically unmounts views in these widgets, this is '
      'intended and Formx gracefully handles this by reattaching the state '
      'automatically. Keeping widgets alive is advanced and error prone, and '
      'thus not recommended.\n',
    );
  }
}

extension<K, V extends State> on Map<K, V> {
  /// Returns a new [Map] where all states are [State.mounted].
  Map<K, V> get mounted {
    return Map.fromEntries(entries.where((entry) => entry.value.mounted));
  }

  /// Returns a new [Map] where all states are not [State.mounted].
  Map<K, V> get unmounted {
    return Map.fromEntries(entries.where((entry) => !entry.value.mounted));
  }
}
