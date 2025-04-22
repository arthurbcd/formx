import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:formx/formx.dart';
// import 'package:formx/formx.dart';

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

final userKey = FormKey();

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
      floatingActionButton: const MyWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      body: Form(
        key: userKey,

        // Check your console and type, it's alive!
        onChanged: () {
          final state = context.formx();
          print(state.toMap());
        },

        // Builder shortcut to access the form state.
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: const Key('sub'),
              onChanged: context.debugForm,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DateFormField(
                    key: const Key('datex'),
                    validator: Validator().isAfter(DateTime.now()),
                  ),
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
                  // FileListFormField.url(
                  //   key: const Key('file'),
                  // ),
                  // ImageListFormField.url(
                  //   initialValue: ['https://via.placeholder.com/150'],
                  //   // imageUploader: (file, path) async {
                  //   //   return 'url';
                  //   // },
                  // ),
                  const DateFormField(
                    key: Key('date'),
                  ),

                  TextFormField(
                    key: const Key('price'),
                    inputFormatters: Formatter().currency(code: 'BRL'),
                  ),

                  TextFormField(
                    key: const Key('name'),
                    inputFormatters: Formatter().pinyin(),
                    // validator: Validator().required().minLength(2),
                  ),

                  // Just add a key to your fields and you're good to go.
                  TextFormField(
                    key: const Key('phone'),
                    initialValue: phoneFormatter.format('91982224111'),
                    inputFormatters: phoneFormatter,
                    validator: Validator().minWords(2),
                  ),

                  TextFormField(
                    key: const Key('age'),
                    initialValue: '1',
                    inputFormatters: Formatter().phone(),
                    validator: Validator(),
                  ),
                  TextFormField(
                    key: const Key('cpf'),
                    initialValue: '00252054202',
                    inputFormatters: Formatter().cpfCnpj(),
                    validator: Validator().cpfCnpj(),
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          final isValid = context.field('cpf').validate();
                          print(isValid);
                        },
                        icon: const Icon(Icons.check),
                      ),
                    ),
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
                          key: const Key('friends').options<List<String>>(
                            adapter: (v) => [for (final i in v) i],
                          ),
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
                  ElevatedButton(
                    onPressed: () {
                      userKey.state.submit();
                      // context.submit();
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
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
