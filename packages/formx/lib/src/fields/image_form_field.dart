import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../formx_state.dart';
import '../models/formx_setup.dart';
import 'file_form_field.dart';
import 'widgets/formx_field.dart';

/// A [FormField] that allows the user to pick an image.
class ImageFormField extends FileFormField {
  /// Creates a [ImageFormField] that allows the user to pick an image.
  const ImageFormField({
    super.key,
    super.autovalidateMode,
    super.autofocus,
    super.decorator,
    super.decoration,
    super.enabled,
    super.focusNode,
    super.forceErrorText,
    super.initialValue,
    super.label,
    super.onChanged,
    super.onFilePressed,
    super.onSaved,
    super.restorationId,
    super.uploadIcon = const Icon(Icons.image),
    super.validator,
    FieldPicker<XFile?>? imagePicker,
  }) : super(filePicker: imagePicker);

  /// Creates a `FormField<String>` that directly gets the uploaded image url.
  static FormField<String?> url({
    Key? key,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    String? forceErrorText,
    String? initialValue,
    void Function(String? url)? onSaved,
    String? restorationId,
    String? Function(String? url)? validator,
    InputDecoration? decoration = const InputDecoration(),
    void Function(String? url)? onChanged,
    bool autofocus = false,
    FormxFieldDecorator<String?>? decorator,
    FocusNode? focusNode,
    Future<XFile?> Function(FormFieldState<dynamic> state)? imagePicker,
    FutureOr<String> Function(XFile file)? path,
    Future<String> Function(XFile file, String? path)? imageUploader,
    Future<void> Function(String url)? imageDeleter,
    void Function(String url, XFile file)? onFilePressed,
    void Function(String? url, XFile? file)? onFileChanged,
    Widget Function(String url, XFile? file)? label,
    Widget uploadIcon = const Icon(Icons.image),
  }) {
    return FileFormField.url(
      filePicker: imagePicker ?? Formx.setup.imagePicker,
      fileUploader: imageUploader ?? Formx.setup.imageUploader,
      fileDeleter: imageDeleter ?? Formx.setup.imageDeleter,
      key: key,
      autovalidateMode: autovalidateMode,
      autofocus: autofocus,
      decorator: decorator,
      decoration: decoration,
      enabled: enabled,
      focusNode: focusNode,
      forceErrorText: forceErrorText,
      initialValue: initialValue,
      label: label,
      onChanged: onChanged,
      onFilePressed: onFilePressed,
      onSaved: onSaved,
      restorationId: restorationId,
      uploadIcon: uploadIcon,
      validator: validator,
      onFileChanged: onFileChanged,
      path: path,
    );
  }

  @override
  FieldPicker<XFile?>? get filePicker =>
      super.filePicker ?? Formx.setup.imagePicker;
}
