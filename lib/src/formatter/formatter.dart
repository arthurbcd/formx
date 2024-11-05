import 'dart:collection';

import 'package:flutter/services.dart';

/// A list of [TextInputFormatter].
class Formatter extends ListBase<TextInputFormatter>
    implements TextInputFormatter {
  /// Creates a new [Formatter] instance.
  Formatter({
    List<TextInputFormatter>? formatters,
  }) {
    if (formatters != null) addAll(formatters);
  }
  final _list = <TextInputFormatter?>[];

  @override
  int get length => _list.length;

  @override
  set length(int newLength) => _list.length = newLength;

  @override
  TextInputFormatter operator [](int index) => _list[index]!;

  @override
  void operator []=(int index, TextInputFormatter value) {
    _list[index] = value;
  }

  /// Adds a [TextInputFormatter] to this list.
  Formatter addFormatter(TextInputFormatter formatter) {
    return this..add(formatter);
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return fold(newValue, (value, f) => f.formatEditUpdate(oldValue, value));
  }
}

/// Extension to format a [String] with a single [TextInputFormatter].
extension TextInputFormatterExtension on TextInputFormatter {
  /// Formats the [text] with this [TextInputFormatter].
  String format(String text) {
    final value = TextEditingValue(text: text);
    return formatEditUpdate(value, value).text;
  }
}
