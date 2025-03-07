import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

import 'utils/finders.dart';
import 'widgets/adapter_exemple.dart';
import 'widgets/form_example.dart';

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

      testWidgets(
        'should a nested key',
        (tester) async {
          var key = 'name';
          final keys = key.split('.');

          expect(keys, ['name']);

          key = keys.removeLast();

          expect(key, 'name');
          expect(keys, <String>[]);
        },
      );

      testWidgets(
        'should a nested key',
        (tester) async {
          var key = 'user.name';
          final keys = key.split('.');

          expect(keys, ['user', 'name']);

          key = keys.removeLast();

          expect(key, 'name');
          expect(keys, ['user']);
        },
      );
    },
  );
}
