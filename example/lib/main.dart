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
      floatingActionButton: const MyWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Form(
        key: const Key('user'),
        // Check your console and type, it's alive!
        onChanged: () {
          final state = context.formx();
          print(state.values);
        },

        // Optional initial values for all fields. Tip: Model.toMap().
        // initialValues: const {
        //   'name': 'Big',
        //   'email': 'some@email',
        //   'address': {
        //     'street': 'Sesame Street',
        //     'number': '42',
        //   },
        // },

        // Builder shortcut to access the form state.
        child: Scaffold(
          body: Center(
            child: Form(
              onChanged: context.onFormChanged,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('USER'),

                  // Just add a key to your fields and you're good to go.
                  TextFormField(
                    key: const Key('name'),
                    initialValue: 'Big',
                  ),
                  TextFormField(
                    key: const Key('email'),
                    initialValue: 'some@email',
                    validator: Validator<String>(
                        // test: isEmail,
                        ),
                  ),

                  /// You can nest [Formx] to create complex structures.
                  Form(
                    key: const Key('address'),
                    onChanged: context.onFormChanged,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Address:'),
                        const MyWidget(),
                        TextFormField(
                          key: const Key('street'),
                          initialValue: 'Sesame Street',
                        ),
                        TextFormField(
                          key: const Key('number'),
                          initialValue: '42',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                onPressed: () {
                  // reset to initial values.
                  context.formx().reset();
                },
                child: const Icon(Icons.refresh),
              ),
              FloatingActionButton(
                onPressed: () {
                  // programatically fill all fields.
                  // state.fill({
                  //   'name': 'Biggy',
                  //   'email': 'z@z',
                  //   'address': {
                  //     'street': 'Lalala Street',
                  //     'number': '43',
                  //   },
                  // });

                  // or the shorthand:
                  // state['name'] = 'Biggy';
                  // state['email'] = 'z@z';
                  // state['address'] = {
                  //   'street': 'Lalala Street',
                  //   'number': '43',
                  // };
                },
                child: const Icon(Icons.edit),
              ),
              FloatingActionButton(
                onPressed: () {
                  final state = context.formx();
                  // Validate all fields. Just like `Form.validate()`.
                  final isValid = state.validate();
                  print('isValid: $isValid');

                  state['address'] = {
                    'street': 'Lalala',
                    'number': '42',
                  };

                  // You can also validate a single field.
                  // final isEmailValid = state.validate(['email']);
                  // print('isEmailValid: $isEmailValid');
                },
                child: const Icon(Icons.check),
              ),
              const MyWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print(context.formx().values.indented);
      },
      child: const Text('Print Form'),
    );
  }
}
