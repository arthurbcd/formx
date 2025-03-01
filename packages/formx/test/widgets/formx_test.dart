import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

import 'adapter_exemple.dart';
import 'form_example.dart';

void main() {
  group(
    'formx',
    () {
      testWidgets(
        'should extract each FormField.value to a Map',
        (tester) async {
          await tester.pumpWidget(const FormExample());
          final state = tester.formx('user');
          final map = state.toMap();

          expect(map, {
            'name': 'John Doe',
            'email': 'john@doe.com',
            'phone': '11999999999',
            'cpf': '99999999922',
          });
        },
      );

      testWidgets(
        'should fill each FormField.value from a Map',
        (tester) async {
          await tester.pumpWidget(const FormExample());
          final state = tester.formx('user');

          expect(state.toMap(), {
            'name': 'John Doe',
            'email': 'john@doe.com',
            'phone': '11999999999',
            'cpf': '99999999922',
          });

          state.fill({
            'name': 'Dart Flutter',
            'email': 'dart@flutter.com',
            'phone': '12312312312',
            'cpf': '12312312312',
          });

          expect(state.toMap(), {
            'name': 'Dart Flutter',
            'email': 'dart@flutter.com',
            'phone': '12312312312',
            'cpf': '12312312312',
          });
        },
      );

      testWidgets(
        'should extract each FormField.value to a Map',
        (tester) async {
          await tester.pumpWidget(const AdapterExample());

          final state = tester.formx('adapter');
          expect(state.toMap, throwsAssertionError);

          final textState = tester.field<String>('text');
          expect(textState.toValue(), 'JOHN DOE');

          final dateState = tester.field<DateTime>('date');
          expect(dateState.toValue, throwsAssertionError);
        },
      );
    },
  );
}

/// Extension for [WidgetController] to access the [FormxState].
extension WidgetControllerExtension on WidgetTester {
  /// Returns the [FormxState] of the [Form] with the given [key].
  FormxState formx(String key) {
    final state = this.state<FormState>(find.byKeyValue(key));
    return FormxState(state);
  }

  FormFieldState<T> field<T>(String key) {
    final state = this.state<FormFieldState<T>>(find.byKeyValue(key));
    return state;
  }

  /// Returns the [FormFieldState] of the [FormField] with the given [key].
  // FormFieldState<T> field<T>(String key) {
  //   final state = this.state<FormFieldState<T>>(find.byKey(Key(key)));
  //   return state;
  // }
}

extension on CommonFinders {
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
