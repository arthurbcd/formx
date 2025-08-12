import 'package:flutter/material.dart';

import '../../extensions/sanitizers.dart';

/// Signature for decorating a [FormxField].
typedef FormxFieldDecorator<T> = Widget Function(
  FormFieldState<T> state,
  Widget child,
);

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
    super.builder = _build,
  });

  /// Called on [FormFieldState.didChange].
  final ValueChanged<T?>? onChanged;

  /// The internal [Focus.autofocus].
  final bool autofocus;

  /// The internal [Focus.focusNode].
  final FocusNode? focusNode;

  /// The decoration to show around this [FormField].
  final InputDecoration? decoration;

  /// The decoration builder to show around this [FormField].
  final FormxFieldDecorator<T>? decorator;

  @override
  FormFieldState<T> createState() => _FormxFieldState();

  @override
  FormFieldBuilder<T> get builder {
    return (state) {
      return (decorator ?? buildDecorator)(state.cast(), super.builder(state));
    };
  }

  static Widget _build(FormFieldState state) {
    return (state.widget as FormxField).build(state.cast());
  }

  /// The [FormField.builder].
  Widget build(FormxFieldState<T> state) {
    throw UnimplementedError(
      'You must either set [builder] or implement this [build] method.',
    );
  }

  /// Builds the decorator around the [child] built by [build].
  Widget buildDecorator(FormxFieldState<T> state, Widget child) {
    return InputDecoratorx(
      decoration: decoration,
      child: child,
    );
  }
}

/// An extended [InputDecorator].
///
/// - Handles the focus and hover states.
/// - Handles the error text.
class InputDecoratorx extends StatefulWidget {
  /// Creates an [InputDecoratorx].
  const InputDecoratorx({
    super.key,
    this.autofocus,
    this.focusNode,
    required this.decoration,
    required this.child,
  });

  /// The [Focus.autofocus]. If null, inherits from parent [FormxField].
  final bool? autofocus;

  /// The [Focus.focusNode]. If null, inherits from parent [FormxField].
  final FocusNode? focusNode;

  /// The decoration to show around this [FormField].
  final InputDecoration? decoration;

  /// The child widget to decorate.
  final Widget? child;

  @override
  State<InputDecoratorx> createState() => _InputDecoratorxState();
}

class _InputDecoratorxState extends State<InputDecoratorx> {
  var _hasFocus = false;
  var _hovering = false;

  void setHovering(bool hovering) {
    setState(() => _hovering = hovering);
  }

  @override
  Widget build(BuildContext context) {
    final field = context.findAncestorStateOfType<FormxFieldState>();
    final decoration = widget.decoration;
    final enabled = field?.widget.enabled ?? true;

    Widget child = Focus(
      autofocus: widget.autofocus ?? field?.widget.autofocus ?? false,
      focusNode: widget.focusNode ?? field?.widget.focusNode,
      onFocusChange:
          enabled ? (hasFocus) => setState(() => _hasFocus = hasFocus) : null,
      child: MouseRegion(
        onEnter: enabled ? (_) => setHovering(true) : null,
        onExit: enabled ? (_) => setHovering(false) : null,
        child: widget.child,
      ),
    );

    if (decoration == null) return child;

    // add decorator
    return InputDecorator(
      isFocused: _hasFocus && enabled,
      isHovering: _hovering && enabled,
      decoration: decoration.copyWith(
        errorText: decoration.errorText ?? field?.errorText,
      ),
      child: child,
    );
  }
}

class _FormxFieldState<T> extends FormxFieldState<T> {}

/// The state of a [FormxField].
class FormxFieldState<T> extends FormFieldState<T> {
  GlobalKey<FormFieldState>? extraKey;
  void Function(T? value)? onChanged;
  void Function()? onReset;

  @override
  FormxField<T> get widget => super.widget as FormxField<T>;

  @override
  void didChange(T? value) {
    super.didChange(value);
    onChanged?.call(value);
    widget.onChanged?.call(value);
  }

  @override
  void reset() {
    super.reset();
    onReset?.call();
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
