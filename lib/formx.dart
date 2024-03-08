/// Build, validate and fill forms easily with extended Form and TextFormField.

library formx;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

export 'package:formx/src/extensions/keep_alive_extension.dart';

/// Signature for [Formx.builder].
typedef FormxBuilder = Widget Function(
  BuildContext context,
  FormxState state,
  Widget? child,
);

/// Signature for [Formx.onChanged].
typedef FormxCallback = void Function(FormxState state);

/// A [Form] that handles any [FormField] and nested [Formx] below it.
class Formx extends StatefulWidget {
  /// A form can also be nested in another [Formx] for more complex forms.
  ///
  /// Use `Formx.of(context)`, `GlobalKey` or [builder] to access [FormxState].
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
    this.initialValues,
    this.onChanged,
    this.onSaved,
    this.builder,
    this.child,
    AutovalidateMode? autovalidateMode,
  })  : autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        assert(
          child != null || builder != null,
          'You must set child and/or builder',
        );

  /// The initial value for each nested [FormField] or [Formx], that has a
  /// valid [Key].
  ///
  /// Example:
  ///
  /// 1. Set a key.
  /// ```dart
  ///  TextFormField(key: 'name'.key),
  /// ```
  ///
  /// 2. Set the initial value.
  /// ```dart
  /// Formx(
  ///  initialValues: {
  ///   'name': 'John',
  ///  },
  /// ```
  final Map<String, dynamic>? initialValues;

  /// Sintax-sugar for accessing the [FormState].
  final FormxBuilder? builder;

  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// Callbacks `form` when one of the form fields changes.
  final FormxCallback? onChanged;

  /// Called when [FormxState.save] is called.
  final FormxCallback? onSaved;

  /// {@macro flutter.widgets.FormField.autovalidateMode}
  final AutovalidateMode autovalidateMode;

  /// Returns the first [FormxState] above [BuildContext].
  static FormxState of(BuildContext context) {
    final maybe = maybeOf(context);
    assert(maybe != null, 'No [Formx] of this context.');

    return maybe!;
  }

  /// Returns the first [FormxState] above [BuildContext] or null.
  static FormxState? maybeOf(BuildContext context) {
    final widget = context.getInheritedWidgetOfExactType<_Form2Scope>();

    return widget?.state;
  }

  @override
  State<Formx> createState() => FormxState();
}

/// The state of a [Formx].
class FormxState extends State<Formx> {
  /// The parent [FormxState] descendant of this [context].
  late final FormxState? parent = () {
    final state = Formx.maybeOf(context);
    if (widget.key?.value case String key) {
      assert(
        state != null,
        'This [Formx] has a valid key but no parent was found. '
        'When [key] is valid, you must wrap this form '
        'in a parent [Formx] widget',
      );
      state?._nested[key] = this;
    }
    return state;
  }();

  /// Wheter this [Formx] has a valid [Key].
  bool get hasValidKey => widget.key?.value != null;

  // /// The initial values for this [form]. Applied to [_fields] and [_nested].
  // Map<String, dynamic> get initialValues => widget.initialValues != null
  //     ? Map.of(widget.initialValues!)
  //     : Map.from(parent?.initialValues[widget.key?.value] as Map? ?? {});

  // ignore: strict_raw_type
  final _fields = <String, FormFieldState>{};
  final _nested = <String, FormxState>{};
  var _oldForm = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visitFields();
      if (widget.initialValues != null) {
        fill(widget.initialValues!);
      }
    });
  }

  @override
  void reassemble() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _visitFields());
    super.reassemble();
  }

  void _visitFields() {
    _fields.clear();
    void visit(Element el) {
      if ((el, el.widget.key?.value) case (StatefulElement el, String key)) {
        // stop recursion if it's a nested form.
        if (el.state is FormxState) return;

        if (el.state case FormFieldState<dynamic> state) {
          _fields[key] = state;
        }
      }
      el.visitChildren(visit);
    }

    if (mounted) context.visitChildElements(visit);
  }

  /// A [Map] containaing all attached field values.
  Map<String, dynamic> get form {
    var form = <String, dynamic>{};
    _nested.removeWhere((key, state) => !state.mounted);
    _fields.removeWhere((key, state) => !state.mounted);
    _nested.forEach((key, formx) => form[key] = formx.form);
    _fields.forEach((key, field) => form[key] = field.value);
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

  /// Returns a flat [Map] of all [_fields] and [_nested] errorTexts.
  ///
  /// Note, if they were not validated, they will not be present.
  Map<String, String> get errorTexts {
    final errorTexts = <String, String>{};
    _fields.forEach((tag, field) => errorTexts[tag] = field.errorText ?? '');
    _nested.forEach((tag, formx) => errorTexts.addAll(formx.errorTexts));
    return errorTexts..removeWhere((key, value) => value.isEmpty);
  }

  /// Validates all fields.
  ///
  /// Optionally, you can set [keys] to validate only specific fields.
  bool validate([List<String> keys = const []]) {
    final validations = <String, bool>{};

    for (final key in keys) {
      final state = stateWhere((k, v) => k == key);
      if (state is FormFieldState) validations[key] = state.validate();
      if (state is FormxState) validations[key] = state.validate();
      assert(validations.containsKey(key), 'Formx.validate key $key not found');
    }

    // if any tag/key validations were called, returns if all are valid.
    if (validations.isNotEmpty) {
      return validations.values.every((isValid) => isValid);
    }

    // otherwise, validates all fields and nested.
    _fields.forEach((tag, field) => field.validate());
    _nested.forEach((tag, formx) => formx.validate());
    return !hasError;
  }

  /// Fills this [FormxState.form] with new [values].
  void fill(Map<String, dynamic> values) {
    values.forEach((key, value) {
      if (value is Map<String, dynamic>) _nested[key]?.fill(value);
      if (value != null) _fields[key]?.didChange(value);
    });
  }

  /// Gets the value of any field by [key].
  T? get<T>(String key) => fieldOrNull<T>(key)?.value;

  /// Sets the value of any field by [key].
  void set<T>(String key, T value) => fieldOrNull<T>(key)?.didChange(value);

  /// Updates the value of any field by [key].
  void update<T>(String key, T? Function(T? value) updater) {
    set(key, updater(get<T>(key)));
  }

  /// Attempts to find the [FormFieldState] by [key], or returns null.
  FormFieldState<T>? fieldOrNull<T>(String key) {
    final state = stateWhere(
      (t, state) => t == key && state is FormFieldState<T>,
    );
    return state as FormFieldState<T>?;
  }

  /// Attempts to find the [FormFieldState] by [key], or throws.
  FormFieldState<T> field<T>(String key) {
    final state = fieldOrNull<T>(key);
    assert(state != null, 'Formx.field $key not found for type $T');
    return state!;
  }

  /// Resets all fields.
  ///
  /// Optionally, you can set [keys] to reset only specific fields.
  void reset([List<String> keys = const []]) {
    _nested.forEach((key, formx) => formx.reset(keys));
    _fields.forEach((key, field) => keys.contains(key) ? field.reset() : null);
    if (widget.initialValues != null) {
      fill(widget.initialValues!);
    }
  }

  /// Saves all fields.
  ///
  /// Optionally, you can set [keys] to save only specific fields.
  void save([List<String> keys = const []]) {
    _nested.forEach((key, formx) => formx.save(keys));
    _fields.forEach((key, field) => keys.contains(key) ? field.save() : null);
    widget.onSaved?.call(this);
  }

  /// Reports a change to this [FormxState.form].
  void _onChanged() {
    // we expect a change, so in no changes, we revisit fields.
    mapEquals(_oldForm, form) ? _visitFields() : _oldForm = Map.of(form);

    widget.onChanged?.call(this);

    //If tag is present, callbacks to parent.
    if (parent case FormxState parent when hasValidKey) {
      parent.widget.onChanged?.call(parent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Form2Scope(
      state: this,
      child: Form(
        autovalidateMode: widget.autovalidateMode,
        onChanged: _onChanged,
        child: Builder(
          builder: (context) {
            if (widget.builder case FormxBuilder builder) {
              return builder(context, this, widget.child);
            }
            return widget.child ?? (throw StateError('No child or builder'));
          },
        ),
      ),
    );
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    final debugMessage = super.toString(minLevel: minLevel);
    return '''
$debugMessage
key: ${widget.key}
form: ${form.indented},
''';
  }
}

extension on Key {
  String? get value {
    try {
      return (this as dynamic).value as String;
    } catch (_) {}
    return null;
  }
}

/// Extension for [Map] to convert it to a indented [String].
extension IndentedFormExtension on Map<dynamic, dynamic> {
  /// Converts this [Map] to a indented [String].
  String get indented => const JsonEncoder.withIndent('  ').convert(this);
}

extension on FormxState {
  State? stateWhere(bool Function(String key, State state) visitor) {
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
}

class _Form2Scope extends InheritedWidget {
  const _Form2Scope({required this.state, required super.child});
  final FormxState state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
