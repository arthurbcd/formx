import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(const MaterialApp(home: Scaffold(body: ComplexStructureExample())));
}

class ComplexStructureExample extends StatelessWidget {
  const ComplexStructureExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Formx(
        initialValues: const {
          'user': {
            'name': 'Big',
            'email': 'a@a',
          },
          'details': {
            'address': {
              'street': 'Sesame Street',
              'number': 42, // will be stringified
            },
            'school': 'Sesame School',
          },
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Formx(
              key: const Key('user'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(key: const Key('name')),
                  TextFormField(
                    key: const Key('email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return value.isEmail ? null : 'Invalid email';
                    },
                  ),
                ],
              ),
            ),
            Formx(
              key: const Key('details'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Formx(
                    key: const Key('address'),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(key: const Key('street')),
                        TextFormField(key: const Key('number')),
                      ],
                    ),
                  ),
                  TextFormField(key: const Key('school')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  bool get isEmail => contains('@');
}
