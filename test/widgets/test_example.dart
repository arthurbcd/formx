import 'package:flutter/material.dart';
import 'package:formx/formx.dart';

class TestExample extends StatelessWidget {
  const TestExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: _Example(),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: const Key('user'),
      child: Column(
        children: [
          TextFormField(
            key: const Key('name'),
            initialValue: 'John Doe',
          ),
          TextFormField(
            key: const Key('email'),
            initialValue: 'john@doe.com',
            validator: Validator<String>().email(),
          ),
          TextFormField(
            key: const Key('cpf'),
            initialValue: '00252054202',
            inputFormatters: Formatter().mask('000.000.000-00'),
            validator: Validator().minWords(2),
          ),
          TextFormField(
            key: const Key('phone'),
            initialValue: '11999999999',
            inputFormatters: Formatter().phone(code: 'BR'),
          ),
        ],
      ),
    );
  }
}
