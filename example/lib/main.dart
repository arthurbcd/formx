import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(
    const MaterialApp(
      locale: Locale('pt', 'BR'),
      supportedLocales: [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Material(
        child: FormxExample(),
      ),
    ),
  );
}

class FormxExample extends StatelessWidget {
  const FormxExample({super.key});

  List<String> get items => [
        'name1',
        'name2',
        'name3',
        'name4',
        'name5',
        'name6',
        'name7',
        'name8',
        'name9',
      ];

  @override
  Widget build(BuildContext context) {
    Validator.translator = (key, errorText) => '$errorText.$key';

    return Scaffold(
      floatingActionButton: const MyWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Form(
        key: const Key('user'),

        // Check your console and type, it's alive!
        onChanged: () {
          final state = context.formx();
          print(state.toMap());
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
              onChanged: context.debugForm,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 300,
                    child: AutocompleteFormField.paged(
                      key: const Key('autocomplete'),
                      search: search,
                      onResults: print,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: SearchFormField.paged(
                      search: search,
                    ),
                  ),
                  const Text('USER'),
                  const DateFormField(
                    key: Key('date'),
                  ),

                  // Just add a key to your fields and you're good to go.
                  TextFormField(
                    key: const Key('name'),
                    initialValue: 'Big',
                    validator: Validator().minWords(2),
                  ),
                  TextFormField(
                    key: const Key('age').text().toInt(),
                    initialValue: '1',
                    validator: Validator(),
                  ),
                  TextFormField(
                    key: const Key('email'),
                    initialValue: 'some@email',
                    validator: Validator().required().email(),
                  ),

                  /// You can nest [Formx] to create complex structures.
                  Form(
                    key: const Key('address'),
                    onChanged: context.debugForm,
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
                          key: const Key('age'),
                        ),
                        RadioListFormField(
                          key: const Key('names'),
                          items: const ['Arthur', 'Iran', 'Juan'],
                          validator: Validator().required(),
                        ),
                        CheckboxListFormField(
                          key:
                              const Key('friends').list<Expertise>((v) => v.id),
                          items: const ['Arthur', 'Iran', 'Juan'],
                          validator: Validator().minLength(2),
                        ),
                        CheckboxFormField(
                          key: const Key('terms'),
                          title: const Text('I agree to the terms'),
                          validator: Validator().required(),
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

                  // state['address'] = {
                  //   'street': 'Lalala',
                  //   'number': '42',
                  // };

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

  Future<List<String>> search(int page, String query) async {
    await Future.delayed(const Duration(seconds: 1));

    return List.generate(10, (index) => '${10 * page + ++index}');
  }
}

class Expertise {
  final String id;

  Expertise(this.id);
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        print(context.formx().toMap());
      },
      child: const Text('Print Form'),
    );
  }
}
