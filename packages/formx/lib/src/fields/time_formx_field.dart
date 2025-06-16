import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../formx.dart';

/// A [FormField] of type [DateTime].
class TimeFormxField extends FormxField<TimeOfDay> {
  /// Creates a [FormField] of type [DateTime].
  ///
  /// You can override the default [picker] to show a custom date picker or to
  /// apply customized parameters.
  ///
  const TimeFormxField({
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

  static Future<TimeOfDay?> _picker(FormFieldState<TimeOfDay> state) {
    return Formx.setup.timePicker(state);
  }

  /// The default [picker] to show the date picker.
  static Future<TimeOfDay?> defaultPicker(FormFieldState state) {
    final now = TimeOfDay.now();

    return showTimePicker(
      context: state.context,
      initialTime: state.time ?? now,
    );
  }

  static TimeOfDay? parseCompactTime(String? text) {
    if (text == null) return null;

    final parts = text.split(':');
    if (parts.length != 2) return null;

    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }

    return TimeOfDay(hour: h, minute: m);
  }

  /// The function that creates the [TimeOfDay] picker.
  final Future<TimeOfDay?> Function(FormFieldState<TimeOfDay> state) picker;

  /// The first date that the user can select. Defaults to 100 years ago.
  final DateTime? firstDate;

  /// The last date that the user can select. Defaults to 100 years from now.
  final DateTime? lastDate;

  @override
  Widget buildDecorator(FormxFieldState<TimeOfDay> state, Widget child) {
    return child;
  }

  @override
  Widget build(FormxFieldState<TimeOfDay> state) {
    final alwaysUse24H = MediaQuery.alwaysUse24HourFormatOf(state.context);
    final key = GlobalObjectKey<FormFieldState<String>>(state.hashCode);
    final localizations = Localizations.of<MaterialLocalizations>(
          state.context,
          MaterialLocalizations,
        ) ??
        const DefaultMaterialLocalizations();
    final date = state.value;

    return TextFormField(
      key: key,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      restorationId: restorationId,
      forceErrorText: forceErrorText,
      autovalidateMode: AutovalidateMode.onUnfocus,
      keyboardType: TextInputType.datetime,
      inputFormatters: Formatter().time(),
      validator: Validator<String>(
        invalidText: localizations.invalidTimeLabel,
        test: (text) => parseCompactTime(text) != null,
      ),
      onChanged: (text) {
        final parsedTime = parseCompactTime(text);
        state.didChange(parsedTime);
      },
      onSaved: (text) {
        final parsedTime = parseCompactTime(text);
        state.didChange(parsedTime);
      },
      decoration: decoration?.copyWith(
        hintText: decoration?.hintText ?? 'hh:mm',
        errorText: decoration?.errorText ?? state.errorText,
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () async {
            final pickedTime = await picker(state);
            state.didChange(pickedTime ?? date);

            if (pickedTime != null) {
              final text = localizations.formatTimeOfDay(
                pickedTime,
                alwaysUse24HourFormat: alwaysUse24H,
              );
              key.currentState?.didChange(text);
            }
          },
        ),
      ),
    );
  }
}

class TimeTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var nums = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (nums.isEmpty || oldValue.text == '00:00' && nums == '000') {
      const noSelection = TextSelection.collapsed(offset: 0);
      return newValue.copyWith(text: '', selection: noSelection);
    }

    nums = nums.length > 4 ? nums.substring(nums.length - 4) : nums;
    nums = nums.padLeft(4, '0');
    final formatted = '${nums.substring(0, 2)}:${nums.substring(2, 4)}';

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
