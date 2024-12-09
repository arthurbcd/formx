import 'package:flutter/material.dart';

import 'widgets/formx_field.dart';

/// A [FormField] that contains a single [CheckboxListTile].
class CheckboxFormField extends FormxField<bool> {
  /// Creates a [FormField] that contains a single [CheckboxListTile].
  const CheckboxFormField({
    this.title,
    this.subtitle,
    this.controlAffinity = ListTileControlAffinity.leading,
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.initialValue = false,
    super.onSaved,
    super.validator,
    super.restorationId,
    super.onChanged,
  }) : super(decoration: null);

  /// The title of the [CheckboxListTile].
  final Widget? title;

  /// The subtitle of the [CheckboxListTile].
  final Widget? subtitle;

  /// The alignment of the checkbox.
  final ListTileControlAffinity controlAffinity;

  @override
  Widget build(FormFieldState<bool> state) {
    final theme = Theme.of(state.context);

    return CheckboxListTile(
      value: state.value,
      onChanged: state.didChange,
      title: title,
      subtitle: switch (state.errorText) {
        null => subtitle,
        _ => Text(
            state.errorText!,
            style: TextStyle(color: theme.colorScheme.error),
          ),
      },
      isError: state.hasError,
      controlAffinity: controlAffinity,
    );
  }
}
