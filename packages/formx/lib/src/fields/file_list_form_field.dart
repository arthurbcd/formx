import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../../formx.dart';
import 'widgets/file_label.dart';
import 'widgets/icon_loading_button.dart';

/// A [FormField] that allows the user to pick multiple files.
class FileListFormField extends FormxField<List<XFile>> {
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
    super.autofocus,
    super.decoration,
    super.decorator,
    super.focusNode,
    super.onChanged,
    this.label,
    this.uploadIcon = const Icon(Icons.upload_file),
    this.filesPicker,
    this.onFilePressed,
  });

  /// Creates a `FormField<List<String>>` that directly uploads the files.
  static FormField<List<String>> url({
    bool autofocus = false,
    AutovalidateMode? autovalidateMode,
    InputDecoration? decoration = const InputDecoration(),
    FormxFieldDecorator<List<String>>? decorator,
    bool enabled = true,
    Future<void> Function(String url)? fileDeleter,
    Future<String> Function(XFile file, String? url)? fileUploader,
    Future<List<XFile>> Function(FormFieldState<dynamic> state)? filesPicker,
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
    return _FileUrlListFormField(
      filesPicker: filesPicker,
      autofocus: autofocus,
      autovalidateMode: autovalidateMode,
      decoration: decoration,
      decorator: decorator,
      enabled: enabled,
      fileDeleter: fileDeleter,
      fileUploader: fileUploader,
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

  /// The [Widget] icon to upload files.
  final Widget uploadIcon;

  /// The [InputChip.label] widget to show when a file is attached.
  final Widget Function(XFile file)? label;

  /// The files picker to use.
  final FieldPicker<List<XFile>>? filesPicker;

  /// The callback that is called when a file is pressed.
  final void Function(XFile file)? onFilePressed;

  @override
  Widget buildDecorator(FormxFieldState<List<XFile>> state, Widget child) {
    final filesPicker = this.filesPicker ?? Formx.setup.filesPicker;

    return InputDecoratorx(
      decoration: decoration?.applyDefaultWidgets(
        suffixIcon: IconLoadingButton(
          icon: uploadIcon,
          onPressed: () async {
            final files = state.value ?? [];
            final newFiles = files + await filesPicker(state);

            state.didChange(newFiles);
          },
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(FormFieldState<List<XFile>> state) {
    final files = state.value ?? [];

    return Wrap(
      children: [
        for (final (index, file) in files.indexed)
          InputChip(
            label: label?.call(file) ?? FileLabel(file),
            onPressed: switch (onFilePressed) {
              var onFilePressed? => () => onFilePressed(file),
              _ => null,
            },
            onDeleted: () {
              final newFiles = files..removeAt(index);
              state.didChange(newFiles);
            },
          ),
      ],
    );
  }
}

class _FileUrlListFormField extends FormxField<List<String>> {
  const _FileUrlListFormField({
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
    this.path,
    this.label,
    this.uploadIcon = const Icon(Icons.upload_file),
    this.filesPicker,
    this.fileUploader,
    this.fileDeleter,
    this.onFilePressed,
    this.onFilesChanged,
  });

  /// The [InputChip.label] widget to show when a file is attached.
  final Widget Function(String url, XFile? file)? label;
  final Widget uploadIcon;
  final UploaderPath? path;
  final FileDeleter? fileDeleter;
  final FileUploader? fileUploader;
  final FieldPicker<List<XFile>>? filesPicker;
  final void Function(String url, XFile file)? onFilePressed;
  final void Function(Map<String, XFile?> files)? onFilesChanged;

  @override
  FormFieldState<List<String>> createState() => _FormFieldState();

  @override
  Widget buildDecorator(FormxFieldState<List<String>> state, Widget child) {
    if (state is! _FormFieldState) throw UnimplementedError();
    final filesPicker = this.filesPicker ?? Formx.setup.filesPicker;
    final fileUploader = this.fileUploader ?? Formx.setup.fileUploader;

    return InputDecoratorx(
      decoration: decoration?.applyDefaultWidgets(
        suffixIcon: IconLoadingButton(
          icon: uploadIcon,
          onPressed: () async {
            final files = state.files;
            final newFiles = await filesPicker(state);
            final futures = <Future>[];

            for (final file in newFiles) {
              final path = await this.path?.call(file);
              final future = fileUploader(file, path).then((url) {
                files[url] = file;
                state.didChange(files.keys.toList(), files.values.toList());
              });
              futures.add(future);
            }

            await futures.wait;
          },
        ),
      ),
      child: child,
    );
  }

  @override
  Widget build(FormFieldState<List<String>> state) {
    if (state is! _FormFieldState) throw UnimplementedError();
    final fileDeleter = this.fileDeleter ?? Formx.setup.fileDeleter;
    final urls = state.files;

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final (url, file) in urls.pairs)
          InputChip(
            key: Key(url),
            label: label?.call(url, file) ?? FileLabel(file, url: url),
            onPressed: switch ((onFilePressed, file)) {
              (var fn?, var file?) => () => fn(url, file),
              _ => null,
            },
            onDeleted: () {
              final map = urls..remove(url);
              final newUrls = map.keys.toList();
              final newFiles = map.values.toList();

              state.didChange(newUrls, newFiles);
              fileDeleter?.call(url).ignore();
            },
          ),
      ],
    );
  }
}

class _FormFieldState extends FormxFieldState<List<String>> {
  var _files = <XFile?>[];
  late var _saved = {...?widget.initialValue};

  Map<String, XFile?> get files {
    final urls = value ?? [];

    if (value?.length == _files.length) {
      return Map.fromIterables(urls, _files);
    }

    return Map.fromIterable(urls, value: (_) => null);
  }

  @override
  _FileUrlListFormField get widget => super.widget as _FileUrlListFormField;

  @override
  void didChange(List<String>? value, [List<XFile?> files = const []]) {
    _files = files;
    super.didChange(value);
    widget.onFilesChanged?.call(this.files);
  }

  @override
  bool validate() {
    if (!super.validate()) return false;
    _saved.addAll(value ?? []);
    return true;
  }

  @override
  void save() {
    _saved.addAll(value ?? []);
    super.save();
  }

  @override
  void reset() {
    _files = [];
    _deleteNotSaveds();
    super.reset();
    widget.onFilesChanged?.call(files);
  }

  @override
  void dispose() {
    _deleteNotSaveds();
    super.dispose();
  }

  void _deleteNotSaveds() {
    for (final url in value ?? <String>[]) {
      if (!_saved.contains(url)) {
        widget.fileDeleter?.call(url).ignore();
      }
    }
    _saved = {...?widget.initialValue};
  }
}
