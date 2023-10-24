// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import 'text_formx_field.dart';

/// A [Exception] thrown by this library.
class FormxException implements Exception {
  /// Default constructor.
  FormxException(this.message) : errorTexts = const {};

  /// Thrown when [FormxState.submit] is called and there are invalid fields.
  FormxException.withErrorTexts(this.errorTexts) {
    final buffer = StringBuffer();
    errorTexts.forEach((tag, msg) => buffer.write('Invalid tag $tag: $msg\n'));
    message = buffer.toString();
  }

  /// The exception message.
  late final String message;

  /// A map of [String] tag and [String] errorText.
  final Map<String, String> errorTexts;

  @override
  String toString() => 'FormxException: $message';
}

/// A widget that builds a form with [TextFormxField] widgets.
class Formx extends StatefulWidget {
  /// A widget that builds a form with [TextFormxField] widgets.
  ///
  /// A form can also be nested in another [Formx] for more complex forms.
  ///
  /// Use `Formx.of(context)` or `GlobalKey` to access the formx state.
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
    required this.child,
    this.tag,
    this.enabled,
    this.initialValues,
    this.onChanged,
    this.onSubmitted,
    this.onField,
    this.onWidget,
    this.onErrorText,
    this.onDecoration,
    this.autovalidateMode,
  });

  /// When present, links this form to a parent [FormxState.form]. This also enables parent/child callbacks.
  /// The tagged form map will be nested in the parent form map.
  ///
  /// Ex: {'my_tag': {'my_field': 'value'}}
  final String? tag;

  /// The widget tree with [TextFormxField] widgets (or [Formx] with [tag]).
  final Widget child;

  /// When false, disables all descendants.
  final bool? enabled;

  /// The initial value for each [TextFormxField.tag] or nested [Formx.tag].
  final FormMap? initialValues;

  ///Listens to all changes of this [FormxState.form].
  final FormCallback? onChanged;

  ///Called when `onFieldSubmitted` or state `submit()` are triggered and valid.
  final FormCallback? onSubmitted;

  ///Wrapper for each [TextFormxField].
  final TagFieldSetter? onField;

  ///Wrapper for each resolved [Widget].
  final TagWidgetSetter? onWidget;

  ///Handler for each `TextFormxField.validator` errorText.
  final TagErrorTextSetter? onErrorText;

  ///Handler for each `TextFormxField.decoration`.
  final TagDecorationSetter? onDecoration;

  /// When null, starts disabled and changes to always on [onSubmitted].
  final AutovalidateMode? autovalidateMode;

  /// Accesses the nearest [FormxState] above [BuildContext].
  static FormxState of(BuildContext context) {
    final maybe = maybeOf(context);
    assert(maybe != null, 'No [Formx] was found above this context.');
    return maybe!;
  }

  /// Accesses the nearest [FormxState] above [BuildContext] or null.
  static FormxState? maybeOf(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<_InheritedFormx>()
        ?.widget as _InheritedFormx?;

    return widget?.state;
  }

  /// Accesses the nearest [FormxState] below [BuildContext] or null.
  static FormxState at(BuildContext context) {
    final maybe = maybeAt(context);
    assert(maybe != null, 'No [Formx] was found below this context.');
    return maybe!;
  }

  /// Accesses the nearest [FormxState] below [BuildContext] or null.
  static FormxState? maybeAt(BuildContext context) {
    _InheritedFormx? widget;
    void visitor(Element el) {
      if (el.widget is _InheritedFormx) {
        widget = el.widget as _InheritedFormx;
      } else {
        el.visitChildElements(visitor);
      }
    }

    context.visitChildElements(visitor);
    return widget?.state;
  }

  @override
  State<Formx> createState() => FormxState();
}

/// A map of [String] tag and [String] or [FormMap] value. Represents a form.
typedef FormMap = Map<String, dynamic>;

/// A [FormMap] callback. Used by [Formx.onChanged] and [Formx.onSubmitted]
typedef FormCallback = void Function(FormMap form);

/// A [TextFormxField] callback. Used by [Formx.onField].
typedef TagFieldSetter = TextFormxField Function(
  String tag,
  TextFormxField field,
);

/// A [Widget] callback. Used by [Formx.onWidget].
typedef TagWidgetSetter = Widget Function(String tag, Widget widget);

/// A [String] setter. Used by [Formx.onErrorText].
typedef TagErrorTextSetter = String Function(String tag, String error);

/// A [InputDecoration] setter. Used by [Formx.onDecoration].
typedef TagDecorationSetter = InputDecoration? Function(
  String tag,
  InputDecoration? decoration,
);

/// The state of a [Formx] widget.
class FormxState extends State<Formx> {
  /// The parent [FormxState] when [Formx.tag] is present.
  late final FormxState? parent = () {
    final scope = Formx.maybeOf(context);
    assert(
      hasTag && scope != null,
      'This [Formx] has a tag but no parent was found. '
      'When [tag] is present, you must wrap this form '
      'in a parent [Formx] widget',
    );
    return scope;
  }();

  bool get hasTag => widget.tag != null;

  // * Formx inheritance
  bool? get enabled => widget.enabled ?? (hasTag ? parent?.enabled : null);
  TagFieldSetter? get onField => widget.onField ?? parent?.onField;
  TagWidgetSetter? get onWidget => widget.onWidget ?? parent?.onWidget;
  TagErrorTextSetter? get onErrorText =>
      widget.onErrorText ?? parent?.onErrorText;
  TagDecorationSetter? get onDecoration =>
      widget.onDecoration ?? parent?.onDecoration;
  AutovalidateMode? get autovalidateMode =>
      widget.autovalidateMode ?? (hasTag ? parent?.autovalidateMode : null);

  /// * Inherited form.
  late final FormMap form = widget.initialValues != null
      ? Map.of(widget.initialValues!)
      : Map.of(parent?.form[widget.tag] as FormMap? ?? {});

  /// All direct descendants [Formx] with non-nullable [Formx.tag].
  final nested = <String, FormxState>{};

  /// All direct descendants [FormFieldState] by [TextFormxField.tag].
  final fields = <String, FormFieldState<String>>{};

  /// All direct and nested invalid `tag`s with their `errorText`.
  final errorTexts = <String, String>{};

  /// Submits if all descendants are valid or throws [FormxException].
  Map<String, dynamic> submit() {
    return trySubmit() ?? (throw FormxException.withErrorTexts(errorTexts));
  }

  /// Submits if all descendants are valid or null.
  Map<String, dynamic>? trySubmit() {
    if (!validate()) return null;
    widget.onSubmitted?.call(form);
    return form;
  }

  /// Validates all fields and nested [Formx], if any.
  bool validate() {
    errorTexts.clear();

    fields.forEach((tag, field) {
      if (!field.validate()) errorTexts[tag] = field.errorText!;
    });

    nested.forEach((tag, formx) {
      if (!formx.validate()) errorTexts.addAll(formx.errorTexts);
    });

    return errorTexts.isEmpty;
  }

  /// Fills this [FormxState.form] with [values] or nested forms.
  ///
  /// Values that are not [String] or [FormMap] will be ignored.
  void fill(FormMap values) {
    values.forEach((tag, value) {
      if (value is FormMap) nested[tag]?.fill(value);
      if (value is String) setValue(tag, value);
    });
  }

  /// Sets the value of the field with the enclosing [tag].
  void setValue(String tag, String value) {
    fields[tag]?.didChange(value);
    didChange(tag, value);
  }

  /// Attaches a [FormFieldState] to this [FormxState].
  @protected
  void attachField(String tag, FormFieldState<String> field) {
    fields[tag] = field;

    //If tag is present, looks for parent.
    if (hasTag) parent?.nested[tag] = this;
  }

  /// Reports a change to this [FormxState.form].
  @protected
  void didChange(String tag, String value) {
    form[tag] = value;
    widget.onChanged?.call(form);

    //If tag is present, looks for parent.
    if (hasTag) {
      parent?.form[widget.tag!] = form;
      parent?.widget.onChanged?.call(parent!.form);
    }
  }

  /// Reports a submit to this [FormxState.form].
  @protected
  void didSubmit() {
    if (!validate()) return;
    widget.onSubmitted?.call(form);

    //If tag is present, looks for parent.
    if (hasTag) parent?.widget.onSubmitted?.call(parent!.form);
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedFormx(
      state: this,
      child: widget.child,
    );
  }
}

class _InheritedFormx extends InheritedWidget {
  const _InheritedFormx({required super.child, required this.state});
  final FormxState state;

  @override
  bool updateShouldNotify(_InheritedFormx oldWidget) => false;
}
