import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../extensions/form_field_state_extension.dart';
import '../fields/date_form_field.dart';
import '../fields/file_form_field.dart';
import '../fields/file_list_form_field.dart';
import '../fields/image_form_field.dart';
import '../fields/image_list_form_field.dart';

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
    this.imagePicker = _defaultImagePicker,
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

  static Future<DateTime?> _defaultDatePicker(FormFieldState state) {
    final widget = state.widget as DateFormField;
    final now = DateTime.now();

    return showDatePicker(
      context: state.context,
      initialDate: state.date,
      firstDate: widget.firstDate ?? now.copyWith(year: now.year - 100),
      lastDate: widget.lastDate ?? now.copyWith(year: now.year + 100),
    );
  }

  static Future<XFile?> _defaultImagePicker(FormFieldState state) {
    return ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
    );
  }

  static Future<List<XFile>> _defaultImagesPicker(FormFieldState state) {
    return ImagePicker().pickMultiImage(
      imageQuality: 80,
      maxWidth: 1200,
      maxHeight: 1200,
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

  static Future<String> _noImageUploader(XFile file, String? path) {
    throw UnimplementedError('You must setup a imageUploader.');
  }

  static Future<void> _noImageDeleter(String url) {
    throw UnimplementedError('You should setup a imageDeleter.');
  }

  /// The default title for all fields.
  final String Function(Object value) defaultTitle;

  /// The default date picker for [DateFormField] fields.
  final FieldPicker<DateTime?> datePicker;

  /// The default file picker for [FileFormField] fields.
  final FieldPicker<XFile?> filePicker;

  /// The default files picker for [FileListFormField] fields.
  final FieldPicker<List<XFile>> filesPicker;

  /// The default file uploader for [XFile] file fields.
  final FileUploader fileUploader;

  /// The default file deleter for [XFile] file fields.
  final FileDeleter? fileDeleter;

  /// The default image picker for [ImageFormField] fields.
  final FieldPicker<XFile?> imagePicker;

  /// The default image picker for [ImageListFormField] fields.
  final FieldPicker<List<XFile>> imagesPicker;

  /// The default image uploader for [XFile] image fields.
  final FileUploader imageUploader;

  /// The default image deleter for [XFile] image fields.
  final FileDeleter imageDeleter;
}
