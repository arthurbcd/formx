import 'dart:async';

import 'package:flutter/material.dart';

import '../extensions/formx_state.dart';
import 'widgets/formx_field.dart';

/// A [FormField] of type [DateTime].
class DateFormField extends FormxField<DateTime> {
  /// Creates a [FormField] of type [DateTime].
  ///
  /// You can override the default [picker] to show a custom date picker or to
  /// apply customized parameters.
  ///
  const DateFormField({
    super.key,
    super.onChanged,
    super.decoration,
    super.decorator,
    super.autofocus,
    super.focusNode,
    super.enabled,
    super.initialValue,
    super.autovalidateMode,
    super.onSaved,
    super.validator,
    super.restorationId,
    super.forceErrorText,
    this.picker = defaultPicker,
  });

  /// The default [picker] to show the date picker.
  static Future<DateTime?> defaultPicker(
    FormFieldState<DateTime> state,
  ) {
    return Formx.setup.datePicker(state);
  }

  /// The function that creates the [DateTime] picker.
  final Future<DateTime?> Function(FormFieldState<DateTime> state) picker;

  @override
  Widget build(FormFieldState<DateTime> state) {
    final localizations = MaterialLocalizations.of(state.context);
    final date = state.value;

    return TextField(
      readOnly: true,
      onTapAlwaysCalled: true,
      decoration: decoration?.copyWith(
        hintText: decoration?.hintText ?? localizations.dateHelpText,
      ),
      controller: TextEditingController(
        text: date != null ? localizations.formatCompactDate(date) : null,
      ),
      onTap: () async {
        final pickedDate = await picker(state);
        state.didChange(pickedDate ?? date);
      },
    );
  }
}
