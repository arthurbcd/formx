// ignore_for_file: avoid_dynamic_calls, lines_longer_than_80_chars, invalid_use_of_protected_member
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../extensions/text_formx_field_copy_with.dart';
import '../interface/text_form_field_base.dart';
import 'formx.dart';

/// A [TextFormField] that can be used with [Formx].
class TextFormxField extends TextFormFieldBase with FormxField<String> {
  /// A [TextFormField] that can be used with [Formx].
  ///
  /// The [tag] of this [TextFormxField], used as parameter key.
  const TextFormxField(
    this.tag, {
    super.key,
    super.controller,
    super.initialValue,
    super.focusNode,
    super.decoration = const InputDecoration(),
    super.keyboardType,
    super.textCapitalization = TextCapitalization.none,
    super.textInputAction,
    super.style,
    super.strutStyle,
    super.textDirection,
    super.textAlign = TextAlign.start,
    super.textAlignVertical,
    super.autofocus = false,
    super.readOnly = false,
    super.toolbarOptions,
    super.showCursor,
    super.obscuringCharacter = '•',
    super.obscureText = false,
    super.autocorrect = true,
    super.smartDashesType,
    super.smartQuotesType,
    super.enableSuggestions = true,
    super.maxLengthEnforcement,
    super.maxLines = 1,
    super.minLines,
    super.expands = false,
    super.maxLength,
    super.onChanged,
    super.onTap,
    super.onTapOutside,
    super.onEditingComplete,
    super.onFieldSubmitted,
    super.onSaved,
    super.validator,
    super.inputFormatters,
    super.enabled,
    super.cursorWidth = 2.0,
    super.cursorHeight,
    super.cursorRadius,
    super.cursorColor,
    super.keyboardAppearance,
    super.scrollPadding = const EdgeInsets.all(20),
    super.enableInteractiveSelection,
    super.selectionControls,
    super.buildCounter,
    super.scrollPhysics,
    super.autofillHints,
    super.autovalidateMode,
    super.scrollController,
    super.restorationId,
    super.enableIMEPersonalizedLearning = true,
    super.mouseCursor,
    super.contextMenuBuilder,
    super.spellCheckConfiguration,
    super.magnifierConfiguration,
    super.undoController,
    super.onAppPrivateCommand,
    super.cursorOpacityAnimates,
    super.selectionHeightStyle = ui.BoxHeightStyle.tight,
    super.selectionWidthStyle = ui.BoxWidthStyle.tight,
    super.dragStartBehavior = DragStartBehavior.start,
    super.contentInsertionConfiguration,
    super.clipBehavior = Clip.hardEdge,
    super.scribbleEnabled = true,
    super.canRequestFocus = true,
  });

  @override
  final String tag;

  @override
  FormFieldValidator<String>? get validator {
    if (Formx.disableValidatorsOnDebugMode && kDebugMode) {
      return null;
    }
    return super.validator;
  }

  /// Accesses the nearest [TextFormxFieldState] above the given context.
  static TextFormxFieldState of(BuildContext context) {
    final maybe = context.findAncestorStateOfType<TextFormxFieldState>();
    assert(maybe != null, 'No [Formx] was found above this context.');
    return maybe!;
  }

  @override
  TextFormxFieldState createState() => TextFormxFieldState();
}

/// A tagged widget for [Formx]. Where [T] is the type of the field value.
mixin FormxField<T> on StatefulWidget {
  /// The [tag] of this [TextFormxField], used as parameter key.
  String get tag;
}

/// The [State] of fields below [Formx]. Currently only [TextFormxField].
abstract class FormxFieldState<T> extends State<FormxField<T>> {
  final _fieldKey = GlobalKey<FormFieldState<T>>();
  FormFieldState<T> get _state => _fieldKey.currentState!;

  /// The current value of this [TextFormxField].
  T? get value => _state.value;

  /// The current error text of this [TextFormxField].
  String? get errorText => _state.errorText;

  /// True if this field has any validation errors.
  bool get hasError => _state.hasError;

  /// Trus if the current value is valid.
  bool get isValid => _state.isValid;

  /// Calls the [FormField]'s onSaved method with the current value.
  void save() => _state.save();

  /// Resets this [TextFormxField] to its initial value.
  void reset() => _state.reset();

  /// Validates this [TextFormxField] and returns its error text.
  bool validate() => _state.validate();

  /// Calls [FormFieldState.didChange] with the current value.
  void didChange(T? value) => _state.didChange(value);

  /// Sets the current value of this [TextFormxField].
  void setValue(T? value) => _state.setValue(value);

  /// Gets [FormFieldState.restorationId].
  String? get restorationId => _state.restorationId;

  /// Calls [FormFieldState.restoreState].
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    _state.restoreState(oldBucket, initialRestore);
  }
}

/// The [State] of a [TextFormxField].
class TextFormxFieldState extends FormxFieldState<String> {
  late final _formx = Formx.of(context);
  late TextFormxField _field = widget;

  @override
  TextFormxField get widget => super.widget as TextFormxField;

  /// The [tag] of this [TextFormxField], used as parameter key.
  String get tag => widget.tag;

  /// Updates this [TextFormxField] programmatically.
  void update(TextFormxField Function(TextFormxField field) onField) {
    setState(() => _field = onField(_field));
  }

  @override
  void initState() {
    _formx.attachField(tag, this);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void reassemble() {
    super.reassemble();

    //extensions methods are applied after reassemble, so this is needed.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _field = widget);
    });
  }

  @override
  Widget build(BuildContext context) {
    final field = _formx.fieldModifier?.call(tag, _field) ?? _field;

    final widget = field
        .copyWith(
          enabled: field.enabled ?? _formx.enabled,
          initialValue: field.controller == null
              ? field.initialValue ?? _formx.initialValues[tag]?.toString()
              : null,
          autovalidateMode: field.autovalidateMode ?? _formx.autovalidateMode,
          onChanged: (value) {
            field.onChanged?.call(value);
            _formx.onChanged(tag, value);
          },
          onFieldSubmitted: (value) {
            field.onFieldSubmitted?.call(value);
            _formx.onSubmitted(tag, value);
          },
          decoration: _formx.decorationModifier?.call(tag, field.decoration) ??
              field.decoration,
          validator: (value) {
            if ((field.autovalidateMode ?? _formx.autovalidateMode) == null) {
              update(
                (field) =>
                    field.copyWith(autovalidateMode: AutovalidateMode.always),
              );
            }

            final errorText = field.validator?.call(value);
            if (errorText == null) return null;

            final onErrorText = _formx.errorTextModifier?.call(tag, errorText);
            return onErrorText ?? errorText;
          },
        )
        .toTextFormField(_fieldKey);

    return _formx.fieldWrapper?.call(tag, widget) ?? widget;
  }
}
