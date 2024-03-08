import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(const MaterialApp(home: Material(child: Form2Example())));
}

class Form2Example extends StatefulWidget {
  const Form2Example({super.key});

  @override
  State<Form2Example> createState() => _Form2ExampleState();
}

class _Form2ExampleState extends State<Form2Example> {
  var obscure = false;

  void toggleObscure() {
    setState(() => obscure = !obscure);
  }

  @override
  Widget build(BuildContext context) {
    return Formx(
      onChanged: print,
      builder: (context, state, _) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Formx(
                key: const Key('nested'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      key: const Key('name'),
                    ),
                    TextFormField(
                      key: const Key('password'),
                      obscureText: obscure,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: toggleObscure,
                          icon: Icon(
                            !obscure ? Icons.remove_red_eye : Icons.security,
                          ),
                        ),
                      ),
                    ),
                    TextFormField(
                      key: const Key('email'),
                    ),
                  ],
                ),
              ),
              DropdownButtonFormField(
                key: const Key('dropdown'),
                items: const [
                  DropdownMenuItem(value: 'a', child: Text('Item 1')),
                  DropdownMenuItem(value: 'b', child: Text('Item 2')),
                ],
                onChanged: (_) {},
              ),
            ],
          ),
        );
      },
    );
  }
}
class User {
  const User({required this.name, required this.email, required this.address});

  final String name;
  final String email;
  final Address address;
}

class Address {
  const Address({required this.street, required this.number});

  final String street;
  final int number;
}

class FormxExample extends StatelessWidget {
  const FormxExample({super.key});

  static const padding = EdgeInsets.all(8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Formx(
        // Check your console and type, it's alive!
        onChanged: print,

        // Optional initial values for all fields. Tip: Model.toMap() or autofill.
        initialValues: const {
          'name': 'Big',
          'email': '',
          'address': {
            'street': 'Sesame Street',
            'number': 42, // will be stringified
          },
        },

        // Your creativity is the limit. Manage your fields however you want.
        // Just make sure there's a [Formx] above them.
        builder: (context, state, _) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('USER'),

                // Just add a key to your fields and you're good to go.
                TextFormField(key: const Key('name')),
                TextFormField(key: const Key('email')),
                TextFormField(key: const Key('password')),

                /// Nested fields too!?
                Formx(
                  key: const Key('address'),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Address:'),
                      TextFormField(key: const Key('street')),
                      TextFormField(key: const Key('number')),
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
                  state.reset();
                },
                child: const Icon(Icons.refresh),
              ),
              FloatingActionButton(
                onPressed: () {
                  state.fill({
                    'name': 'Biggy',
                    'email': 'z@z',
                    'address': {
                      'street': 'Lalala Street',
                      'number': 43,
                    },
                  });
                },
                child: const Icon(Icons.edit),
              ),
              FloatingActionButton(
                onPressed: () {
                  // Validate all fields. Just like `Form.validate()`.
                  final isValid = state.validate();

                  // you can also validate specific fields:
                  // validate(['name', 'email']);

                  if (isValid) {
                    Map<String, dynamic> form = state.form;
                    print('all valid and ready to go: $form');
                  } else {
                    print('invalid fields:');
                    state.errorTexts.forEach((tag, errorText) {
                      print('$tag: $errorText');
                    });
                  }
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

class ComplexDataStructure extends StatelessWidget {
  const ComplexDataStructure({super.key});

  @override
  Widget build(BuildContext context) {
    return Formx(
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
                TextFormField(key: const Key('email')),
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
    );
  }
}
