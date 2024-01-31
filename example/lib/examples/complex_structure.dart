import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(const MaterialApp(home: Scaffold(body: ComplexStructureExample())));
}

class ComplexStructureExample extends StatelessWidget {
  const ComplexStructureExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Formx(
        initialValues: {
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
              tag: 'user',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormxField(tag: 'name'),
                  TextFormxField(tag: 'email'),
                ],
              ),
            ),
            Formx(
              tag: 'details',
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Formx(
                    tag: 'address',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormxField(tag: 'street'),
                        TextFormxField(tag: 'number'),
                      ],
                    ),
                  ),
                  TextFormxField(tag: 'school'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
