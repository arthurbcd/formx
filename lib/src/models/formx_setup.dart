import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_file_icon/material_file_icon.dart';

import '../extensions/form_field_state_extension.dart';
import '../extensions/formx_extension.dart';
import '../fields/date_form_field.dart';
import '../fields/file_form_field.dart';
import '../fields/file_list_form_field.dart';

/// A function to pick a value for a [FormField].
typedef FieldPicker<T> = Future<T> Function(FormFieldState state);

/// Signature for a function that uploads a file.
typedef FileUploader = Future<String> Function(XFile file, String? path);

/// Signature for a function that deletes a file.
typedef FileDeleter = Future<void> Function(String url);

/// Signature for a function that returns the path to upload a file.
typedef UploaderPath = FutureOr<String> Function(XFile file);

/// Global setup for all [Formx] widgets.
class FormxSetup {
  /// Creates a [FormxSetup].
  ///
  /// - [defaultTitle] - The default title for all fields.
  /// - [datePicker] - The default date picker for [DateFormField] fields.
  /// - [filePicker] - The default file picker for [FileFormField] fields.
  /// - [filesPicker] - The default file picker for [FileListFormField] fields.
  /// - [fileUploader] - The default file uploader for [XFile] fields.
  ///
  /// NOTE: Only some fields have default implementations. Others will throw
  /// an [UnimplementedError] if not set.
  ///
  const FormxSetup({
    this.defaultTitle = _defaultTitle,
    this.datePicker = _defaultDatePicker,
    this.filePicker = _noFilePicker,
    this.filesPicker = _noFilesPicker,
    this.fileUploader = _noFileUploader,
    this.fileDeleter = _noFileDeleter,
  });

  static String _defaultTitle(Object value) {
    if (value is String) return value;

    try {
      return (value as dynamic).title as String;
    } catch (_) {}
    try {
      return (value as dynamic).name as String;
    } catch (_) {}

    return value.toString();
  }

  static Future<DateTime?> _defaultDatePicker(FormFieldState state) {
    return showDatePicker(
      context: state.context,
      initialDate: state.date,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
  }

  static Future<XFile?> _noFilePicker(FormFieldState state) {
    throw UnimplementedError('You must setup a filePicker.');
  }

  static Future<List<XFile>> _noFilesPicker(FormFieldState state) {
    throw UnimplementedError('You must setup a filesPicker.');
  }

  static Future<String> _noFileUploader(XFile file, String? path) {
    throw UnimplementedError('You must setup a fileUploader.');
  }

  static Future<void> _noFileDeleter(String url) {
    throw UnimplementedError('You should setup a fileDeleter.');
  }

  /// The default title for all fields.
  final String Function(Object value) defaultTitle;

  /// The default date picker for [DateFormField] fields.
  final FieldPicker<DateTime?> datePicker;

  /// The default file picker for [FileFormField] fields.
  final FieldPicker<XFile?> filePicker;

  /// The default file picker for [FileListFormField] fields.
  final FieldPicker<List<XFile>> filesPicker;

  /// The default file uploader for [XFile] fields.
  final FileUploader fileUploader;

  /// The default file deleter for [XFile] fields.
  final FileDeleter? fileDeleter;
}
