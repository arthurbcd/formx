import '../formx_state.dart';

/// Exception thrown by [FormxState] when the form is invalid.
class FormxException implements Exception {
  /// Creates a [FormxException] with the given [errorTexts].
  FormxException(this.errorTexts, [this.errorMessage]);

  /// The error texts of each field.
  final Map<String, String> errorTexts;

  /// The error message of the form. If null, concatenates all [errorTexts].
  final String? errorMessage;

  /// All [errorTexts] as a single message.
  String get message => errorMessage ?? errorTexts.values.join(', ');

  @override
  String toString() => 'FormxException: ${errorTexts.values.join(', ')}';
}
