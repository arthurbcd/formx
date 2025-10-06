import 'dart:async';

import 'package:flutter/material.dart';

import '../../formx.dart';

/// A [FormField] of type [DateTime].
class DateFormxField extends FormxField<DateTime> {
  /// Creates a [FormField] of type [DateTime].
  ///
  /// You can override the default [picker] to show a custom date picker or to
  /// apply customized parameters.
  ///
  const DateFormxField({
    super.key,
    super.onChanged,
    super.decoration,
    super.decorator,
    super.autofocus,
    super.focusNode,
    super.enabled,
    super.readOnly,
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
    final widget = state.widget as DateFormxField;
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
    final localizations = Localizations.of<MaterialLocalizations>(
          state.context,
          MaterialLocalizations,
        ) ??
        const DefaultMaterialLocalizations();
    final disabledColor = Theme.of(state.context).disabledColor;

    final mask = localizations.dateHelpText.replaceAll(RegExp(r'[^\W]'), '#');
    final date = state.value;

    state.onChanged ??= (date) {
      final text = date != null ? localizations.formatCompactDate(date) : null;
      state.extraKey?.currentState?.didChange(text);
    };

    state.onReset ??= () {
      state.extraKey?.currentState?.reset();
    };

    final initialDate = state.widget.initialValue;

    return TextFormField(
      key: state.extraKey ??= GlobalKey(),
      initialValue: initialDate != null
          ? localizations.formatCompactDate(initialDate)
          : null,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      focusNode: focusNode,
      restorationId: restorationId,
      forceErrorText: forceErrorText,
      autovalidateMode: AutovalidateMode.onUnfocus,
      keyboardType: TextInputType.datetime,
      inputFormatters: Formatter().mask(mask),
      validator: Validator<String>(
        invalidText: localizations.invalidDateFormatLabel,
        test: (text) => localizations.parseCompactDate(text) != null,
      ),
      onChanged: (text) {
        final parsedDate = localizations.parseCompactDate(text);
        state.onChanged = null;
        state.didChange(parsedDate);
      },
      onSaved: (text) {
        final parsedDate = localizations.parseCompactDate(text);
        state.onChanged = null;
        state.didChange(parsedDate);
      },
      decoration: decoration?.copyWith(
        hintText: decoration?.hintText ?? localizations.dateHelpText,
        errorText: decoration?.errorText ?? state.errorText,
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today,
              color: readOnly ? disabledColor : null),
          onPressed: readOnly || !enabled
              ? null
              : () async {
                  final pickedDate = await picker(state);
                  state.didChange(pickedDate ?? date);
                },
        ),
      ),
    );
  }
}
