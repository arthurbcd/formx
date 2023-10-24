import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(const MaterialApp(home: FormxExample()));
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
          print('all valid and ready to go: $form');
        },

        // Optional initial values for all fields. Tip: Model.toMap() or autofill.
        initialValues: const {
          'name': 'Big',
          'email': '',
          'address': {
            'street': 'Sesame Street',
            'number': '42',
          }
        },

        // Allows you to modify the field before it's built.
        onField: (tag, field) {
          // `.required()` is an extension. See [TextFormxFieldAddons]
          return ['name', 'email'].contains(tag) ? field.required() : field;
        },

        // A wrapper that will be applied to all fields. DRY!
        onWidget: (tag, widget) => Padding(padding: padding, child: widget),

        // [InputDecoration] callback. Tip: scoped form themes!
        onDecoration: (tag, decoration) {
          return decoration?.copyWith(
            labelText: tag,
            border: const OutlineInputBorder(),
            constraints: const BoxConstraints(maxWidth: 300),
          );
        },

        // [TextFormField.validator] errorText callback. Tip: nice for i18n key.
        onErrorText: (tag, errorText) => '$errorText.$tag',

        // Your creativity is the limit. Manage your fields however you want.
        // Just make sure there's a [Formx] above them.
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('USER'),

              /// Simple as one line can be.
              const TextFormxField('name'),
              const TextFormxField('email'),

              /// Nested fields too!? Yes!
              Formx(
                tag: 'address',
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Address:'),

                    // Same as TextFormField but copiable and const.
                    const TextFormxField('street').copyWith(),

                    // Thanks to copyWith we can have cool extensions!
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
          final formxState = Formx.at(context); // or .of() for above.

          // Validate all fields. Just like `Form.validate()`.
          final isValid = formxState.validate();

          if (isValid) {
            Map<String, dynamic> form = formxState.submit();
            print('all valid and ready to go: $form');
          } else {
            print('invalid fields:');
            formxState.errorTexts.forEach((tag, errorText) {
              print('$tag: $errorText');
            });
          }
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
