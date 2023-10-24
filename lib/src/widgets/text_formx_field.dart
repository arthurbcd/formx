// ignore_for_file: avoid_dynamic_calls, lines_longer_than_80_chars, invalid_use_of_protected_member
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../extensions/text_formx_field_copy_with.dart';
import '../interface/text_form_field_copy.dart';
import 'formx.dart';

/// A [TextFormField] that can be used with [Formx].
class TextFormxField extends TextFormFieldCopy {
  /// A [TextFormField] that can be used with [Formx].
  ///
  /// The [tag] of this [TextFormxField], used as parameter key.
  const TextFormxField(
    this.tag, {
    super.key,
    this.fieldKey,
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

  /// The [tag] of this [TextFormxField], used as parameter key.
  final String tag;

  /// The [key] of this internal [TextFormField].
  final GlobalKey<FormFieldState<String>>? fieldKey;

  /// Accesses the nearest [TextFormxFieldState] above the given context.
  static TextFormxFieldState of(BuildContext context) {
    final maybe = context.findAncestorStateOfType<TextFormxFieldState>();
    assert(maybe != null, 'No [Formx] was found above this context.');
    return maybe!;
  }

  @override
  State<TextFormxField> createState() => TextFormxFieldState();
}

/// The [State] of a [TextFormxField].
class TextFormxFieldState extends State<TextFormxField> {
  late final _formx = Formx.of(context);
  late final _fieldKey = widget.fieldKey ?? GlobalKey();
  late TextFormxField _field = widget;

  /// The [tag] of this [TextFormxField], used as parameter key.
  String get tag => widget.tag;

  /// Updates this [TextFormxField] programmatically.
  void update(TextFormxField Function(TextFormxField field) onField) {
    setState(() => _field = onField(_field));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @protected
  void _init() {
    _formx.attachField(widget.tag, _fieldKey.currentState!);
  }

  @override
  Widget build(BuildContext context) {
    // * Field wrapper
    final field = _formx.onField?.call(tag, _field) ?? _field;

    // * Form inheritance
    final widget = field
        .copyWith(
          enabled: field.enabled ?? _formx.enabled,
          initialValue: field.controller == null
              ? field.initialValue ?? _formx.form[tag] as String?
              : null,
          autovalidateMode: field.autovalidateMode ?? _formx.autovalidateMode,
          onChanged: (value) {
            field.onChanged?.call(value);
            _formx.didChange(tag, value);
          },
          onFieldSubmitted: (value) {
            field.onFieldSubmitted?.call(value);
            _formx.didSubmit();
          },
          decoration: () {
            final onDecoration =
                _formx.onDecoration?.call(tag, field.decoration);
            return onDecoration ?? field.decoration;
          }(),
          validator: (value) {
            if ((field.autovalidateMode ?? _formx.autovalidateMode) == null) {
              update(
                (field) =>
                    field.copyWith(autovalidateMode: AutovalidateMode.always),
              );
            }

            final errorText = field.validator?.call(value);
            if (errorText == null) return null;

            final onErrorText = _formx.onErrorText?.call(tag, errorText);
            return onErrorText ?? errorText;
          },
        )
        .toTextFormField(_fieldKey);

    // * Widget wrapper
    return _formx.onWidget?.call(tag, widget) ?? widget;
  }
}
