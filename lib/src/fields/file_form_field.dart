import 'package:flutter/material.dart';

import '../../formx.dart';
import 'widgets/file_label.dart';
import 'widgets/inputx_decorator.dart';

/// A [FormField] that allows the user to pick a file.
class FileFormField extends FormField<XFile> {
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
    this.decoration = const InputDecoration(),
    this.filePicker,
    this.onFilePressed,
  }) : super(builder: _FileFormField.new);

  /// Creates a `FormField<String>` that directly gets the uploaded file url.
  /// The file is uploaded to the [path] using the [fileUploader].
  ///
  /// The [path] is generated using the [path] function.
  static FormField<String> url({
    Key? key,
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    String? forceErrorText,
    String? initialValue,
    void Function(String? value)? onSaved,
    String? restorationId,
    String? Function(String? value)? validator,
    InputDecoration? decoration = const InputDecoration(),
    FieldPicker<XFile?>? filePicker,
    UploaderPath? path,
    FileUploader? fileUploader,
    FileDeleter? fileDeleter,
    void Function(XFile file)? onFilePressed,
  }) {
    return _FileUrlFormField(
      key: key,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      forceErrorText: forceErrorText,
      initialValue: initialValue,
      onSaved: onSaved,
      restorationId: restorationId,
      validator: validator,
      decoration: decoration,
      path: path,
      filePicker: filePicker,
      fileDeleter: fileDeleter,
      fileUploader: fileUploader,
      onFilePressed: onFilePressed,
    );
  }

  /// The decoration to show around the field.
  final InputDecoration decoration;

  /// The file picker to use.
  final FieldPicker<XFile?>? filePicker;

  /// The callback that is called when a file is pressed.
  final void Function(XFile file)? onFilePressed;
}

class _FileFormField extends StatelessWidget {
  const _FileFormField(this.state, {super.key});
  final FormFieldState<XFile> state;

  @override
  Widget build(BuildContext context) {
    final widget = state.widget as FileFormField;
    final filePicker = widget.filePicker ?? Formx.setup.filePicker;
    final file = state.value;

    return InputxDecorator(
      decoration: widget.decoration,
      state: state,
      suffix: (icon) => IconButton(
        icon: icon,
        disabledColor: file == null ? null : Colors.grey,
        onPressed: file == null
            ? () async {
                final newFile = await filePicker(state);
                state.didChange(newFile);
              }
            : null,
      ),
      child: file != null
          ? InputChip(
              key: ValueKey(file.name),
              label: FileLabel(file),
              onPressed: switch (widget.onFilePressed) {
                var onFilePressed? => () => onFilePressed(file),
                _ => null,
              },
              onDeleted: () {
                state.didChange(null);
              },
            )
          : null,
    );
  }
}

class _FileUrlFormField extends FormField<String> {
  const _FileUrlFormField({
    super.key,
    super.autovalidateMode,
    super.enabled,
    super.forceErrorText,
    super.initialValue,
    super.onSaved,
    super.restorationId,
    super.validator,
    this.decoration = const InputDecoration(),
    this.filePicker,
    this.path,
    this.fileUploader,
    this.fileDeleter,
    this.onFilePressed,
  }) : super(builder: __FileUrlFormField.new);

  final InputDecoration? decoration;
  final UploaderPath? path;
  final FieldPicker<XFile?>? filePicker;
  final FileUploader? fileUploader;
  final FileDeleter? fileDeleter;
  final void Function(XFile file)? onFilePressed;
}

class __FileUrlFormField extends StatefulWidget {
  const __FileUrlFormField(this.state, {super.key});
  final FormFieldState<String> state;

  @override
  State<__FileUrlFormField> createState() => __FileUrlFormFieldState();
}

class __FileUrlFormFieldState extends State<__FileUrlFormField> {
  XFile? _file;

  @override
  Widget build(BuildContext context) {
    final state = this.widget.state;
    final widget = state.widget as _FileUrlFormField;
    final filePicker = widget.filePicker ?? Formx.setup.filePicker;
    final fileUploader = widget.fileUploader ?? Formx.setup.fileUploader;
    final fileDeleter = widget.fileDeleter ?? Formx.setup.fileDeleter;
    final file = _file;

    return InputxDecorator(
      decoration: widget.decoration,
      state: state,
      suffix: (icon) => IconButton(
        icon: icon,
        onPressed: () async {
          final newFile = await filePicker(state);
          if (newFile == null) return;

          final path = await widget.path?.call(newFile);
          final url = await fileUploader(newFile, path);

          setState(() => _file = newFile);
          state.didChange(url);
        },
      ),
      child: file != null
          ? InputChip(
              key: Key(state.value!),
              label: FileLabel(file),
              onPressed: switch (widget.onFilePressed) {
                var onFilePressed? => () => onFilePressed(file),
                _ => null,
              },
              onDeleted: () {
                state.didChange(null);
                fileDeleter?.call(state.value!);
              },
            )
          : null,
    );
  }
}
