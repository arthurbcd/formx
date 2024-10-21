import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../extensions/formx_extension.dart';
import '../models/formx_options.dart';

/// A [FormField] of type [DateTime].
class DateFormField extends FormField<DateTime> {
  /// Creates a [FormField] of type [DateTime].
  ///
  /// Use [FormxOptions.dateAdapter] to define the format in [FormState] values.
  ///
  /// You can override the default [picker] to show a custom date picker or to
  /// apply customized parameters.
  ///
  const DateFormField({
    super.key,
    this.onChanged,
    this.decoration = const InputDecoration(),
    this.picker = _defaultPicker,
    super.enabled,
    super.initialValue,
    super.autovalidateMode,
    super.onSaved,
    super.validator,
    super.restorationId,
  }) : super(builder: _builder);

  static Widget _builder(FormFieldState<DateTime> state) {
    return _DateFormField(DateFormFieldState(state));
  }

  static Future<DateTime?> _defaultPicker(DateFormFieldState state) async {
    return Formx.setup.datePicker(state);
  }

  /// The decoration to show around the field.
  final InputDecoration? decoration;

  /// The callback that is called when the value changes.
  final ValueChanged<DateTime?>? onChanged;

  /// The function that creates the [DateTime] picker.
  final FutureOr<DateTime?> Function(DateFormFieldState state) picker;
}

class _DateFormField extends StatelessWidget {
  const _DateFormField(this.state);
  final DateFormFieldState state;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final widget = state.widget;
    final date = state.value;

    return TextField(
      readOnly: true,
      onTapAlwaysCalled: true,
      decoration: widget.decoration?.copyWith(
        hintText: widget.decoration?.hintText ?? localizations.dateHelpText,
      ),
      controller: TextEditingController(
        text: date != null ? localizations.formatCompactDate(date) : null,
      ),
      onTap: () async {
        final pickedDate = await widget.picker(state);

        state.didChange(pickedDate ?? date);
        widget.onChanged?.call(pickedDate ?? date);
      },
    );
  }
}

/// The state of a [DateFormField].
extension type DateFormFieldState(FormFieldState<DateTime> state)
    implements FormFieldState<DateTime> {
  @redeclare
  DateFormField get widget => state.widget as DateFormField;
}
