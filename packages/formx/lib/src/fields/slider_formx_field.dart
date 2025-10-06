import 'package:flutter/material.dart';

import '../../formx.dart';

class SliderFormxField extends FormxField<double> {
  const SliderFormxField({
    super.key,
    super.autofocus,
    super.focusNode,
    super.initialValue = 0.0,
    super.onChanged,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.restorationId,
    super.decoration = const InputDecoration(),
    super.decorator,
    super.readOnly,
    this.secondaryTrackValue,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.secondaryActiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.allowedInteraction,
    this.padding,
  });

  final double? secondaryTrackValue;
  final void Function(double)? onChangeStart;
  final void Function(double)? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? secondaryActiveColor;
  final Color? thumbColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final MouseCursor? mouseCursor;
  final String Function(double)? semanticFormatterCallback;
  final SliderInteraction? allowedInteraction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(FormxFieldState<double> state) {
    return Slider(
      value: state.value ?? 0.0,
      secondaryTrackValue: secondaryTrackValue,
      autofocus: autofocus,
      focusNode: focusNode,
      onChanged: enabled ? state.didChange : null,
      onChangeStart: enabled ? onChangeStart : null,
      onChangeEnd: enabled ? onChangeEnd : null,
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      secondaryActiveColor: secondaryActiveColor,
      thumbColor: thumbColor,
      overlayColor: overlayColor,
      mouseCursor: readOnly ? SystemMouseCursors.basic : mouseCursor,
      semanticFormatterCallback: semanticFormatterCallback,
      allowedInteraction: allowedInteraction,
      padding: padding,
    );
  }
}
