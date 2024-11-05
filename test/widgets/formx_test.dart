import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

import 'test_example.dart';

void main() {
  testWidgets(
    'formx',
    (tester) async {
      await tester.pumpWidget(const TestExample());
      final state = tester.formx('user');

      state.fill({
        'phone': '91999999999',
      });

      final map = state.toMap();

      // await tester.enterText(find.byKey(const Key('phone')), '91999999999');

      expect(map, {
        'name': 'John Doe',
        'email': 'john@doe.com',
        'phone': '91999999999',
        'cpf': '00000000000',
      });
    },
  );
}

/// Extension for [WidgetController] to access the [FormxState].
extension WidgetControllerExtension on WidgetTester {
  /// Returns the [FormxState] of the [Form] with the given [key].
  FormxState formx(String key) {
    final state = this.state<FormState>(find.byKey(Key(key)));
    return FormxState(state);
  }

  /// Returns the [FormFieldState] of the [FormField] with the given [key].
  // FormFieldState<T> field<T>(String key) {
  //   final state = this.state<FormFieldState<T>>(find.byKey(Key(key)));
  //   return state;
  // }
}
