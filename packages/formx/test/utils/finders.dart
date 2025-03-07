import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

Matcher isFormxException(Map<String, dynamic> errors) {
  return isA<FormxException>().having(
    (e) => e.errorTexts,
    'errors',
    equals(errors),
  );
}

Matcher throwsFormxException([Map<String, dynamic>? errors]) {
  if (errors == null) {
    return throwsA(isA<FormxException>());
  }
  return throwsA(isFormxException(errors));
}

extension WidgetControllerExtension on WidgetTester {
  /// Equivalent to `context.formx`.
  FormxState formx(String key) {
    final state = this.state<FormState>(find.byKeyValue(key));
    return FormxState(state);
  }

  /// Equivalent to `context.field`.
  FormFieldState<T> field<T>(String key) {
    final state = this.state<FormFieldState<T>>(find.byKeyValue(key));
    return state;
  }

  /// Sintactic sugar to `pumpWidget`.
  Future<void> pumpWithForm({
    required String key,
    required WidgetBuilder builder,
  }) {
    return pumpWidget(
      MaterialApp(
        key: UniqueKey(),
        home: Scaffold(
          body: Form(
            key: Key(key),
            child: Builder(builder: builder),
          ),
        ),
      ),
    );
  }
}

extension CommonFindersByKeyValue on CommonFinders {
  /// Finds a widget by its key `value`.
  /// ```dart
  /// Key('name') -> find.byKeyValue('name')
  /// ```
  MatchFinder byKeyValue(String key) => _KeyValueFinder(key);
}

class _KeyValueFinder extends MatchFinder {
  _KeyValueFinder(this.value);
  final String value;

  @override
  String get description => 'key $value';

  @override
  bool matches(Element candidate) {
    return candidate.widget.key?.value == value;
  }
}
