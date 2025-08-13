import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(
    const MaterialApp(
      locale: Locale('pt', 'BR'),
      supportedLocales: [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: Center(
        child: SizedBox(width: 400, child: Material(child: FormxExample())),
      ),
    ),
  );
}

final userKey = FormKey('user');

final userForm = Formx(
  initialValues: {
    'name': 'Arthur',
    'age': '18',
    'cpf': '00252054202',
    'email': 'some@email',
    'phone': '91982224111',
  },
);

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

    final phoneFormatter = Formatter().phone.br();

    return Scaffold(
      body: Form(
        // key: userKey,

        // Check your console and type, it's alive!
        onChanged: () {
          final map = userForm.values;
          print(map);
        },

        // Builder shortcut to access the form state.
        child: Center(
          child: Form(
            onChanged: () {
              final map = userForm.values;
              print(map);
            },
            // key: const Key('sub'),
            child: ListView(
              // mainAxisSize: MainAxisSize.min,
              children: [
                DateFormxField(
                  key: userForm.key('date'),
                  initialValue: DateTime.now(),
                  validator: Validator().required(),
                ),
                TimeFormxField(
                  key: userForm.key('time'),
                  validator: Validator().required(),
                ),
                SizedBox(
                  width: 300,
                  child: AutocompleteFormxField.paged(
                    key: userForm.key('autocomplete'),
                    search: search,
                    onResults: print,
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: SearchFormxField.paged(search: search),
                ),
                const Text('USER'),

                // FileListFormField.url(
                //   key: const Key('file'),
                // ),
                // ImageListFormField.url(
                //   initialValue: ['https://via.placeholder.com/150'],
                //   // imageUploader: (file, path) async {
                //   //   return 'url';
                //   // },
                // ),
                // DateFormField(
                //   key: formController['date'],
                // ),
                TextFormField(
                  key: userForm.key('price'),
                  inputFormatters: Formatter().currency(code: 'BRL'),
                ),

                TextFormField(
                  key: userForm.key('name'),
                  // inputFormatters: Formatter().pinyin(),
                  // validator: Validator().required().minLength(2),
                ),

                // Just add a key to your fields and you're good to go.
                TextFormField(
                  key: userForm.key('phone'),
                  // initialValue: phoneFormatter.format('91982224111'),
                  inputFormatters: phoneFormatter,
                  validator: Validator().minWords(2),
                ),

                TextFormField(
                  key: userForm.key('age'),
                  inputFormatters: Formatter().phone(),
                  validator: Validator(),
                ),
                TextFormField(
                  key: userForm.key('cpf'),
                  inputFormatters: Formatter().cpfCnpj(),
                  validator: Validator().cpfCnpj(),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: () {
                        // final isValid = formController['cpf'].validate();
                        // print(isValid);
                      },
                      icon: const Icon(Icons.check),
                    ),
                  ),
                ),
                TextFormField(
                  key: userForm.key('email', keepMask: true),
                  validator: Validator().required().email(),
                ),

                /// You can nest [Formx] to create complex structures.
                // Form(
                //   key: formController['address'],
                //   child: Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       const Text('Address:'),
                //       TextFormField(
                //         key: formController['street'],
                //         initialValue: 'Sesame Street',
                //       ),
                //       TextFormField(
                //         key: formController['age'],
                //       ),
                //       RadioListFormField(
                //         key: formController['names'],
                //         items: const ['Arthur', 'Iran', 'Juan'],
                //         validator: Validator().required(),
                //       ),
                //       CheckboxListFormField(
                //         key: formController['friends'],
                //         items: const ['Arthur', 'Iran', 'Juan'],
                //         validator: Validator().minLength(2),
                //       ),
                //       CheckboxFormField(
                //         key: formController['terms'],
                //         title: const Text('I agree to the terms'),
                //         validator: Validator().required(),
                //       ),
                //     ],
                //   ),
                // ),
                ElevatedButton(
                  onPressed: () {
                    userForm.validate();
                    final map = userForm.values;
                    print(map);
                  },
                  child: const Text('Submit'),
                ),
                ElevatedButton(
                  onPressed: () {
                    userForm.reset();
                    final map = userForm.values;
                    print(map);
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> search(int page, String query) async {
    await Future.delayed(const Duration(seconds: 1));
    // throw Exception('Error searching for $query');

    return List.generate(10, (index) => '${10 * page + ++index}');
  }
}

// class MyForm extends StatefulWidget {
//   final Widget child;
//   const MyForm({super.key, required this.child});

//   @override
//   State<MyForm> createState() => _MyFormState();
// }

// class _MyFormState extends State<MyForm> {
//   late final formKey = FormKey(widget.key?.value ?? '$hashCode');

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // This is a good place to initialize the form state
//       // or perform any setup that requires the widget to be built.
//       formKey.state.fill(map);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: formKey,
//       onChanged: () {},
//       child: widget.child,
//     );
//   }
// }
