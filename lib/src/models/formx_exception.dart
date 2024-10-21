import '../extensions/formx_state.dart';

/// Exception thrown by [FormxState] when the form is invalid.
class FormxException implements Exception {
  /// Creates a [FormxException] with the given [errorTexts].
  FormxException(this.errorTexts);

  /// The error texts of each field.
  final Map<String, String> errorTexts;

  /// All [errorTexts] as a single message.
  String get message => errorTexts.values.join(', ');

  @override
  String toString() => 'FormxException: ${errorTexts.values.join(', ')}';
}
