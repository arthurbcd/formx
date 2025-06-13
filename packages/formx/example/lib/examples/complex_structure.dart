import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

void main() {
  runApp(
    const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(width: 300, child: ComplexStructureExample()),
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
        key: const Key('form'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Form(
              key: const Key('user'),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(key: const Key('name')),
                  SliderFormxField(
                    key: const Key('age'),
                    initialValue: 18,
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: 'Age',
                    validator: Validator().maxNumber(50),
                  ),

                  TextFormField(
                    key: const Key('email'),
                    validator: Validator<String>(),
                  ),
                  TextFormField(
                    key: const Key('password'),
                    validator: Validator<String>(
                      validators: [
                        Validator(test: (value) => value.length > 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final isValid = context.formx('form').validate();
                print('Form is valid: $isValid');
                print('Form values: ${context.formx('form').toMap()}');
              },
              child: const Text('validate'),
            ),
            ElevatedButton(
              onPressed: () {
                context.field('age').validate();
                // state.nested['user']?.fields['email']
                //     ?.setErrorText('errorText');
              },
              child: const Text('setErrorText'),
            ),
            ElevatedButton(
              onPressed: () {
                context.formx('form').reset();
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
      ),
    );
  }
}
