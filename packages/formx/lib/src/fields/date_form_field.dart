import 'dart:async';

import 'package:flutter/material.dart';

import '../extensions/form_field_state_extension.dart';
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
    this.firstDate,
    this.lastDate,
    this.picker = _picker,
  });

  static Future<DateTime?> _picker(FormFieldState<DateTime> state) {
    return Formx.setup.datePicker(state);
  }

  /// The default [picker] to show the date picker.
  static Future<DateTime?> defaultPicker(FormFieldState state) {
    final widget = state.widget as DateFormField;
    final now = DateTime.now();

    return showDatePicker(
      context: state.context,
      initialDate: state.date,
      firstDate: widget.firstDate ?? now.copyWith(year: now.year - 100),
      lastDate: widget.lastDate ?? now.copyWith(year: now.year + 100),
    );
  }

  /// The function that creates the [DateTime] picker.
  final Future<DateTime?> Function(FormFieldState<DateTime> state) picker;

  /// The first date that the user can select. Defaults to 100 years ago.
  final DateTime? firstDate;

  /// The last date that the user can select. Defaults to 100 years from now.
  final DateTime? lastDate;

  @override
  Widget buildDecorator(FormxFieldState<DateTime> state, Widget child) {
    return child;
  }

  @override
  Widget build(FormxFieldState<DateTime> state) {
    final localizations = MaterialLocalizations.of(state.context);
    final date = state.value;

    return TextFormField(
      readOnly: true,
      onTapAlwaysCalled: true,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      restorationId: restorationId,
      forceErrorText: forceErrorText,
      decoration: decoration?.copyWith(
        hintText: decoration?.hintText ?? localizations.dateHelpText,
        errorText: decoration?.errorText ?? state.errorText,
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
