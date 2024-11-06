// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../extensions/formx_extension.dart';
import '../models/formx_setup.dart';
import 'widgets/file_label.dart';
import 'widgets/formx_field.dart';
import 'widgets/icon_loading_button.dart';

/// A [FormField] that allows the user to pick a file.
class FileFormField extends FormxField<XFile> {
  /// Creates a [FileFormField] that allows the user to pick a file.
  const FileFormField({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    super.decoration,
    super.decorator,
    super.onChanged,
    super.autofocus,
    super.focusNode,
    this.label,
    this.uploadIcon = const Icon(Icons.upload_file),
    this.filePicker,
    this.onFilePressed,
  });

  /// Creates a `FormField<String>` that directly gets the uploaded file url.
  /// The file is uploaded to the `path` using the `fileUploader`.
  ///
  /// The `path` is generated using the `path` function.
  static FormField<String?> url({
    Key? key,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    String? forceErrorText,
    String? initialValue,
    void Function(String? url)? onSaved,
    String? restorationId,
    String? Function(String? value)? validator,
    InputDecoration? decoration = const InputDecoration(),
    void Function(String? value)? onChanged,
    bool autofocus = false,
    InputDecoration? Function(FormFieldState<String> state)? decorator,
    FocusNode? focusNode,
    Future<XFile?> Function(FormFieldState<dynamic> state)? filePicker,
    FutureOr<String> Function(XFile file)? path,
    Future<String> Function(XFile file, String? url)? fileUploader,
    Future<void> Function(String url)? fileDeleter,
    void Function(String url, XFile file)? onFilePressed,
    void Function(String? url, XFile? file)? onFileChanged,
    Widget Function(String url, XFile? file)? label,
    Widget uploadIcon = const Icon(Icons.upload_file),
  }) {
    return _FileUrlFormField(
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
      filePicker: filePicker,
      fileDeleter: fileDeleter,
      fileUploader: fileUploader,
      onFileChanged: onFileChanged,
      path: path,
    );
  }

  /// The [InputChip.label] widget to show when a file is attached.
  final Widget Function(XFile file)? label;

  /// The [Widget] icon to upload files.
  final Widget uploadIcon;

  /// The file picker to use.
  final FieldPicker<XFile?>? filePicker;

  /// The callback that is called when a file is pressed.
  final void Function(XFile file)? onFilePressed;

  @override
  InputDecoration? decorate(FormFieldState<XFile> state) {
    final filePicker = this.filePicker ?? Formx.setup.filePicker;

    return decoration?.applyDefaultWidgets(
      suffixIcon: IconLoadingButton(
        icon: uploadIcon,
        onPressed: () async {
          final newFile = await filePicker(state);
          state.didChange(newFile);
        },
      ),
    );
  }

  @override
  Widget build(FormFieldState<XFile> state) {
    final file = state.value;
    if (file == null) return const SizedBox.shrink();

    return InputChip(
      key: ValueKey(file.name),
      label: label?.call(file) ?? FileLabel(file),
      onPressed: switch (onFilePressed) {
        var onFilePressed? => () => onFilePressed(file),
        _ => null,
      },
      onDeleted: () => state.didChange(null),
    );
  }
}

class _FileUrlFormField extends FormxField<String> {
  const _FileUrlFormField({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    super.decoration,
    super.onChanged,
    super.autofocus,
    super.decorator,
    super.focusNode,
    this.filePicker,
    this.path,
    this.fileUploader,
    this.fileDeleter,
    this.onFilePressed,
    this.onFileChanged,
    this.label,
    this.uploadIcon = const Icon(Icons.upload_file),
  });

  final UploaderPath? path;
  final FieldPicker<XFile?>? filePicker;
  final FileUploader? fileUploader;
  final FileDeleter? fileDeleter;
  final Widget Function(String url, XFile? file)? label;
  final Widget uploadIcon;

  final void Function(String url, XFile file)? onFilePressed;
  final void Function(String? url, XFile? file)? onFileChanged;

  @override
  FormFieldState<String> createState() => _FormFieldState();

  @override
  InputDecoration? decorate(FormFieldState<String> state) {
    if (state is! _FormFieldState) throw UnimplementedError();

    final filePicker = this.filePicker ?? Formx.setup.filePicker;
    final fileUploader = this.fileUploader ?? Formx.setup.fileUploader;

    return decoration?.applyDefaultWidgets(
      suffixIcon: IconLoadingButton(
        icon: uploadIcon,
        onPressed: () async {
          final newFile = await filePicker(state);
          if (newFile == null) return;

          final path = await this.path?.call(newFile);
          final url = await fileUploader(newFile, path);

          state.didChange(url, newFile);
        },
      ),
    );
  }

  @override
  Widget build(FormFieldState<String> state) {
    if (state is! _FormFieldState) throw UnimplementedError();

    return Wrap(
      children: [
        if (state.value case var url?)
          InputChip(
            key: Key(url),
            label:
                label?.call(url, state.file) ?? FileLabel(state.file, url: url),
            onPressed: switch ((onFilePressed, state.file)) {
              (var fn?, var file?) => () => fn(url, file),
              _ => null,
            },
            onDeleted: () {
              state.didChange(null);
            },
          ),
      ],
    );
  }
}

class _FormFieldState extends FormxFieldState<String> {
  XFile? _file;

  /// The current associated [XFile].
  XFile? get file => _file;

  Future<void> Function(String url)? get fileDeleter =>
      widget.fileDeleter ?? Formx.setup.fileDeleter;

  @override
  _FileUrlFormField get widget => super.widget as _FileUrlFormField;

  @override
  void didChange(String? value, [XFile? file]) {
    final oldUrl = this.value;

    _file = file;
    super.didChange(value);
    widget.onFileChanged?.call(value, file);

    if (oldUrl != null && oldUrl != value) {
      fileDeleter?.call(oldUrl).ignore();
    }
  }

  @override
  void reset() {
    _file = null;
    super.reset();
    widget.onFileChanged?.call(value, null);
  }
}
