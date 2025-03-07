import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:formx/formx.dart';

import '../utils/finders.dart';

void main() {
  group(
    'Validator',
    () {
      testWidgets(
        'should be interoperable with TextFormField.validator',
        (tester) async {
          await tester.pumpWithForm(
            key: 'form',
            builder: (context) {
              return TextFormField(
                key: const Key('email'),
                validator: (value) {
                  if (value?.isEmpty ?? false) {
                    return 'isEmpty';
                  }
                  return null;
                },
              );
            },
          );
          final email = tester.field('email');

          expect(email.submit, throwsFormxException({'email': 'isEmpty'}));
          expect(email.errorText, 'isEmpty');

          email.didChange('a@a.com');
          await tester.pump();

          expect(email.submit(), 'a@a.com');
        },
      );
      testWidgets(
        'should be interoperable with Validator',
        (tester) async {
          await tester.pumpWithForm(
            key: 'form',
            builder: (context) => TextFormField(
              key: const Key('email'),
              validator: Validator().required('isEmpty'),
            ),
          );
          final email = tester.field('email');

          expect(email.submit, throwsFormxException({'email': 'isEmpty'}));
          expect(email.errorText, 'isEmpty');

          email.didChange('a@a.com');
          await tester.pump();

          expect(email.submit(), 'a@a.com');
        },
      );
      testWidgets(
        'should throw an error when calling setErrorText without Validator()',
        (tester) async {
          await tester.pumpWithForm(
            key: 'form',
            builder: (context) => TextFormField(
              key: const Key('email'),
              validator: (_) => 'isEmpty',
            ),
          );
          final email = tester.field('email');
          expect(email.submit, throwsFormxException({'email': 'isEmpty'}));

          expect(() => email.setErrorText('errorText'), throwsAssertionError);
        },
      );
      testWidgets(
        'should set errorText when calling setErrorText with Validator()',
        (tester) async {
          await tester.pumpWithForm(
            key: 'form',
            builder: (context) => TextFormField(
              key: const Key('email'),
              validator: Validator().required('isEmpty'),
            ),
          );
          final email = tester.field('email');
          expect(email.submit, throwsFormxException({'email': 'isEmpty'}));

          email.setErrorText('errorText');
          expect(email.errorText, 'errorText');

          email.setErrorText(null);
          expect(email.errorText, null);
        },
      );
      testWidgets(
        'should assert duplicated fields',
        (tester) async {
          late BuildContext context;
          await tester.pumpWithForm(
            key: 'form',
            builder: (ctx) {
              context = ctx;
              return Column(
                children: [
                  SizedBox(
                    child: TextFormField(
                      key: const Key('email'),
                      validator: Validator().required('isEmpty'),
                    ),
                  ),
                  TextFormField(
                    key: const Key('email'),
                    validator: Validator().required('isEmpty'),
                  ),
                ],
              );
            },
          );

          expect(() => context.field('email'), throwsAssertionError);
        },
      );
      testWidgets(
        'should assert direct nested duplicated form keys',
        (tester) async {
          late BuildContext context;
          await tester.pumpWithForm(
            key: 'form',
            builder: (ctx) {
              return Form(
                key: const Key('form'),
                child: Builder(
                  builder: (ctx) {
                    context = ctx;
                    return Column(
                      children: [
                        TextFormField(
                          key: const Key('email'),
                          validator: Validator().required('isEmpty'),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          );

          expect(() => context.formx('form'), throwsAssertionError);
        },
      );
    },
  );
}
