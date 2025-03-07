import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

import '../utils/finders.dart';
import 'adapter_exemple.dart';
import 'form_example.dart';
import 'nested_example.dart';

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
        'should handle nested forms and fields',
        (tester) async {
          late BuildContext context;
          await tester.pumpWithForm(
            key: 'user',
            builder: (ctx) {
              context = ctx;
              return const NestedExample();
            },
          );

          final state = context.formx('user');
          final map = state.toMap();
          final userData = UserData.fromMap(map);

          expect(userData, isA<UserData>());
          expect(map, userData.toMap()..clean()); // nonNulls

          final zip = context.field('user.address.zip');
          final zipChild = context.field('user.address.address.zip');

          expect(zip.toValue(), '62704');
          expect(zipChild.toValue(), '62705');

          expect(() => context.field('street'), throwsAssertionError); // dupli.
          final street = context.field('user.address.street');
          final streetChild = context.field('user.address.address.street');

          expect(street.toValue(), '123 Main St');
          expect(streetChild.toValue(), '456 Elm St');

          final address = context.formx('user.address');
          final addressChild = context.formx('user.address.address');

          expect(address.toMap(), {
            'street': '123 Main St',
            'city': 'Springfield',
            'state': 'IL',
            'zip': '62704',
            'address': {
              'street': '456 Elm St',
              'city': 'Shelbyville',
              'state': 'IL',
              'zip': '62705',
            },
          });

          expect(addressChild.toMap(), {
            'street': '456 Elm St',
            'city': 'Shelbyville',
            'state': 'IL',
            'zip': '62705',
          });
        },
      );
    },
  );
}
