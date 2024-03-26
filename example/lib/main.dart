import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(const MaterialApp(home: Material(child: FormxExample())));
}

class FormxExample extends StatelessWidget {
  const FormxExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Formx(
        // Check your console and type, it's alive!
        onChanged: print,

        // Optional initial values for all fields. Tip: Model.toMap().
        initialValues: const {
          'name': 'Big',
          'email': 'some@email',
          'address': {
            'street': 'Sesame Street',
            'number': '42',
          },
        },

        // Builder shortcut to access the form state.
        builder: (state) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('USER'),

                // Just add a key to your fields and you're good to go.
                TextFormField(
                  key: const Key('name'),
                ),
                TextFormField(
                  key: const Key('email'),
                ),

                /// You can nest [Formx] to create complex structures.
                Formx(
                  key: const Key('address'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Address:'),
                      TextFormField(
                        key: const Key('street'),
                      ),
                      TextFormField(
                        key: const Key('number'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  // reset to initial values.
                  state.reset();
                },
                child: const Icon(Icons.refresh),
              ),
              FloatingActionButton(
                onPressed: () {
                  // programatically fill all fields.
                  state.fill({
                    'name': 'Biggy',
                    'email': 'z@z',
                    'address': {
                      'street': 'Lalala Street',
                      'number': '43',
                    },
                  });

                  // or the shorthand:
                  state['name'] = 'Biggy';
                  state['email'] = 'z@z';
                  state['address'] = {
                    'street': 'Lalala Street',
                    'number': '43',
                  };
                },
                child: const Icon(Icons.edit),
              ),
              FloatingActionButton(
                onPressed: () {
                  // Validate all fields. Just like `Form.validate()`.
                  final isValid = state.validate();
                  print('isValid: $isValid');

                  // You can also validate a single field.
                  final isEmailValid = state.validate(['email']);
                  print('isEmailValid: $isEmailValid');
                },
                child: const Icon(Icons.check),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
