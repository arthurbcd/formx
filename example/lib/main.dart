import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(const MaterialApp(home: Material(child: FormxExample())));
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

        // Called when all fields are valid and submitted via Enter key or .submit().
        onSubmitted: (form) {
          if (Formx.at(context).validate()) {
            print('all valid and ready to go: $form');
          }
        },

        // Optional initial values for all fields. Tip: Model.toMap() or autofill.
        initialValues: const {
          'name': 'Big',
          'email': '',
          'address': {
            'street': 'Sesame Street',
            'number': 42, // will be stringified
          }
        },

        // Allows you to modify the field before it's built.
        fieldModifier: (tag, field) {
          // `.required()` is an extension. See [TextFormxFieldModifiers]
          return tag == 'name' ? field.required() : field;
        },

        // A wrapper that will be applied to all fields. DRY!
        fieldWrapper: (tag, widget) => Padding(padding: padding, child: widget),

        // [InputDecoration] callback. Tip: scope your form themes!
        decorationModifier: (tag, decoration) {
          return decoration?.copyWith(
            labelText: tag,
            border: const OutlineInputBorder(),
            constraints: const BoxConstraints(maxWidth: 300),
          );
        },

        // [TextFormField.validator] errorText callback. Tip: nice for i18n key.
        errorTextModifier: (tag, errorText) {
          if (tag == 'email') return errorText;
          return '$errorText.$tag';
        },

        // Your creativity is the limit. Manage your fields however you want.
        // Just make sure there's a [Formx] above them.
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('USER'),

              // Same as TextFormField but copiable and const.
              const TextFormxField('name'),

              /// Stack validators through extensions modifiers.
              const TextFormxField('email')
                  .validate((value) => value.isNotEmpty) // same as .required()
                  .validate((value) => value.contains('form'))
                  .validate((value) => value.contains('x'), 'Missing x')
                  .validate((value) => value.contains('@'), 'Not an email'),

              /// Simple as one line.
              const TextFormxField('password'), // adds suffixIcon

              /// Nested fields too!?
              Formx(
                tag: 'address',

                /// and value modifier? Yes!
                valueModifier: (tag, value) {
                  if (tag == 'number') {
                    return int.tryParse(value);
                  }
                  return value;
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Address:'),

                    // Use copyWith to create your own extensions!
                    const TextFormxField('street').copyWith(),

                    // Like this cool num validator.
                    const TextFormxField('number').validateNum((n) => n < 100),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // You can use formxKey or just visit the state at context.
          final state = Formx.at(context); // or .of() for above.

          // Validate all fields. Just like `Form.validate()`.
          final isValid = state.validate();

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
    );
  }
}

class ComplexDataStructure extends StatelessWidget {
  const ComplexDataStructure({super.key});

  @override
  Widget build(BuildContext context) {
    return const Formx(
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
                TextFormxField('name'),
                TextFormxField('email'),
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
                      TextFormxField('street'),
                      TextFormxField('number'),
                    ],
                  ),
                ),
                TextFormxField('school'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
