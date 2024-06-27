import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

/// A [FormField] that contains a single [CheckboxListTile].
class CheckboxFormField extends FormField<bool> {
  /// Creates a [FormField] that contains a single [CheckboxListTile].
  const CheckboxFormField({
    this.title,
    this.subtitle,
    this.onChanged,
    this.controlAffinity = ListTileControlAffinity.leading,
    super.autovalidateMode,
    super.enabled,
    super.initialValue = false,
    super.key,
    super.onSaved,
    super.validator,
    super.restorationId,
  }) : super(builder: _builder);

  static Widget _builder(FormFieldState<bool> state) {
    return _CheckboxFormField(CheckboxFormFieldState(state));
  }

  /// The callback that is called when the value changes.
  final ValueChanged<bool?>? onChanged;

  /// The title of the [CheckboxListTile].
  final Widget? title;

  /// The subtitle of the [CheckboxListTile].
  final Widget? subtitle;

  /// The alignment of the checkbox.
  final ListTileControlAffinity controlAffinity;
}

class _CheckboxFormField extends StatelessWidget {
  const _CheckboxFormField(this.state);
  final CheckboxFormFieldState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final widget = state.widget;

    return CheckboxListTile(
      value: state.value,
      title: widget.title,
      subtitle: widget.subtitle ??
          (state.errorText != null
              ? Text(
                  state.errorText!,
                  style: TextStyle(color: theme.colorScheme.error),
                )
              : null),
      isError: state.hasError,
      controlAffinity: widget.controlAffinity,
      onChanged: (value) {
        state.didChange(value);
        widget.onChanged?.call(value);
      },
    );
  }
}

/// The state of a [CheckboxFormField].
extension type CheckboxFormFieldState(FormFieldState<bool> state)
    implements FormFieldState<bool> {
  @redeclare
  CheckboxFormField get widget => state.widget as CheckboxFormField;
}
