import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            height: 400,
            width: 300,
            child: ComplexStructureExample(),
          ),
        ),
      ),
    ),
  );
}

class ComplexStructureExample extends StatelessWidget {
  const ComplexStructureExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Formx(
        onChanged: print,
        // autovalidateMode: AutovalidateMode.always,
        initialValues: const {
          'user': {
            'name': 'Big',
            // 'email': 'a',
          },
          'details': {
            'address': {
              // 'street': 'Sesame Street',
              'number': '42',
            },
            'school': 'Sesame School',
          },
        },
        builder: (_, state, __) => Builder(builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Formx(
                key: const Key('user'),
                // autovalidateMode: AutovalidateMode.disabled,
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
              ElevatedButton(
                onPressed: () {
                  state.validate();
                },
                child: const Text('validate'),
              ),
              ElevatedButton(
                onPressed: () {
                  state.reset();
                },
                child: const Text('reset'),
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
                          TextFormField(
                            key: const Key('street'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return value.isEmail ? null : 'Invalid email';
                            },
                          ),
                          TextFormField(
                            key: const Key('number'),
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
                    TextFormField(key: const Key('school')),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

extension on String {
  bool get isEmail => contains('@');
}
