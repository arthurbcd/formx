import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
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
    Validator.defaultRequiredText = 'form.required';
    Validator.defaultInvalidText = 'form.invalid';
    Validator.modifier = (validator, errorText) {
      if (!errorText.contains('form.')) return errorText;

      return '$errorText.${validator.key}';
    };

    return Center(
      child: Formx(
        onChanged: print,
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
        builder: (state) => Builder(builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Formx(
                key: const Key('user'),
                // autovalidateMode: AutovalidateMode.disabled,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: const Key('name'),
                      // validator: Validator(),
                    ),
                    TextFormField(
                      key: const Key('email'),
                      validator: Validator<String>(),
                    ),
                    TextFormField(
                      key: const Key('password'),
                      validator: Validator<String>(
                        validators: [
                          Validator(
                            test: (value) => value.length > 5,
                          ),
                        ],
                      ),
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
                  state.nested['user']?.fields['email']
                      ?.setErrorText('errorText');
                },
                child: const Text('setErrorText'),
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
                          ),
                          TextFormField(
                            key: const Key('number'),
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
