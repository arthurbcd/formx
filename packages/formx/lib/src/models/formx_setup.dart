import 'dart:async';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../fields/date_formx_field.dart' show DateFormxField;
import '../fields/file_formx_field.dart' show FileFormxField;
import '../fields/file_list_formx_field.dart' show FileListFormxField;

/// A function to pick a value for a [FormField].
typedef FieldPicker<T> = Future<T> Function(FormFieldState state);

/// Signature for a function that uploads a file.
typedef FileUploader = Future<String> Function(XFile file, String? path);

/// Signature for a function that deletes a file.
typedef FileDeleter = Future<void> Function(String url);

/// Signature for a function that returns the path to upload a file.
typedef UploaderPath = FutureOr<String> Function(XFile file);

/// Global setup for all Formx widgets.
class FormxSetup {
  /// Creates a [FormxSetup].
  ///
  /// - [defaultTitle] - The default title for all fields.
  /// - [datePicker] - The default date picker for [DateFormxField] fields.
  /// - [filePicker] - The default file picker for [FileFormxField] fields.
  /// - [filesPicker] - The default file picker for [FileListFormxField] fields.
  /// - [fileUploader] - The default file uploader for [XFile] fields.
  ///
  /// NOTE: Only some fields have default implementations. Others will throw
  /// an [UnimplementedError] if not set.
  ///
  const FormxSetup({
    this.defaultTitle = _defaultTitle,
    this.datePicker = DateFormxField.defaultPicker,
    this.filePicker = _noFilePicker,
    this.filesPicker = _noFilesPicker,
    this.fileUploader = _noFileUploader,
    this.fileDeleter = _noFileDeleter,
    this.imagePicker = _noImagePicker,
    this.imagesPicker = _defaultImagesPicker,
    this.imageUploader = _noImageUploader,
    this.imageDeleter = _noImageDeleter,
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

  static Future<XFile?> _noImagePicker(FormFieldState state) {
    throw UnimplementedError('You must setup a imagePicker.');
  }

  static Future<List<XFile>> _defaultImagesPicker(FormFieldState state) {
    throw UnimplementedError('You must setup a imagesPicker.');
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

  static Future<String> _noImageUploader(XFile file, String? path) {
    throw UnimplementedError('You must setup a imageUploader.');
  }

  static Future<void> _noImageDeleter(String url) {
    throw UnimplementedError('You should setup a imageDeleter.');
  }

  /// The default title for all fields.
  final String Function(Object value) defaultTitle;

  /// The default date picker for [DateFormxField] fields.
  final FieldPicker<DateTime?> datePicker;

  /// The default file picker for [FileFormxField] fields.
  final FieldPicker<XFile?> filePicker;

  /// The default files picker for [FileListFormxField] fields.
  final FieldPicker<List<XFile>> filesPicker;

  /// The default file uploader for [XFile] file fields.
  final FileUploader fileUploader;

  /// The default file deleter for [XFile] file fields.
  final FileDeleter? fileDeleter;

  /// The default image picker for `ImageFormField` fields.
  final FieldPicker<XFile?> imagePicker;

  /// The default image picker for `ImageListFormField` fields.
  final FieldPicker<List<XFile>> imagesPicker;

  /// The default image uploader for [XFile] image fields.
  final FileUploader imageUploader;

  /// The default image deleter for [XFile] image fields.
  final FileDeleter imageDeleter;
}
