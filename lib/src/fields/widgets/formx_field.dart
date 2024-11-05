import 'package:flutter/material.dart';

/// An extended [FormField] with:
///
/// - overridable [build] method.
/// - [decoration] property.
/// - [onChanged] callback.
class FormxField<T> extends FormField<T> {
  /// Creates a [FormxField].
  const FormxField({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.restorationId,
    this.autofocus = false,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.decorator,
    this.onChanged,
    FormFieldBuilder<T>? builder,
  })  : _builder = builder,
        super(builder: _Builder.new);

  final FormFieldBuilder<T>? _builder;

  /// Called on [FormFieldState.didChange].
  final ValueChanged<T?>? onChanged;

  /// The internal [Focus.autofocus].
  final bool autofocus;

  /// The internal [Focus.focusNode].
  final FocusNode? focusNode;

  /// The decoration to show around this [FormField].
  final InputDecoration? decoration;

  /// The [decoration] modifier.
  final InputDecoration? Function(FormFieldState<T> state)? decorator;

  /// Whether the field is raw and should not integrate focus and decoration.
  bool get isRaw => false;

  /// The [FormxField.decoration] modifier.
  InputDecoration? decorate(FormFieldState<T> state) {
    return decorator?.call(state) ?? decoration;
  }

  /// The [FormField.builder].
  Widget build(FormFieldState<T> state) {
    if (_builder != null) return _builder(state);

    throw UnimplementedError(
      'You must either set [builder] or implement this [build] method.',
    );
  }

  @override
  FormFieldState<T> createState() => _FormxFieldState();
}

class _Builder extends StatefulWidget {
  const _Builder(this.state);
  final FormFieldState state;

  @override
  State<_Builder> createState() => _BuilderState();
}

class _BuilderState extends State<_Builder> {
  var _hasFocus = false;
  var _hovering = false;

  @override
  Widget build(BuildContext context) {
    final state = this.widget.state as FormxFieldState;
    final widget = state.widget;

    // raw
    if (widget.isRaw) return widget.build(state);

    // field
    var child = widget.build(state);
    final decoration = widget.decorate(state);

    // add interactions
    child = Focus(
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onFocusChange: (hasFocus) => setState(() => _hasFocus = hasFocus),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: child,
      ),
    );

    if (decoration == null) return child;

    // add decorator
    return InputDecorator(
      isFocused: _hasFocus,
      isHovering: _hovering,
      decoration: decoration.copyWith(
        errorText: decoration.errorText ?? state.errorText,
      ),
      child: child,
    );
  }
}

class _FormxFieldState<T> extends FormxFieldState<T> {}

/// The state of a [FormxField].
abstract class FormxFieldState<T> extends FormFieldState<T> {
  @override
  FormxField<T> get widget => super.widget as FormxField<T>;

  @override
  void didChange(T? value) {
    super.didChange(value);
    widget.onChanged?.call(value);
  }

  @override
  void reset() {
    super.reset();
    widget.onChanged?.call(value);
  }
}

///
extension InputDecorationExtension on InputDecoration {
  /// Applies the default widgets to this [InputDecoration].
  InputDecoration applyDefaultWidgets({
    Widget? counter,
    Widget? error,
    Widget? helper,
    Widget? icon,
    Widget? label,
    Widget? prefix,
    Widget? prefixIcon,
    Widget? suffix,
    Widget? suffixIcon,
  }) {
    return copyWith(
      counter: this.counter ?? counter,
      error: this.error ?? error,
      helper: this.helper ?? helper,
      icon: this.icon ?? icon,
      label: this.label ?? label,
      prefix: this.prefix ?? prefix,
      prefixIcon: this.prefixIcon ?? prefixIcon,
      suffix: this.suffix ?? suffix,
      suffixIcon: this.suffixIcon ?? suffixIcon,
    );
  }
}
