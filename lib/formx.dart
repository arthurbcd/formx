/// Build, validate and fill forms easily with extended Form and TextFormField.

// ignore_for_file: invalid_use_of_protected_member

library formx;

import 'dart:collection';
import 'dart:convert';

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
    this.autovalidateMode,
  }) : assert(
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

  /// Same as [Form.onChanged], but callbacks the [FormxState].
  ///
  /// If it is a nested [Formx], it will trigger the parent [onChanged] as well.
  final FormxCallback? onChanged;

  /// Called when [FormxState.save] is called.
  final FormxCallback? onSaved;

  /// The [Form.autovalidateMode] that fields will inherit.
  ///
  /// If null:
  /// - [Formx] - starts with [AutovalidateMode.disabled] and then changes to
  /// [AutovalidateMode.always] after the first validation.
  ///
  /// - [Form] - starts and stays with [AutovalidateMode.disabled].
  final AutovalidateMode? autovalidateMode;

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
          'Only use a valid key if you are using a nested [Formx].');
      state?._nested[key] = this;
      return state;
    }
    return null;
  }();

  final _fields = <String, FormFieldState>{};
  final _nested = <String, FormxState>{};
  bool? _hasInteractedByUser;
  bool _hasValidated = false;

  /// Wheter this [Formx] has a valid [Key].
  bool get hasValidKey => widget.key?.value != null;

  /// The [AutovalidateMode] for this [Formx].
  AutovalidateMode? get autovalidateMode {
    if (_hasInteractedByUser == null) return null;
    final mode = widget.autovalidateMode ?? parent?.autovalidateMode;

    return _hasValidated && mode == null ? AutovalidateMode.always : mode;
  }

  /// The initial value for each nested [FormField] or [Formx].
  Map<String, dynamic>? get initialValues =>
      widget.initialValues ??
      parent?.initialValues?[widget.key?.value] as Map<String, dynamic>?;

  /// All attached [FormFieldState].
  Map<String, FormFieldState> get fields => UnmodifiableMapView(_fields);

  /// All attached [FormxState] and nested [FormFieldState].
  Map<String, FormxState> get nested => UnmodifiableMapView(_nested);

  /// A [Map] containaing all attached field values.
  Map<String, dynamic> get form {
    var form = <String, dynamic>{};
    _fields.forEach((key, field) => form[key] = field.value);
    _nested.forEach((key, formx) => form[key] = formx.form);
    return form;
  }

  /// Returns true if [fields] or [nested] have errors. Doesn't set ui state.
  bool get hasError =>
      _fields.values.any((field) => field.hasError) ||
      _nested.values.any((formx) => formx.hasError);

  /// Returns true if [fields] and [nested] are valid. Doesn't set ui state.
  bool get isValid =>
      _fields.values.every((field) => field.isValid) &&
      _nested.values.every((formx) => formx.isValid);

  /// Returns a flat [Map] of all [_fields] and [_nested] errorTexts.
  ///
  /// Note, if they were not validated, they will not be present.
  Map<String, String> get errorTexts {
    final errorTexts = <String, String>{};
    _fields.forEach((tag, field) => errorTexts[tag] = field.errorText ?? '');
    _nested.forEach((tag, formx) => errorTexts.addAll(formx.errorTexts));
    return errorTexts..removeWhere((key, value) => value.isEmpty);
  }

  /// Gets either a [FormFieldState.value] or [FormxState.form] by [key].
  Object? operator [](String key) {
    final state = stateWhere((e) => e.key == key);

    if (state is FormFieldState) return state.value;
    if (state is FormxState) return state.form;
    return null;
  }

  /// Sets either a [FormFieldState.value] or [FormxState.form] value by [key].
  void operator []=(String key, Object? value) {
    final state = stateWhere((e) => e.key == key);

    if (state is FormFieldState) state.didChange(value);
    if (state is FormxState && value is Map) state.fill(value.cast());
  }

  void _visitFields() {
    _fields.clear();
    void visit(Element el) {
      if ((el, el.widget.key) case (StatefulElement el, Key key)) {
        // stop recursion, the nested form will handle it.
        if (el.state is FormxState) return;

        if (el.state case FormFieldState state) {
          if (key.value case String value) {
            _fields[value] = state;
            return;
          }
          assert(
            true,
            'FormField.key.value is not a String: $key.\n'
            'You must set a valid key for this FormField:\n\n'
            'Ex: `TextFormField(key: const Key("name"))`',
          );
        }
      }
      el.visitChildren(visit); // continue recursion
    }

    if (mounted) context.visitChildElements(visit);
  }

  void _onChanged() {
    // still waiting for the first build.
    if (_hasInteractedByUser == null) return;

    // ready to go.
    if (_hasInteractedByUser == false) {
      setState(() => _hasInteractedByUser = true);
    }
    _visitFields();

    // We callback the change.
    widget.onChanged?.call(this);

    if (parent case FormxState parent when hasValidKey) {
      // If this is a nested form, we callback the parent as well.
      parent._onChanged();
    }

    if (hasError && !_hasValidated) {
      setState(() => _hasValidated = true);
    }
  }

  /// Fills this [FormxState.form] with new [values].
  void fill(Map<String, dynamic> values) {
    values.forEach((key, value) {
      if (value case Map<String, dynamic> form) return _nested[key]?.fill(form);

      _fields[key]?.didChange(value);
    });
  }

  /// Resets all fields.
  ///
  /// Optionally, you can set [keys] to reset only specific fields.
  void reset([List<String> keys = const []]) {
    _hasInteractedByUser = null;

    for (final e in _fields.entries) {
      if (keys.isEmpty || keys.contains(e.key)) {
        e.value.reset();
        if (initialValues?[e.key] case Object value) e.value.didChange(value);
      }
    }
    _nested.forEach((key, formx) => formx.reset(keys));
    setState(() => _hasInteractedByUser = false);
  }

  /// Saves all fields.
  ///
  /// Optionally, you can set [keys] to save only specific fields.
  void save([List<String> keys = const []]) {
    for (final e in _fields.entries) {
      if (keys.isEmpty || keys.contains(e.key)) e.value.save();
    }
    _nested.forEach((key, formx) => formx.save(keys));
    widget.onSaved?.call(this);
  }

  /// Validates this and nested fields.
  ///
  /// Optionally, you can set [keys] to validate only specific fields.
  bool validate([List<String> keys = const []]) {
    final isValid = _fields.entries
        .where((e) => keys.isEmpty || keys.contains(e.key))
        .fold(true, (p, e) => e.value.validate() && p);

    final areValid = _nested.values.fold(true, (p, e) => e.validate(keys) && p);
    return isValid && areValid;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _visitFields();
      if (initialValues case Map<String, dynamic> map) fill(map);

      // unlock autovalidateMode after the first build.
      setState(() => _hasInteractedByUser = false);
    });
  }

  @override
  void reassemble() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _visitFields());
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return _Form2Scope(
      state: this,
      child: Form(
        autovalidateMode: autovalidateMode,
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

class _Form2Scope extends InheritedWidget {
  const _Form2Scope({required this.state, required super.child});
  final FormxState state;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

extension on Key {
  String? get value {
    try {
      return (this as dynamic).value as String;
    } catch (_) {}
    return null;
  }
}

extension on FormxState {
  State? stateWhere(bool Function(MapEntry<String, State> e) visitor) {
    for (final e in _fields.entries) {
      if (visitor(e)) return e.value;
    }
    for (final e in _nested.entries) {
      if (visitor(e)) return e.value.stateWhere(visitor);
    }
    return null;
  }
}

/// Extension for [Map] to convert it to an indented [String].
extension FormxIndentedExtension on Map<dynamic, dynamic> {
  /// Converts this [Map] to a indented [String].
  String get indented {
    return JsonEncoder.withIndent('  ', (e) => e.toString()).convert(this);
  }
}

/// Extension to enable Object inference casting by type.
extension FormxObjectExtension on Object {
  /// Returns this as [T].
  T cast<T>() => this as T;

  /// Returns this as [T] if it is [T], otherwise null.
  T? tryCast<T>() => this is T ? this as T : null;
}
