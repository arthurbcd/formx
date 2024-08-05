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
    Validator.translator = (key, errorText) => '$errorText.$key';

    return Center(
      child: Form(
        onChanged: () => print(context.formx().initialValues),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: const Key('user'),
              onChanged: context.debugForm,
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
                context.formx().validate();
              },
              child: const Text('validate'),
            ),
            ElevatedButton(
              onPressed: () {
                // state.nested['user']?.fields['email']
                //     ?.setErrorText('errorText');
              },
              child: const Text('setErrorText'),
            ),
            ElevatedButton(
              onPressed: () {
                context.formx().reset();
              },
              child: const Text('reset'),
            ),
            Form(
              key: const Key('details'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Form(
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
        ),
      ),
    );
  }
}
