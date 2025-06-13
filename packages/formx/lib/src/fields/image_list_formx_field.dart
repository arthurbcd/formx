import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../../formx.dart';
import 'image_formx_field.dart' show ImageFormxField;
import 'image_formx_field.dart';

/// A [FormField] that allows the user to pick images.
class ImageListFormxField extends FileListFormxField {
  /// Creates a [ImageFormxField] that allows the user to pick images.
  const ImageListFormxField({
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
    FieldPicker<List<XFile>>? imagesPicker,
  }) : super(filesPicker: imagesPicker);

  /// Creates a `FormField<List>` that directly gets the uploaded files urls.
  static FormField<List<String>> url({
    bool autofocus = false,
    AutovalidateMode? autovalidateMode,
    InputDecoration? decoration = const InputDecoration(),
    FormxFieldDecorator<List<String>>? decorator,
    bool enabled = true,
    Future<void> Function(String url)? imageDeleter,
    Future<String> Function(XFile file, String? path)? imageUploader,
    Future<List<XFile>> Function(FormFieldState<dynamic> state)? imagesPicker,
    FocusNode? focusNode,
    String? forceErrorText,
    List<String>? initialValue,
    Key? key,
    Widget Function(String url, XFile? file)? label,
    void Function(List<String>? urls)? onChanged,
    void Function(String url, XFile file)? onFilePressed,
    void Function(Map<String, XFile?> map)? onFilesChanged,
    void Function(List<String>? urls)? onSaved,
    FutureOr<String> Function(XFile file)? path,
    String? restorationId,
    Widget uploadIcon = const Icon(Icons.image),
    String? Function(List<String>? urls)? validator,
  }) {
    return FileListFormxField.url(
      filesPicker: imagesPicker ?? Formx.setup.imagesPicker,
      fileUploader: imageUploader ?? Formx.setup.imageUploader,
      fileDeleter: imageDeleter ?? Formx.setup.imageDeleter,
      autofocus: autofocus,
      autovalidateMode: autovalidateMode,
      decoration: decoration,
      decorator: decorator,
      enabled: enabled,
      focusNode: focusNode,
      forceErrorText: forceErrorText,
      initialValue: initialValue,
      key: key,
      label: label,
      onChanged: onChanged,
      onFilePressed: onFilePressed,
      onFilesChanged: onFilesChanged,
      onSaved: onSaved,
      path: path,
      restorationId: restorationId,
      uploadIcon: uploadIcon,
      validator: validator,
    );
  }

  @override
  FieldPicker<List<XFile>>? get filesPicker =>
      super.filesPicker ?? Formx.setup.imagesPicker;
}
