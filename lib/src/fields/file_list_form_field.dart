import 'package:flutter/material.dart';
import 'package:material_file_icon/material_file_icon.dart';

import '../extensions/formx_extension.dart';
import '../models/formx_setup.dart';
import 'widgets/file_label.dart';
import 'widgets/icon_loading_button.dart';
import 'widgets/inputx_decorator.dart';

/// A mixin that provides default values for the formx [FormField]s.
mixin FieldData<T> on FormField<T> {
  /// The decoration to show around the this [FormField].
  InputDecoration? get decoration;
}

/// A [FormField] that allows the user to pick multiple files.
class FileListFormField extends FormField<List<XFile>> with FieldData {
  /// Creates a [FileListFormField] that allows the user to pick multiple files.
  const FileListFormField({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    this.decoration = const InputDecoration(),
    this.filesPicker,
    this.onFilePressed,
  }) : super(builder: _FileListFormField.new);

  @override
  final InputDecoration? decoration;

  /// The files picker to use.
  final FieldPicker<List<XFile>>? filesPicker;

  /// The callback that is called when a file is pressed.
  final void Function(XFile file)? onFilePressed;

  /// Creates a `FormField<List<String>>` that directly uploads the files.
  static FormField<List<String>> url({
    Key? key,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    String? forceErrorText,
    List<String>? initialValue,
    void Function(List<String>? value)? onSaved,
    String? restorationId,
    String? Function(List<String>? value)? validator,
    InputDecoration? decoration = const InputDecoration(),
    UploaderPath? path,
    FieldPicker<List<XFile>>? filesPicker,
    FileUploader? fileUploader,
    FileDeleter? fileDeleter,
    void Function(XFile file)? onFilePressed,
  }) {
    return _FileUrlListFormField(
      key: key,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      forceErrorText: forceErrorText,
      initialValue: initialValue,
      onSaved: onSaved,
      restorationId: restorationId,
      validator: validator,
      path: path,
      filesPicker: filesPicker,
      fileUploader: fileUploader,
      fileDeleter: fileDeleter,
      decoration: decoration,
      onFilePressed: onFilePressed,
    );
  }
}

class _FileListFormField extends StatelessWidget {
  const _FileListFormField(this.state);
  final FormFieldState<List<XFile>> state;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget as FileListFormField;
    final files = [...?state.value];
    final filesPicker = widget.filesPicker ?? Formx.setup.filesPicker;

    return InputxDecorator(
      isTextEmpty: false, // not a text field.

      decoration: widget.decoration,
      suffix: IconLoadingButton(
        icon: widget.decoration?.suffixIcon ?? const Icon(Icons.upload_file),
        onPressed: () async {
          final newFiles = await filesPicker(state);
          state.didChange(files + newFiles);
        },
      ),
      child: Wrap(
        children: [
          for (final (index, file) in files.indexed)
            InputChip(
              label: FileLabel(file),
              onPressed: switch (widget.onFilePressed) {
                var onFilePressed? => () => onFilePressed(file),
                _ => null,
              },
              onDeleted: () {
                state.didChange(files..removeAt(index));
              },
            ),
        ],
      ),
    );
  }
}

class _FileUrlListFormField extends FormField<List<String>> {
  const _FileUrlListFormField({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    this.decoration = const InputDecoration(),
    this.onFilePressed,
    this.filesPicker,
    this.fileUploader,
    this.fileDeleter,
    this.path,
  }) : super(builder: __FileUrlListFormField.new);

  final InputDecoration? decoration;
  final void Function(XFile file)? onFilePressed;
  final FieldPicker<List<XFile>>? filesPicker;
  final FileUploader? fileUploader;
  final FileDeleter? fileDeleter;
  final UploaderPath? path;
}

class __FileUrlListFormField extends StatefulWidget {
  const __FileUrlListFormField(this.state);
  final FormFieldState<List<String>> state;

  @override
  State<__FileUrlListFormField> createState() => __FileUrlListFormFieldState();
}

class __FileUrlListFormFieldState extends State<__FileUrlListFormField> {
  Map<String, XFile> files = <String, XFile>{};

  @override
  Widget build(BuildContext context) {
    final state = this.widget.state;
    final widget = state.widget as _FileUrlListFormField;
    final urls = [...?state.value];
    final filesPicker = widget.filesPicker ?? Formx.setup.filesPicker;
    final fileUploader = widget.fileUploader ?? Formx.setup.fileUploader;
    final fileDeleter = widget.fileDeleter ?? Formx.setup.fileDeleter;

    return InputxDecorator(
      isTextEmpty: false, // not a text field.
      decoration: widget.decoration,
      suffix: IconLoadingButton(
        icon: widget.decoration?.suffixIcon ?? const Icon(Icons.upload_file),
        onPressed: () async {
          final newFiles = await filesPicker(state);
          final newUrls = <Future<String>>[];

          for (final file in newFiles) {
            final path = await widget.path?.call(file);
            final url = fileUploader(file, path).then((url) {
              setState(() => files[url] = file);
              return url;
            });
            newUrls.add(url);
          }

          state.didChange(urls + await newUrls.wait);
        },
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: [
          for (final MapEntry(key: url, value: file) in files.entries)
            InputChip(
              key: Key(url),
              label: FileLabel(file),
              onPressed: switch (widget.onFilePressed) {
                var onFilePressed? => () => onFilePressed(file),
                _ => null,
              },
              onDeleted: () {
                files.remove(url);
                state.didChange(files.keys.toList());
                fileDeleter?.call(url);
              },
            ),
        ],
      ),
    );
  }
}
